<?php
/**
 * @file
 * tap_ipad_app_custom_stops.features.inc
 */

/**
 * Implements hook_ctools_plugin_api().
 */
function tap_ipad_app_custom_stops_ctools_plugin_api() {
  list($module, $api) = func_get_args();
  if ($module == "strongarm" && $api == "strongarm") {
    return array("version" => "1");
  }
}

/**
 * Implements hook_node_info().
 */
function tap_ipad_app_custom_stops_node_info() {
  $items = array(
    'event_stop' => array(
      'name' => t('Event Stop'),
      'base' => 'node_content',
      'description' => t('A stop that describes a particular event'),
      'has_title' => '1',
      'title_label' => t('Title'),
      'help' => '',
    ),
    'video_stop_with_category' => array(
      'name' => t('Video Stop with Category'),
      'base' => 'node_content',
      'description' => t('Video stop for use in the TAP iPad app.'),
      'has_title' => '1',
      'title_label' => t('Title'),
      'help' => '',
    ),
  );
  return $items;
}
