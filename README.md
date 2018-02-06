# Google Places Autocomplete Plugin
> Designed by Oracle APEX developers, for Oracle APEX developers.

## Features
### Return address into multiple items
![](https://user-images.githubusercontent.com/9313239/30663109-969e9a0a-9e17-11e7-83e3-a111b0385e7f.gif)

### Return address into Interactive Grid columns
![](https://user-images.githubusercontent.com/9313239/30664071-7cd91ff2-9e1a-11e7-9a13-5f47801c2b1d.gif)

### Return address JSON
![](https://user-images.githubusercontent.com/9313239/30666236-a4bca064-9e21-11e7-93cf-914235af5e82.gif)

Create a Dynamic Action
* `Event` : place_changed[Google Address Autocomplete]
* `Selection Type` : Item(s)
* `Item(s)` : `<autocomplete plugin item>`

On True:
* `Action` : Execute JavaScript Code
* `Code` : ```console.log(this.data)```

You can access the JSON with this.data. The size of the JSON is dynamic based on the users input. If a city is entered, you will not receive route, street_number, etc...

Example:
```
{
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
}
```

Note : This only works for the Page Item and not the Interactive Grid for now.

## Installation
1. Download the item_type_plugin_com_insum_placecomplete.sql file.
2. Import the plugin into your application.
3. During installation, enter your Google Maps Javascript API Key. If you do not have one, you can acquire one here: https://developers.google.com/maps/documentation/javascript/get-api-key
4. Enjoy!

## Pricing
Google has limits on the amount of requests per day that you can make for free. This plugin uses the Google Maps JavaScript API. Please view the pricing table to determine if you will need to enable billing:
https://developers.google.com/maps/pricing-and-plans/#details

## Changelog
[See changelog.](changelog.md)

## Project Sponsors
[Insum Solutions](http://insum.ca)

## Team
* [Neil Fernandez](https://github.com/neilfernandez)  
* [Martin D'Souza](https://github.com/martindsouza)
