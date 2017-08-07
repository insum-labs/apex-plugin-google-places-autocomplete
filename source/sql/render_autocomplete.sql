create or replace procedure render_autocomplete  (
    p_item in apex_plugin.t_page_item,
    p_plugin in apex_plugin.t_plugin,
    p_param in apex_plugin.t_item_render_param,
    p_result in out nocopy apex_plugin.t_item_render_result ) IS

    subtype plugin_attr is varchar2(32767);

    l_result apex_plugin.t_item_render_result;
    l_js_params varchar2(1000);
    l_onload_string varchar2(3000);
    l_name varchar2(30);

    -- Plugin attributes
    l_api_key plugin_attr := p_plugin.attribute_01;

    -- Component attributes
    l_purpose plugin_attr := p_item.attribute_01;
    l_address plugin_attr := p_item.attribute_02;
    l_city plugin_attr := p_item.attribute_03;
    l_state plugin_attr := p_item.attribute_04;
    l_zip plugin_attr := p_item.attribute_05;
    l_country plugin_attr := p_item.attribute_06;
    l_latitude plugin_attr := p_item.attribute_07;
    l_longitude plugin_attr := p_item.attribute_08;
    l_address_long plugin_attr := p_item.attribute_09;
    l_state_long plugin_attr := p_item.attribute_10;
    l_country_long plugin_attr := p_item.attribute_11;
    l_location_type plugin_attr := p_item.attribute_12;

begin
    -- Get internal name of the input element
    l_name := apex_plugin.get_input_name_for_page_item(false);

    -- Get API key for JS file name
    l_js_params := '?key=' || l_api_key || '&libraries=places';

    apex_javascript.add_library
          (p_name           => 'js' || l_js_params
          ,p_directory      => 'https://maps.googleapis.com/maps/api/'
          ,p_skip_extension => true);

    apex_javascript.add_library
      (p_name                  => 'autocomplete'
      ,p_directory             => p_plugin.file_prefix);

    -- For use with APEX 5.1 and up.
    sys.htp.prn (apex_string.format('<input type="text" %s size="%s" maxlength="%s"/>'
                                    , apex_plugin_util.get_element_attributes(p_item, l_name, 'text_field')
                                    , p_item.element_width
                                    , p_item.element_max_length));

    l_onload_string := '
var allItems_#ITEM# = {
  autoComplete : {
    id : "'||p_item.name||'"
  },
  route : {
    id : "'|| l_address ||'",
    form : "' || CASE WHEN l_address_long = 'Y' THEN 'long_name' ELSE 'short_name' END || '"
  },
  locality : {
    id : "'|| l_city ||'",
    form : "long_name"
  },
  administrative_area_level_1 : {
    id : "'|| l_state ||'",
    form : "' || CASE WHEN l_state_long = 'Y' THEN 'long_name' ELSE 'short_name' END || '"
  },
  postal_code : {
    id : "'|| l_zip ||'",
    form : "long_name"
  },
  country : {
    id : "'|| l_country ||'",
    form : "' || CASE WHEN l_country_long = 'Y' THEN 'long_name' ELSE 'short_name' END || '"
  },
  lat : {id : "'|| l_latitude ||'"},
  lng : {id : "'|| l_longitude ||'"}
};
var opt_#ITEM# = {
  place_type : ['|| CASE WHEN l_location_type IS NOT NULL THEN '''' || l_location_type || '''' END || '],
  purpose: "'|| l_purpose ||'"
};
initAutocomplete(allItems_#ITEM#, opt_#ITEM#);
';
    l_onload_string := REPLACE(l_onload_string,'#ITEM#',p_item.id);
    apex_javascript.add_inline_code(p_code => l_onload_string);
end render_autocomplete;
