/**
 * Insum Solutions Google Places Address Autocomplete for APEX
 * Plug-in Type: Item
 * Summary: Plugin to autocomplete a location and return the address into separate fields, as well as return address JSON data
 *
 *
 * Version:
 *  1.0.0: Initial
 *
 * ^^^ Contact information ^^^
 * Developed by Insum Solutions
 * http://www.insum.ca
 * nfern002@plattsburgh.edu
 *
 * ^^^ License ^^^
 * Licensed Under: The MIT License (MIT) - http://www.opensource.org/licenses/gpl-3.0.html
 *
 * @author Neil Fernandez - http://www.neilfernandez.com
 */


//USE apex.debug

$.widget('ui.placesAutocomplete', {
  // Default options
  options: {
    pageItems: {
      autoComplete: {
        id: ''
      },
      route: {
        id: '',
        form: ''
      },
      locality: {
        id: '',
        form: ''
      },
      administrative_area_level_1: {
        id: '',
        form: ''
      },
      postal_code: {
        id: '',
        form: ''
      },
      country: {
        id: '',
        form: ''
      }
    },
    action: '',
    locationType: '',
    componentType: '',
    componentTypePageItem: '',
    componentTypeIgColumn: ''
  },


  /**
   * Set private widget varables.
   */
  _setWidgetVars: function() {
    var uiw = this;

    uiw._scope = 'ui.placesAutocomplete'; //For debugging

    uiw._values = {
      place_json: {},
      place: {}
    };

    uiw._elements = {
      $autoComplete: $(uiw.element)
    };
    uiw._constants = {
      googleEvent: "place_changed",
      apexEvent: "place_changed",
      split: "SPLIT",
      pageItem: uiw.options.componentTypePageItem,
      gridColumn: uiw.options.componentTypeIgColumn
    };
  }, //_setWidgetVars

  /**
   * Create function: Only called the first time the widget is assiocated to the object
   * Will implicitly call the _init function after
   */
  _create: function() {
    var uiw = this;

    uiw._setWidgetVars(); // Set variables (don't modify this)

    var consoleGroupName = uiw._scope + '_create';
    // console.groupCollapsed(consoleGroupName); //Need to use apex.debug
    apex.debug.log('this:', uiw);

    // Register autoComplete
    var autocomplete = new google.maps.places.Autocomplete(
      /** @type {!HTMLInputElement} */
      (uiw._elements.$autoComplete.get(0)), {
        types: [uiw.options.locationType ? uiw.options.locationType : "geocode"]
      });

    // Bias the autocomplete object to the user's geographical location,
    // as supplied by the browser's 'navigator.geolocation' object.
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(function(position) {
        var geolocation = {
          lat: position.coords.latitude,
          lng: position.coords.longitude
        };
        var circle = new google.maps.Circle({
          center: geolocation,
          radius: position.coords.accuracy
        });
        autocomplete.setBounds(circle.getBounds());
      });
    }

    // When the user selects an address from the dropdown, populate the address
    // fields in the form.
    autocomplete.addListener(uiw._constants.googleEvent, function() {
      uiw._values.place = autocomplete.getPlace();
      uiw._generateJSON();

      // Trigger place_changed in APEX
      uiw._elements.$autoComplete.trigger(uiw._constants.apexEvent, uiw._values.place_json);

      // Split into page items
      if (uiw.options.action == uiw._constants.split && uiw.options.componentType == uiw._constants.pageItem) {

        // Clear out all items except for the address field
        for (var item in uiw.options.pageItems) {
          item == 'autoComplete' ? null : $s(uiw.options.pageItems[item].id, '');
        }

        // Set latitude and longitude if they exist
        uiw.options.pageItems.lat.id ? $s(uiw.options.pageItems.lat.id, uiw._values.place.geometry.location.lat()) : null;
        uiw.options.pageItems.lng.id ? $s(uiw.options.pageItems.lng.id, uiw._values.place.geometry.location.lng()) : null;

        for (var i = 0; i < uiw._values.place.address_components.length; i++) {
          var addressType = uiw._values.place.address_components[i].types[0];
          // GET RID OF OUTTER IF
          if (uiw.options.pageItems[addressType]) {
            if (uiw.options.pageItems[addressType].id) {
              var val = '';
              if (addressType == 'route') {
                uiw._values.place.address_components[0].types[0] == 'street_number' ? val = uiw._values.place.address_components[0].short_name + ' ' : null;
              }
              val += uiw._values.place.address_components[i][uiw.options.pageItems[addressType].form];
              // Set page item value
              $s(uiw.options.pageItems[addressType].id, val);
            }
          }
        } // END LOOP
      }
      // Split into grid columns
      else if(uiw.options.action == uiw._constants.split && uiw.options.componentType == uiw._constants.gridColumn){
        var $selector = $('#' + uiw.options.pageItems.autoComplete.id);
        var region = apex.region.findClosest($selector);

        // Get the place details from the autocomplete object.
        var place = uiw._values.place;
        var i, records, record, model,
        view = region.widget().interactiveGrid("getCurrentView");

        if ( view.supports.edit ) { // make sure this is the editable view
            model = view.model;
            records = view.getSelectedRecords();
            // TODO Fix issue when clicking Return instead of clicking in the IG. Current record issue.
            apex.debug.log('record: ',records.length);
            if ( records.length > 0 ) {
                for ( i = 0; i < records.length; i++ ) {
                    record = records[i];

                     // Clear out all items except for the address field
                     for (var item in uiw.options.pageItems) {
                       uiw.options.pageItems[item].id ? item == 'autoComplete' ? null : model.setValue(record, uiw.options.pageItems[item].id, '') : null;
                     }

                     // Set latitude and longitude if they exist
                    uiw.options.pageItems.lat.id ? model.setValue(record, uiw.options.pageItems.lat.id, place.geometry.location.lat()) : null;
                    uiw.options.pageItems.lng.id ? model.setValue(record, uiw.options.pageItems.lng.id, place.geometry.location.lng()) : null;

                    // Get all address components
                    for (var i = 0; i < uiw._values.place.address_components.length; i++) {
                      var addressType = uiw._values.place.address_components[i].types[0];
                      // GET RID OF OUTTER IF
                      if (uiw.options.pageItems[addressType]) {
                        if (uiw.options.pageItems[addressType].id) {
                          var val = '';
                          if (addressType == 'route') {
                            uiw._values.place.address_components[0].types[0] == 'street_number' ? val = uiw._values.place.address_components[0].short_name + ' ' : null;
                          }
                          val += uiw._values.place.address_components[i][uiw.options.pageItems[addressType].form];
                          // Set grid column value
                          model.setValue(record, uiw.options.pageItems[addressType].id, val);
                        }
                      }
                    }
                } // END LOOP
            }
        }
      }
    });

    // console.groupEnd(consoleGroupName); // Need to find out to use apex.debug
  }, //_create

  /**
   * Init function. This function will be called each time the widget is referenced with no parameters
   */
  _init: function(place) {
    var uiw = this;

    apex.debug.log(uiw._scope, '_init', uiw);
  }, //_init


  /**
   * Saves place_json into internal _values
   */
  _generateJSON: function() {
    var uiw = this;
    var place = uiw._values.place;
    uiw._values.place_json = {};

    uiw._values.place_json.lat = place.geometry.location.lat();
    uiw._values.place_json.lng = place.geometry.location.lng();

    for (var i = 0; i < place.address_components.length; i++) {
      var addressType = place.address_components[i].types[0];
      uiw._values.place_json[addressType] = place.address_components[i].long_name;
    }

    apex.debug.log(uiw._scope, '_generateJSON', uiw);

  }, //_generateJSON

  destroy: function() {
    var uiw = this;
    apex.debug.log(uiw._scope, 'destroy', uiw);
    // Undo autocomplete
    $.Widget.prototype.destroy.apply(uiw, arguments); // default destroy
  } //destroy

}); //ui.widgetName
