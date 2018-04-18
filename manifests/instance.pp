# == Definition: wordpress::instance
#
# This module manages wordpress
#
# === Parameters
#
# [*install_dir*]
#   Specifies the directory into which wordpress should be installed. Default:
#   /opt/wordpress
#
# [*install_url*]
#   Specifies the url from which the wordpress tarball should be downloaded.
#   Default: https://wordpress.org
#
# [*version*]
#   Specifies the version of wordpress to install. Default: 4.8.1
#
# [*create_db*]
#   Specifies whether to create the db or not. Default: true
#
# [*create_db_user*]
#   Specifies whether to create the db user or not. Default: true
#
# [*db_name*]
#   Specifies the database name which the wordpress module should be configured
#   to use. Required.
#
# [*db_host*]
#   Specifies the database host to connect to. Default: localhost
#
# [*db_user*]
#   Specifies the database user. Required.
#
# [*db_password*]
#   Specifies the database user's password in plaintext. Default: password
#
# [*wp_owner*]
#   Specifies the owner of the wordpress files. Default: root
#
# [*wp_group*]
#   Specifies the group of the wordpress files. Default: 0 (*BSD/Darwin
#   compatible GID)
#
# [*wp_config_owner*]
#   Specifies the other of the wordpress wp-config.php.  You must ensure this
#   user exists as this module does not attempt to create it if missing.
#   Default: $wp_owner value.
#
# [*wp_config_group*]
#   Specifies the group of the wordpress wp-config.php. Default: $pw_group value.
#
# [*wp_config_mode*]
#   Specifies the file permissions of wp-config.php. Default: 0644
#
# [*manage_wp_content*]
#   Specifies whether the wp-content directory should be managed. Default: `false`.
#
# [*wp_content_owner*]
#   Specifies the owner of the wordpress wp-content directory. Default: $wp_owner value.
#
# [*wp_content_group*]
#   Specifies the group of the wordpress wp-content directory. Default: $wp_group value.
#
# [*wp_content_recurse*]
#   Specifies whether to recursively manage the permissions on wp-content. Default: true
#
# [*wp_lang*]
#   WordPress Localized Language. Default: ''
#
#
# [*wp_plugin_dir*]
#   WordPress Plugin Directory. Full path, no trailing slash. Default: WordPress Default
#
# [*wp_additional_config*]
#   Specifies a template to include near the end of the wp-config.php file to add additional options. Default: ''
#
# [*wp_table_prefix*]
#   Specifies the database table prefix. Default: wp_
#
# [*wp_proxy_host*]
#   Specifies a Hostname or IP of a proxy server for Wordpress to use to install updates, plugins, etc. Default: ''
#
# [*wp_proxy_port*]
#   Specifies the port to use with the proxy host.  Default: ''
#
# [*wp_site_url*]
#  If your WordPress server is behind a proxy, you wish to override the value in the wp_options table or reduce the number of database calls when loading, you might need to set the WP_SITEURL with this parameter.  Default: `undef`
#
# [*wp_home*]
#  If you wish to override the value in the wp_options table or reduce the number of database calls when loading, you might need to set the WP_HOME with this parameter.  Default: `undef`
#
# [*wp_multisite*]
#   Specifies whether to enable the multisite feature. Requires `wp_site_domain` to also be passed. Default: `false`
#
# [*wp_site_domain*]
#   Specifies the `DOMAIN_CURRENT_SITE` value that will be used when configuring multisite. Typically this is the address of the main wordpress instance.  Default: ''
#
# === Requires
#
# === Examples
#
define wordpress::instance (
  $db_name,
  $db_user,
  $install_dir          = $title,
  $install_url          = 'https://wordpress.org',
  $version              = '4.8.1',
  $create_db            = true,
  $create_db_user       = true,
  $db_host              = 'localhost',
  $db_password          = 'password',
  $wp_owner             = 'root',
  $wp_group             = '0',
  $wp_config_owner      = undef,
  $wp_config_group      = undef,
  $wp_config_mode       = '0644',
  $manage_wp_content    = false,
  $wp_content_owner     = undef,
  $wp_content_group     = undef,
  $wp_content_recurse   = true,
  $wp_lang              = '',
  $wp_config_content    = undef,
  $wp_plugin_dir        = 'DEFAULT',
  $wp_additional_config = 'DEFAULT',
  $wp_table_prefix      = 'wp_',
  $wp_proxy_host        = '',
  $wp_proxy_port        = '',
  $wp_site_url          = undef,
  $wp_home              = undef,
  $wp_multisite         = false,
  $wp_site_domain       = '',
  $wp_debug             = false,
  $wp_debug_log         = false,
  $wp_debug_display     = false,
) {
  $_wp_config_owner = pick($wp_config_owner, $wp_owner)
  $_wp_config_group = pick($wp_config_group, $wp_group)
  $_wp_content_owner = pick($wp_content_owner, $wp_owner)
  $_wp_content_group = pick($wp_content_group, $wp_group)
  wordpress::instance::app { $install_dir:
    install_dir          => $install_dir,
    install_url          => $install_url,
    version              => $version,
    db_name              => $db_name,
    db_host              => $db_host,
    db_user              => $db_user,
    db_password          => $db_password,
    wp_owner             => $wp_owner,
    wp_group             => $wp_group,
    wp_config_owner      => $_wp_config_owner,
    wp_config_group      => $_wp_config_group,
    wp_config_mode       => $wp_config_mode,
    manage_wp_content    => $manage_wp_content,
    wp_content_owner     => $_wp_content_owner,
    wp_content_group     => $_wp_content_group,
    wp_content_recurse   => $wp_content_recurse,
    wp_lang              => $wp_lang,
    wp_config_content    => $wp_config_content,
    wp_plugin_dir        => $wp_plugin_dir,
    wp_additional_config => $wp_additional_config,
    wp_table_prefix      => $wp_table_prefix,
    wp_proxy_host        => $wp_proxy_host,
    wp_proxy_port        => $wp_proxy_port,
    wp_site_url          => $wp_site_url,
    wp_home              => $wp_home,
    wp_multisite         => $wp_multisite,
    wp_site_domain       => $wp_site_domain,
    wp_debug             => $wp_debug,
    wp_debug_log         => $wp_debug_log,
    wp_debug_display     => $wp_debug_display,
  }

  wordpress::instance::db { "${db_host}/${db_name}":
    create_db      => $create_db,
    create_db_user => $create_db_user,
    db_name        => $db_name,
    db_host        => $db_host,
    db_user        => $db_user,
    db_password    => $db_password,
  }
}
