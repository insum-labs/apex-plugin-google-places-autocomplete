set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2016.08.24'
,p_release=>'5.1.1.00.08'
,p_default_workspace_id=>1880665973001338
,p_default_application_id=>254
,p_default_owner=>'SANDBOX'
);
end;
/
prompt --application/ui_types
begin
null;
end;
/
prompt --application/shared_components/plugins/item_type/com_insum_placecomplete
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(137888084662405544)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'COM.INSUM.PLACECOMPLETE'
,p_display_name=>'Google Places Autocomplete'
,p_supported_ui_types=>'DESKTOP'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'procedure render_autocomplete  (',
'    p_item   in            apex_plugin.t_page_item,',
'    p_plugin in            apex_plugin.t_plugin,',
'    p_param  in            apex_plugin.t_item_render_param,',
'    p_result in out nocopy apex_plugin.t_item_render_result ) IS',
'    ',
'    SUBTYPE plugin_attr is VARCHAR2(32767);   ',
'    ',
'    l_result            APEX_PLUGIN.t_item_render_result;',
'    l_js_params         varchar2(1000);',
'    l_onload_string     varchar2(3000);',
'    l_name              varchar2(30);',
'    ',
'    -- Plugin attributes',
'    l_api_key           plugin_attr := p_plugin.attribute_01;',
'            ',
'    -- Component attributes',
'    l_purpose           plugin_attr := p_item.attribute_01;',
'    l_address           plugin_attr := p_item.attribute_02;',
'    l_city              plugin_attr := p_item.attribute_03;',
'    l_state             plugin_attr := p_item.attribute_04;',
'    l_zip               plugin_attr := p_item.attribute_05;    ',
'    l_country           plugin_attr := p_item.attribute_06;',
'    l_latitude          plugin_attr := p_item.attribute_07;',
'    l_longitude         plugin_attr := p_item.attribute_08;',
'    l_address_long      plugin_attr := p_item.attribute_09;',
'    l_state_long        plugin_attr := p_item.attribute_10;',
'    l_country_long      plugin_attr := p_item.attribute_11;',
'    l_location_type     plugin_attr := p_item.attribute_12;',
'    ',
'begin',
'    -- Get internal name of the input element',
'    l_name := apex_plugin.get_input_name_for_page_item(false);',
'    ',
'    -- Get API key for JS file name',
'    l_js_params := ''?key='' || l_api_key || ''&libraries=places'';',
'    ',
'    APEX_JAVASCRIPT.add_library',
'          (p_name           => ''js'' || l_js_params',
'          ,p_directory      => ''https://maps.googleapis.com/maps/api/''',
'          ,p_skip_extension => true);',
'               ',
'    APEX_JAVASCRIPT.add_library',
'      (p_name                  => ''autocomplete''',
'      ,p_directory             => p_plugin.file_prefix);',
'      ',
'    /* -- For DEV purposes',
'    APEX_JAVASCRIPT.add_library',
'      (p_name                  => ''autocomplete''',
'      ,p_directory             => ''#APP_IMAGES#/'');',
'    */  ',
'    ',
'    --For use with APEX 5.0 and below',
'    /*',
'    sys.htp.prn (''<input type="text" '' ',
'               || apex_plugin_util.get_element_attributes(p_item, l_name, ''text_field'') ',
'               || ''size="''||p_item.element_width||''" ''',
'               || ''maxlength="''||p_item.element_max_length||''" ''',
'               || '' />''); ',
'    */',
'    ',
'    -- For use with APEX 5.1 and up.',
'    sys.htp.prn (apex_string.format(''<input type="text" %s size="%s" maxlength="%s"/>''',
'                                    , apex_plugin_util.get_element_attributes(p_item, l_name, ''text_field'')',
'                                    , p_item.element_width',
'                                    , p_item.element_max_length));',
'                                    ',
'    l_onload_string := ''var allItems_#ITEM# = { ',
'                          autoComplete : {',
'                            id : "''||p_item.name||''"',
'                          },',
'                          route : {',
'                            id : "''|| l_address ||''",',
'                            form : "'' || CASE WHEN l_address_long = ''Y'' THEN ''long_name'' ELSE ''short_name'' END || ''"',
'                          },',
'                          locality : {',
'                            id : "''|| l_city ||''",',
'                            form : "long_name"',
'                          },',
'                          administrative_area_level_1 : {',
'                            id : "''|| l_state ||''",',
'                            form : "'' || CASE WHEN l_state_long = ''Y'' THEN ''long_name'' ELSE ''short_name'' END || ''"',
'                          },',
'                          postal_code : {',
'                            id : "''|| l_zip ||''",',
'                            form : "long_name"',
'                          },',
'                          country : {',
'                            id : "''|| l_country ||''",',
'                            form : "'' || CASE WHEN l_country_long = ''Y'' THEN ''long_name'' ELSE ''short_name'' END || ''"',
'                          },',
'                          lat : {id : "''|| l_latitude ||''"},',
'                          lng : {id : "''|| l_longitude ||''"}',
'                        };',
'                        var opt_#ITEM# = { ',
'                          place_type : [''|| CASE WHEN l_location_type IS NOT NULL THEN '''''''' || l_location_type || '''''''' END || ''],',
'                          purpose: "''|| l_purpose ||''"',
'                        };',
'                        initAutocomplete(allItems_#ITEM#, opt_#ITEM#);'';',
'    l_onload_string := REPLACE(l_onload_string,''#ITEM#'',p_item.id);',
'    apex_javascript.add_inline_code(p_code => l_onload_string);',
'end render_autocomplete;'))
,p_api_version=>2
,p_render_function=>'render_autocomplete'
,p_standard_attributes=>'VISIBLE:FORM_ELEMENT:WIDTH'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0'
,p_files_version=>2
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(137888905158417223)
,p_plugin_id=>wwv_flow_api.id(137888084662405544)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Google Maps API Key'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_help_text=>'Enter your Google Maps API key here. You can get one from : https://developers.google.com/maps/documentation/javascript/examples/places-autocomplete-addressform'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(137890457692422129)
,p_plugin_id=>wwv_flow_api.id(137888084662405544)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Purpose'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'If left null, you may only select a Google Place Address.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(137890924681424105)
,p_plugin_attribute_id=>wwv_flow_api.id(137890457692422129)
,p_display_sequence=>10
,p_display_value=>'Split into items and return JSON'
,p_return_value=>'SPLIT'
,p_help_text=>'Will split the address returned to be stored into multiple page items such as Street, City, State, Zip, etc.. As well as return the JSON if needed. The JSON data can be retrieved with the place_changed custom dynamic action event.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(137891322528427830)
,p_plugin_attribute_id=>wwv_flow_api.id(137890457692422129)
,p_display_sequence=>20
,p_display_value=>'Only return JSON'
,p_return_value=>'JSON'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Will just return the JSON contatining all the address components from the Google Place Address chosen.',
'The data can be retrieved with the place_changed custom dynamic action event.'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(137894468600497599)
,p_plugin_id=>wwv_flow_api.id(137888084662405544)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Address Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(137890457692422129)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'SPLIT'
,p_help_text=>'Page item to return the street address into.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(137896047363500462)
,p_plugin_id=>wwv_flow_api.id(137888084662405544)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'City Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(137890457692422129)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'SPLIT'
,p_help_text=>'Page item to return the city into.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(137897261437505124)
,p_plugin_id=>wwv_flow_api.id(137888084662405544)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'State Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(137890457692422129)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'SPLIT'
,p_help_text=>'Page item to return the state into.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(137898926052507700)
,p_plugin_id=>wwv_flow_api.id(137888084662405544)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Zip Code Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(137890457692422129)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'SPLIT'
,p_help_text=>'Page item to return the zip code into.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(137901312828513354)
,p_plugin_id=>wwv_flow_api.id(137888084662405544)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Country Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(137890457692422129)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'SPLIT'
,p_help_text=>'Page item to return the country into.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(137903917196518168)
,p_plugin_id=>wwv_flow_api.id(137888084662405544)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Latitude Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(137890457692422129)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'SPLIT'
,p_help_text=>'Page item to return the latitude into.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(137905335583520803)
,p_plugin_id=>wwv_flow_api.id(137888084662405544)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Longitude Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(137890457692422129)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'SPLIT'
,p_help_text=>'Page item to return the longitude into.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(137906949839525361)
,p_plugin_id=>wwv_flow_api.id(137888084662405544)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Address Long Form'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(137894468600497599)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_NULL'
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Long form : 123 Testing Street',
'<br>',
'Short form: 123 Testing St.'))
,p_help_text=>'If set to ''Yes'', then the street address returned will be in long form. If set to ''No'', the street address returned will be in short form.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(137908475842528777)
,p_plugin_id=>wwv_flow_api.id(137888084662405544)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>100
,p_prompt=>'State Long Form'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(137897261437505124)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_NULL'
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Long form : New York',
'<br>',
'Short form: NY'))
,p_help_text=>'If set to ''Yes'', then the state returned will be in long form. If set to ''No'', the state returned will be in short form.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(137909660455532236)
,p_plugin_id=>wwv_flow_api.id(137888084662405544)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_prompt=>'Country Long Form'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(137901312828513354)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_NULL'
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Long form : United States',
'<br>',
'Short form: US'))
,p_help_text=>'If set to ''Yes'', then the country returned will be in long form. If set to ''No'', the country returned will be in short form.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(137910899809534566)
,p_plugin_id=>wwv_flow_api.id(137888084662405544)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>120
,p_prompt=>'Place Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_null_text=>'All'
,p_help_text=>'You may restrict results from a Place Autocomplete request to be of a certain type by passing a types parameter. The parameter specifies a type or a type collection, as listed in the supported types below. If nothing is specified, all types are retur'
||'ned. In general only a single type is allowed. The exception is that you can safely mix the geocode and establishment types, but note that this will have the same effect as specifying no types.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(137912157318535930)
,p_plugin_attribute_id=>wwv_flow_api.id(137910899809534566)
,p_display_sequence=>10
,p_display_value=>'geocode'
,p_return_value=>'geocode'
,p_help_text=>'geocode instructs the Place Autocomplete service to return only geocoding results, rather than business results. Generally, you use this request to disambiguate results where the location specified may be indeterminate.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(137912580503536970)
,p_plugin_attribute_id=>wwv_flow_api.id(137910899809534566)
,p_display_sequence=>20
,p_display_value=>'address'
,p_return_value=>'address'
,p_help_text=>'address instructs the Place Autocomplete service to return only geocoding results with a precise address. Generally, you use this request when you know the user will be looking for a fully specified address.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(137912960990538173)
,p_plugin_attribute_id=>wwv_flow_api.id(137910899809534566)
,p_display_sequence=>30
,p_display_value=>'establishment'
,p_return_value=>'establishment'
,p_help_text=>'establishment instructs the Place Autocomplete service to return only business results.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(137930424860539427)
,p_plugin_attribute_id=>wwv_flow_api.id(137910899809534566)
,p_display_sequence=>40
,p_display_value=>'(regions)'
,p_return_value=>'(regions)'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'The (regions) type collection instructs the Places service to return any result matching the following types:',
'locality',
'sublocality',
'postal_code',
'country',
'administrative_area_level_1',
'administrative_area_level_2'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(137930902879541207)
,p_plugin_attribute_id=>wwv_flow_api.id(137910899809534566)
,p_display_sequence=>50
,p_display_value=>'(cities)'
,p_return_value=>'(cities)'
,p_help_text=>'The (cities) type collection instructs the Places service to return results that match locality or administrative_area_level_3.'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '66756E6374696F6E20696E69744175746F636F6D706C65746528616C6C4974656D732C206F707429207B0D0A2020617065782E64656275672E6C6F6728616C6C4974656D73293B0D0A2020617065782E64656275672E6C6F67286F7074293B0D0A0D0A20';
wwv_flow_api.g_varchar2_table(2) := '202F2F2043726561746520746865206175746F636F6D706C657465206F626A6563740D0A2020766172206175746F636F6D706C6574652C20706C6163653B0D0A0A20206175746F636F6D706C657465203D206E657720676F6F676C652E6D6170732E706C';
wwv_flow_api.g_varchar2_table(3) := '616365732E4175746F636F6D706C657465280D0A0920202F2A2A204074797065207B2148544D4C496E707574456C656D656E747D202A2F28646F63756D656E742E676574456C656D656E744279496428616C6C4974656D732E6175746F436F6D706C6574';
wwv_flow_api.g_varchar2_table(4) := '652E696429292C0D0A0920207B74797065733A206F70742E706C6163655F747970657D293B0D0A0D0A20202F2F204269617320746865206175746F636F6D706C657465206F626A65637420746F20746865207573657227732067656F6772617068696361';
wwv_flow_api.g_varchar2_table(5) := '6C206C6F636174696F6E2C0D0A20202F2F20617320737570706C696564206279207468652062726F77736572277320276E6176696761746F722E67656F6C6F636174696F6E27206F626A6563742E0D0A2020696620286E6176696761746F722E67656F6C';
wwv_flow_api.g_varchar2_table(6) := '6F636174696F6E29207B0D0A202020206E6176696761746F722E67656F6C6F636174696F6E2E67657443757272656E74506F736974696F6E2866756E6374696F6E28706F736974696F6E29207B0D0A2020202020207661722067656F6C6F636174696F6E';
wwv_flow_api.g_varchar2_table(7) := '203D207B0D0A20202020202020206C61743A20706F736974696F6E2E636F6F7264732E6C617469747564652C0D0A20202020202020206C6E673A20706F736974696F6E2E636F6F7264732E6C6F6E6769747564650D0A2020202020207D3B0D0A20202020';
wwv_flow_api.g_varchar2_table(8) := '202076617220636972636C65203D206E657720676F6F676C652E6D6170732E436972636C65287B0D0A202020202020202063656E7465723A2067656F6C6F636174696F6E2C0D0A20202020202020207261646975733A20706F736974696F6E2E636F6F72';
wwv_flow_api.g_varchar2_table(9) := '64732E61636375726163790D0A2020202020207D293B0D0A2020202020206175746F636F6D706C6574652E736574426F756E647328636972636C652E676574426F756E64732829293B0D0A202020207D293B0D0A20207D0D0A0D0A20202F2F205768656E';
wwv_flow_api.g_varchar2_table(10) := '2074686520757365722073656C6563747320616E20616464726573732066726F6D207468652064726F70646F776E2C20706F70756C6174652074686520616464726573730D0A20202F2F206669656C647320696E2074686520666F726D2E0D0A0D0A2020';
wwv_flow_api.g_varchar2_table(11) := '6175746F636F6D706C6574652E6164644C697374656E65722827706C6163655F6368616E676564272C2066756E6374696F6E202829207B0D0A092020706C616365203D206175746F636F6D706C6574652E676574506C61636528293B0D0A202020206170';
wwv_flow_api.g_varchar2_table(12) := '65782E64656275672E6C6F6728706C616365293B0D0A0D0A20202F2F4669726520706C6163655F6368616E676564206576656E740D0A2020617065782E6A5175657279282223222B616C6C4974656D732E6175746F436F6D706C6574652E6964292E7472';
wwv_flow_api.g_varchar2_table(13) := '69676765722822706C6163655F6368616E676564222C204A534F4E2E737472696E67696679287B0D0A20202020227374726565745F6E756D62657222203A20706C6163652E616464726573735F636F6D706F6E656E74735B305D203F20706C6163652E61';
wwv_flow_api.g_varchar2_table(14) := '6464726573735F636F6D706F6E656E74735B305D2E6C6F6E675F6E616D65203A206E756C6C2C0D0A2020202022726F75746522203A20706C6163652E616464726573735F636F6D706F6E656E74735B315D203F20706C6163652E616464726573735F636F';
wwv_flow_api.g_varchar2_table(15) := '6D706F6E656E74735B315D2E6C6F6E675F6E616D65203A206E756C6C2C0D0A20202020226C6F63616C69747922203A20706C6163652E616464726573735F636F6D706F6E656E74735B325D203F20706C6163652E616464726573735F636F6D706F6E656E';
wwv_flow_api.g_varchar2_table(16) := '74735B325D2E6C6F6E675F6E616D65203A206E756C6C2C0D0A202020202261646D696E6973747261746976655F617265615F6C6576656C5F3122203A20706C6163652E616464726573735F636F6D706F6E656E74735B345D203F20706C6163652E616464';
wwv_flow_api.g_varchar2_table(17) := '726573735F636F6D706F6E656E74735B345D2E6C6F6E675F6E616D65203A206E756C6C2C0D0A202020202261646D696E6973747261746976655F617265615F6C6576656C5F32223A20706C6163652E616464726573735F636F6D706F6E656E74735B335D';
wwv_flow_api.g_varchar2_table(18) := '203F20706C6163652E616464726573735F636F6D706F6E656E74735B335D2E6C6F6E675F6E616D65203A206E756C6C2C0D0A2020202022706F7374616C5F636F646522203A20706C6163652E616464726573735F636F6D706F6E656E74735B365D203F20';
wwv_flow_api.g_varchar2_table(19) := '706C6163652E616464726573735F636F6D706F6E656E74735B365D2E6C6F6E675F6E616D65203A206E756C6C2C0D0A2020202022706F7374616C5F636F64655F73756666697822203A20706C6163652E616464726573735F636F6D706F6E656E74735B37';
wwv_flow_api.g_varchar2_table(20) := '5D203F20706C6163652E616464726573735F636F6D706F6E656E74735B375D2E6C6F6E675F6E616D65203A206E756C6C2C0D0A2020202022636F756E7472792220203A20706C6163652E616464726573735F636F6D706F6E656E74735B355D203F20706C';
wwv_flow_api.g_varchar2_table(21) := '6163652E616464726573735F636F6D706F6E656E74735B355D2E6C6F6E675F6E616D65203A206E756C6C0D0A20207D29293B0D0A0D0A2020696620286F70742E707572706F7365203D3D202753504C495427297B0D0A202020202F2F20436C656172206F';
wwv_flow_api.g_varchar2_table(22) := '757420616C6C206974656D732065786365707420666F72207468652061646472657373206669656C640D0A20202020666F722028766172206974656D20696E20616C6C4974656D7329207B0D0A2020202020206974656D203D3D20276175746F436F6D70';
wwv_flow_api.g_varchar2_table(23) := '6C65746527203F206E756C6C203A20247328616C6C4974656D735B6974656D5D2E69642C2727293B0D0A202020207D0D0A0D0A202020202F2F536574206C6174697475646520616E64206C6F6E67697475646520696620746865792065786973740D0A20';
wwv_flow_api.g_varchar2_table(24) := '202020616C6C4974656D735B276C6174275D2E6964203F20247328616C6C4974656D735B276C6174275D2E69642C706C6163652E67656F6D657472792E6C6F636174696F6E2E6C6174282929203A206E756C6C3B0D0A20202020616C6C4974656D735B27';
wwv_flow_api.g_varchar2_table(25) := '6C6E67275D2E6964203F20247328616C6C4974656D735B276C6E67275D2E69642C706C6163652E67656F6D657472792E6C6F636174696F6E2E6C6E67282929203A206E756C6C3B0D0A0D0A202020202F2F20536574206F7468657220636F6D706F6E656E';
wwv_flow_api.g_varchar2_table(26) := '74730D0A20202020666F7220287661722069203D20303B2069203C20706C6163652E616464726573735F636F6D706F6E656E74732E6C656E6774683B20692B2B29207B0D0A202020202020766172206164647265737354797065203D20706C6163652E61';
wwv_flow_api.g_varchar2_table(27) := '6464726573735F636F6D706F6E656E74735B695D2E74797065735B305D3B0D0A202020202020202069662028616C6C4974656D735B61646472657373547970655D29207B0D0A2020202020202020202069662028616C6C4974656D735B61646472657373';
wwv_flow_api.g_varchar2_table(28) := '547970655D5B276964275D297B0D0A202020202020202020202020696620286164647265737354797065203D3D2027726F7574652729207B0D0A20202020202020202020202020207661722076616C203D20706C6163652E616464726573735F636F6D70';
wwv_flow_api.g_varchar2_table(29) := '6F6E656E74735B305D2E73686F72745F6E616D65202B20272027202B20706C6163652E616464726573735F636F6D706F6E656E74735B695D5B616C6C4974656D735B61646472657373547970655D5B27666F726D275D5D3B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(30) := '20207D0D0A202020202020202020202020656C73657B0D0A20202020202020202020202020207661722076616C203D20706C6163652E616464726573735F636F6D706F6E656E74735B695D5B616C6C4974656D735B61646472657373547970655D5B2766';
wwv_flow_api.g_varchar2_table(31) := '6F726D275D5D3B0D0A2020202020202020202020207D0D0A202020202020202020202020247328616C6C4974656D735B61646472657373547970655D5B276964275D2C76616C293B0D0A202020202020202020207D0D0A20202020202020207D0D0A2020';
wwv_flow_api.g_varchar2_table(32) := '202020207D0D0A202020207D0D0A20207D293B0D0A7D0D0A0D0A2F2A0D0A2F2F204269617320746865206175746F636F6D706C657465206F626A65637420746F20746865207573657227732067656F67726170686963616C206C6F636174696F6E2C0D0A';
wwv_flow_api.g_varchar2_table(33) := '2F2F20617320737570706C696564206279207468652062726F77736572277320276E6176696761746F722E67656F6C6F636174696F6E27206F626A6563742E0D0A66756E6374696F6E2067656F6C6F636174652829207B0D0A2020696620286E61766967';
wwv_flow_api.g_varchar2_table(34) := '61746F722E67656F6C6F636174696F6E29207B0D0A202020206E6176696761746F722E67656F6C6F636174696F6E2E67657443757272656E74506F736974696F6E2866756E6374696F6E28706F736974696F6E29207B0D0A202020202020766172206765';
wwv_flow_api.g_varchar2_table(35) := '6F6C6F636174696F6E203D207B0D0A20202020202020206C61743A20706F736974696F6E2E636F6F7264732E6C617469747564652C0D0A20202020202020206C6E673A20706F736974696F6E2E636F6F7264732E6C6F6E6769747564650D0A2020202020';
wwv_flow_api.g_varchar2_table(36) := '207D3B0D0A20202020202076617220636972636C65203D206E657720676F6F676C652E6D6170732E436972636C65287B0D0A202020202020202063656E7465723A2067656F6C6F636174696F6E2C0D0A20202020202020207261646975733A20706F7369';
wwv_flow_api.g_varchar2_table(37) := '74696F6E2E636F6F7264732E61636375726163790D0A2020202020207D293B0D0A2020202020206175746F636F6D706C6574652E736574426F756E647328636972636C652E676574426F756E64732829293B0D0A202020207D293B0D0A20207D0D0A7D0D';
wwv_flow_api.g_varchar2_table(38) := '0A2A2F0D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(138500919170418072)
,p_plugin_id=>wwv_flow_api.id(137888084662405544)
,p_file_name=>'autocomplete.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
