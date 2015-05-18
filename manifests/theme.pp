# == Define: wordpress::theme
#
# Installs a zipped wordpress theme.
#
# This is largely based on plugin.pp
#
# === Actions
#
#  - install wordpress theme from zip file
#
# === Parameters
#
# The name of the define must be the name of the theme (directory in the zip file)
#
# [*tar_url*]
#   String. URL to the zip file to download
#
# [*tar_filename*]
#   String. The name of the zip file.
#
# [*strip_components*]
#   Int. The number of segment prefixes to strip from zip contents.
#   Default: 0
#
# [*creates*]
#   String. A path relative to the theme directory to confirm is extracted from the theme zip.
#   Default: 'index.php'
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
define wordpress::theme (
  $tar_url,
  $tar_filename,
  $strip_components = 0,
  $creates          = 'index.php',
  $wp_owner         = $::wordpress::wp_owner,
  $wp_group         = $::wordpress::wp_group,
  $install_dir      = $::wordpress::install_dir,
){

  validate_absolute_path($install_dir)
  validate_string($zip_url, $wp_owner, $wp_group, $zip_filename)

  $theme_root_dir = "${install_dir}/wp-content/themes"
  $theme_dir = "${theme_root_dir}/${name}"

  file { $theme_dir:
    ensure  => directory,
    mode    => '0644',
    owner   => $wp_owner,
    group   => $wp_group,
    require => File[$install_dir],
  }

  # Download and Extract
  exec { "download-wordpress-theme-${name}":
    cwd     => $theme_dir,
    user    => $wp_owner,
    path    => ['/bin','/sbin','/usr/bin','/usr/sbin'],
    command => "/usr/bin/curl -o ${tar_filename} -L ${tar_url}",
    creates => "${theme_dir}/${tar_filename}",
    require => File[$theme_dir],
  } ->
  exec { "extract-wordpress-theme-${name}":
    cwd     => $theme_dir,
    user    => $wp_owner,
    path    => ['/bin','/sbin','/usr/bin','/usr/sbin'],
    command => "tar --strip-components=${strip_components} -xf ./${tar_filename}",
    creates => "${theme_dir}/${creates}",
  }
}
