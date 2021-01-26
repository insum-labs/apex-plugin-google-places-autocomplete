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
        id: '',
        page_item_value: ''
      },
      lat: {
        id: ''
      },
      lng: {
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
    componentTypeIgColumn: '',
    locationBias: ''
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
      apexEventFullObject: "place_changed_full_object", //(Marie Hilpl 8/1/18)
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
    var options = uiw.options.locationType ? {types: [uiw.options.locationType]} : {};
    var autocomplete = new google.maps.places.Autocomplete(
      /** @type {!HTMLInputElement} */
      (uiw._elements.$autoComplete.get(0)), options);
    // 8/1/18 Marie Hilpl: Set style of autocomplete input to be the same as the reset of the inputs
    // Problem identified in Apex 5.1
    var autocomplete_elm_id = uiw.options.pageItems.autoComplete.id;
    $('#'+autocomplete_elm_id+'').addClass('apex-item-text');

    // 8/3/18 Marie Hilpl: Get value of autocomplete page item if it's beign used to return address
    // item into it. Then set the page item value.
    var address_elm_id = uiw.options.pageItems.route.id;
    if (autocomplete_elm_id == address_elm_id){
      //uiw.options.pageItems.autoComplete.id ? $s(uiw.options.pageItems.autoComplete.id, uiw.options.pageItems.autoComplete.page_item_value) : null;
      $s(uiw.options.pageItems.autoComplete.id, uiw.options.pageItems.autoComplete.page_item_value);
    }

    // 8/1/18 Marie Hilpl: Commented out because google places is automatically geolocating by IP address
    // Bias the autocomplete object to the user's geographical location,
    // as supplied by the browser's 'navigator.geolocation' object.
    if (uiw.options.locationBias == "Y"){
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
    }

    // 1/15/19 Marie Hilpl: Fix old enter/tab listener
    // When enter or tab pressed, simulate selection of first item in dropdown
    var autocomplete_elm = document.getElementById(autocomplete_elm_id);
    enableEnterTabKeys(autocomplete_elm);

    function enableEnterTabKeys(input) {
      // Store original event listener
      var _addEventListener = (input.addEventListener) ? input.addEventListener : input.attachEvent;

      function addEventListenerWrapper(type, listener) {
        // Simulate a 'down arrow' keypress on hitting 'return' when no pac suggestion is selected,
        // and then trigger the original listener.
        if (type === "keydown") {
          // Store existing listener function
          var orig_listener = listener;
          listener = function(event) {
            var suggestion_selected = $(".pac-item-selected").length > 0;
            if (event.which === 9 || event.which === 13 && !suggestion_selected) {
               var simulated_downarrow = $.Event("keydown", {
                   keyCode: 40,
                   which: 40
               });
               orig_listener.apply(input, [simulated_downarrow]);
           }

           orig_listener.apply(input, [event]);

          };
       }
         _addEventListener.apply(input, [type, listener]);
      }
      input.addEventListener = addEventListenerWrapper;
      input.attachEvent      = addEventListenerWrapper;
     }

    // When the user selects an address from the dropdown, populate the address
    // fields in the form.
    autocomplete.addListener(uiw._constants.googleEvent, function() {
      uiw._values.place = autocomplete.getPlace();
      uiw._generateJSON();

      //Trigger place_changed_full_info in apex (Marie Hilpl 8/1/18)
      uiw._elements.$autoComplete.trigger(uiw._constants.apexEventFullObject, uiw._values.place);

      // Trigger place_changed in APEX
      uiw._elements.$autoComplete.trigger(uiw._constants.apexEvent, uiw._values.place_json);

      if (uiw._values.place.address_components) {
        // Split into page items
        if (uiw.options.action == uiw._constants.split && uiw.options.componentType == uiw._constants.pageItem) {

    /*      // Clear out all items except for the address field
          for (var item in uiw.options.pageItems) {
            item == 'autoComplete' ? null : $s(uiw.options.pageItems[item].id, '');
          }
    */
          // Clear out all items except for the address field
          uiw._clearItems();

          var lat = uiw._values.place.geometry.location.lat();
          var long = uiw._values.place.geometry.location.lng();

          if (apex.locale.getDecimalSeparator() == ',') {
              lat = lat.toString().replace(/\./g, ',');
              long = long.toString().replace(/\./g, ',');
          }

          // Set latitude and longitude if they exist
          uiw.options.pageItems.lat.id ? $s(uiw.options.pageItems.lat.id, lat) : null;
          uiw.options.pageItems.lng.id ? $s(uiw.options.pageItems.lng.id, long) : null;

          for (var i = 0; i < uiw._values.place.address_components.length; i++) {
            var addressType = uiw._values.place.address_components[i].types[0];

            // 8/1/18 Marie Hilpl: Handle missing locality by using sublocality_level_1
            if (uiw.options.pageItems['locality']) {
              if (uiw.options.pageItems['locality'].id) {
                if (addressType == 'sublocality_level_1') {
                  var sublocality = uiw._values.place.address_components[i].short_name;
                  $s(uiw.options.pageItems['locality'].id, sublocality);
                }
              }
            }

            // GET RID OF OUTTER IF
            if (uiw.options.pageItems[addressType]) {
              if (uiw.options.pageItems[addressType].id) {
                var val = '';
                //var city = sublocality ? sublocality : uiw._values.place.address_components[0].short_name;

                if (addressType == 'route') {
                  //uiw._values.place.address_components[0].types[0] == 'street_number' ? val = uiw._values.place.address_components[0].short_name + ' ' : null;
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
                     /*for (var item in uiw.options.pageItems) {
                         uiw.options.pageItems[item].id ? item == 'autoComplete' ? null : model.setValue(record, uiw.options.pageItems[item].id, '') : null;
                       }*/
                      // Clear out all items except for the address field
                      uiw._clearItems(model, record);

                      // Set latitude and longitude if they exist
                      // 8/1/18 Marie Hilpl: added ' "" + ' before the value for lat/lng to fix bug where numbers would not save
                      uiw.options.pageItems.lat.id ? model.setValue(record, uiw.options.pageItems.lat.id, "" + place.geometry.location.lat()) : null;
                      uiw.options.pageItems.lng.id ? model.setValue(record, uiw.options.pageItems.lng.id, "" + place.geometry.location.lng()) : null;

                      // Get all address components
                      for (var i = 0; i < uiw._values.place.address_components.length; i++) {
                        var addressType = uiw._values.place.address_components[i].types[0];

                        // 8/1/18 Marie Hilpl: Handle missing locality by using sublocality_level_1
                        if (uiw.options.pageItems['locality']) {
                          if (uiw.options.pageItems['locality'].id) {
                            if (addressType == 'sublocality_level_1') {
                              var sublocality = uiw._values.place.address_components[i].short_name;
                              model.setValue(record, uiw.options.pageItems['locality'].id, sublocality);
                            }
                          }
                        }

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
      }
      else {
        // Clear address items if no address found
        uiw._clearItems();
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
    if(place.address_components) {
      uiw._values.place_json.lat = place.geometry.location.lat();
      uiw._values.place_json.lng = place.geometry.location.lng();

      for (var i = 0; i < place.address_components.length; i++) {
        var addressType = place.address_components[i].types[0];
        uiw._values.place_json[addressType] = place.address_components[i].long_name;
      }

      apex.debug.log(uiw._scope, '_generateJSON', uiw);
    }
  }, //_generateJSON

  destroy: function() {
    var uiw = this;
    apex.debug.log(uiw._scope, 'destroy', uiw);
    // Undo autocomplete
    $.Widget.prototype.destroy.apply(uiw, arguments); // default destroy
  }, //destroy

  // Clear address items
  _clearItems: function(model, record) {
    var uiw = this;
    // Clear page items
    if (uiw.options.componentType == uiw._constants.pageItem) {
      // Clear out all items except for the address field
      for (var item in uiw.options.pageItems) {
        // #25: Fixes issue in APEX 20.x as the id is an empty string if not defined (this is ok)
        if (item != 'autoComplete' && uiw.options.pageItems[item].id != ''){
          $s(uiw.options.pageItems[item].id, '');
        }
      }
    }
    // Clear IR Grid cells
    else if (uiw.options.componentType == uiw._constants.gridColumn) {
      var $selector = $('#' + uiw.options.pageItems.autoComplete.id);
      var region = apex.region.findClosest($selector);

      var i, records, record, model,
      view = region.widget().interactiveGrid("getCurrentView");

      if ( view.supports.edit ) { // make sure this is the editable view
          model = view.model;
          records = view.getSelectedRecords();

        if ( records.length > 0 ) {
          for ( i = 0; i < records.length; i++ ) {
              record = records[i];
            // Clear out all items except for the address field
            for (var item in uiw.options.pageItems) {
              uiw.options.pageItems[item].id ? item == 'autoComplete' ? null : model.setValue(record, uiw.options.pageItems[item].id, '') : null;
            }
          }
        }
      }
    }
  } //_clearItems


}); //ui.widgetName
