# Place Autocomplete Plugin
> Designed by Oracle APEX developers, for Oracle APEX developers.

### Features
Return address into multiple items

![](https://user-images.githubusercontent.com/9313239/30663109-969e9a0a-9e17-11e7-83e3-a111b0385e7f.gif)

* `Address` - Return the street address into an item.
  * `Address Long Form` - Setting to 'Yes' will return the unabbreviated street address. Ex: Street vs. St.
* `City` - Return the city into an item.
* `State` - Return the state into an item.
  * `State Long Form` - Setting to 'Yes' will return the unabbreviated state. Ex: New York vs. NY
* `ZIP` - Return the ZIP into an item.
* `Country` - Return the country into an item.
  * `Country Long Form` - Setting to 'Yes' will return the unabbreviated country. Ex: United States vs. US
* `Latitude` - Return the latitude into an item.
* `Longitude` - Return the longitude into an item.

Return address into Interactive Grid columns

![](https://user-images.githubusercontent.com/9313239/30664071-7cd91ff2-9e1a-11e7-9a13-5f47801c2b1d.gif)

* `Address` - Return the street address into a column.
  * `Address Long Form` - Setting to 'Yes' will return the unabbreviated street address. Ex: Street vs. St.
* `City` - Return the city into a column.
* `State` - Return the state into a column.
  * `State Long Form` - Setting to 'Yes' will return the unabbreviated state. Ex: New York vs. NY
* `ZIP` - Return the ZIP into a column.
* `Country` - Return the country into a column.
  * `Country Long Form` - Setting to 'Yes' will return the unabbreviated country. Ex: United States vs. US
* `Latitude` - Return the latitude into a column.
* `Longitude` - Return the longitude into a column.

Return address JSON

![](https://user-images.githubusercontent.com/9313239/30664716-a1a69eb6-9e1c-11e7-878c-f7a0556812ce.gif)

Create a Dynamic Action
* `Event` : place_changed[Google Address Autocomplete]
* `Selection Type` : Item(s)
* `Item(s)` : <autocomplete plugin item>

True:
* `Action` : Execute JavaScript Code
* `Code` : ```console.log(this.data)```

You can access the JSON with this.data. The size of the JSON is dynamic based on the users input. If a city is entered, you will not receive route, street_number, etc...

Example:
```
administrative_area_level_1 : "New York"
administrative_area_level_2 : "Clinton County"
country : "United States"
lat : 44.697461
lng : -73.466204
locality : "Plattsburgh"
postal_code : "12901"
postal_code_suffix : "2727"
route : "Beekman Street"
street_number : "46"
```

### Installation
1. Download the item_type_plugin_com_insum_placecomplete.sql file.
2. Import the plugin into your application.
3. During installation, enter your Google Maps Javascript API Key. If you do not have one, you can acquire one here: https://developers.google.com/maps/documentation/javascript/get-api-key
4. Enjoy!

### Project Sponsors
[Insum Solutions](http://insum.ca)

### Team
* [Neil Fernandez](mailto:nfernandez@insum.ca)  
* [Martin D'Souza](mailto:mdsouza@insum.ca)
