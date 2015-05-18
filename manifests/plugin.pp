# == Define: wordpress::plugin
#
# Installs a zipped wordpress plugin.
#
# This is largely based on https://github.com/seattle-biomed/puppet-wordpress/blob/master/manifests/app/plugin.pp
#
# === Actions
#
#  - install wordpress plugin from zip file
#
# === Parameters
#
# The name of the define must be the name of the plugin (directory in the zip file)
#
# [*zip_url*]
#   String. URL to the zip file to download
#
# [*zip_filename*]
#   String. The name of the zip file.
#
# [*wp_owner*]
#   String. User to own wp-config.php
#   Default: 'wordpress'
#
# [*wp_group*]
#   String. Group to own wp-config.php
#   Default: 'wordpress'
#
# [*install_dir*]
#   Absolute Path. Directory where WordPress is installed.
#   Default: '/var/www/html'
#
# === Notes
#
# Relies on hunner/wordpress in order to do anything useful
#
define wordpress::plugin (
  $zip_url,
  $zip_filename,
  $wp_owner     = $::wordpress::wp_owner,
  $wp_group     = $::wordpress::wp_group,
  $install_dir  = $::wordpress::install_dir,
){

  validate_absolute_path($install_dir)
  validate_string($zip_url, $wp_owner, $wp_group, $zip_filename)

  $plugin_dir = "${install_dir}/wp-content/plugins"


  # Download and Extract
  exec { "download-wordpress-plugin-${name}":
    cwd     => $plugin_dir,
    user    => $wp_owner,
    path    => ['/bin','/sbin','/usr/bin','/usr/sbin'],
    command => "/usr/bin/wget -nc ${zip_url}",
    creates => "${plugin_dir}/${zip_filename}",
    require => File[$install_dir],
  } ->
  exec { "extract-wordpress-plugin-${name}":
    cwd     => $plugin_dir,
    user    => $wp_owner,
    path    => ['/bin','/sbin','/usr/bin','/usr/sbin'],
    command => "unzip ./${zip_filename}",
    creates => "${plugin_dir_real}/${name}",
    require => Package['unzip'],
  }
}
