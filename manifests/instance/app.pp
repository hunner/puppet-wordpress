define wordpress::instance::app (
  Stdlib::Absolutepath $install_dir,
  String $install_url,
  String $version,
  String $db_name,
  String $db_host,
  String $db_user,
  String $db_password,
  String $wp_owner,
  String $wp_group,
  String $wp_config_owner,
  String $wp_config_group,
  String $wp_config_mode,
  Boolean $manage_wp_content,
  String $wp_content_owner,
  String $wp_content_group,
  Boolean $wp_content_recurse,
  String $wp_lang,
  Optional[String] $wp_config_content,
  String $wp_plugin_dir,
  String $wp_additional_config,
  String $wp_table_prefix,
  String $wp_proxy_host,
  String $wp_proxy_port,
  Optional[String] $wp_site_url,
  Boolean $wp_multisite,
  String $wp_site_domain,
  Boolean $wp_debug,
  Boolean $wp_debug_log,
  Boolean $wp_debug_display,
) {
  if $wp_config_content and ($wp_lang or $wp_debug or $wp_debug_log or $wp_debug_display or $wp_proxy_host or $wp_proxy_port or $wp_multisite or $wp_site_domain) {
    warning('When $wp_config_content is set, the following parameters are ignored: $wp_table_prefix, $wp_lang, $wp_debug, $wp_debug_log, $wp_debug_display, $wp_plugin_dir, $wp_proxy_host, $wp_proxy_port, $wp_multisite, $wp_site_domain, $wp_additional_config')
  }

  if $wp_multisite and ! $wp_site_domain {
    fail('wordpress class requires `wp_site_domain` parameter when `wp_multisite` is true')
  }

  if $wp_debug_log and ! $wp_debug {
    fail('wordpress class requires `wp_debug` parameter to be true, when `wp_debug_log` is true')
  }

  if $wp_debug_display and ! $wp_debug {
    fail('wordpress class requires `wp_debug` parameter to be true, when `wp_debug_display` is true')
  }

  if $wp_proxy_host and !empty($wp_proxy_host) {
    $exec_environment = [
      "http_proxy=http://${wp_proxy_host}:${wp_proxy_port}",
      "https_proxy=http://${wp_proxy_host}:${wp_proxy_port}",
    ]
  } else {
    $exec_environment = []
  }

  ## Resource defaults
  File {
    owner  => $wp_owner,
    group  => $wp_group,
    mode   => '0644',
  }
  Exec {
    path        => ['/bin','/sbin','/usr/bin','/usr/sbin'],
    cwd         => $install_dir,
    environment => $exec_environment,
    logoutput   => 'on_failure',
  }

  ## Installation directory
  if ! defined(File[$install_dir]) {
    file { $install_dir:
      ensure  => directory,
      recurse => true,
    }
  } else {
    notice("Warning: cannot manage the permissions of ${install_dir}, as another resource (perhaps apache::vhost?) is managing it.")
  }

  ## tar.gz. file name lang-aware
  if $wp_lang and !empty($wp_lang) {
    $install_file_name = "wordpress-${version}-${wp_lang}.tar.gz"
  } else {
    $install_file_name = "wordpress-${version}.tar.gz"
  }

  ## Download and extract
  exec { "Download wordpress ${install_url}/wordpress-${version}.tar.gz to ${install_dir}":
    command => "curl -L -O ${install_url}/${install_file_name}",
    creates => "${install_dir}/${install_file_name}",
    require => File[$install_dir],
    user    => $wp_owner,
    group   => $wp_group,
  }
  -> exec { "Extract wordpress ${install_dir}":
    command => "tar zxvf ./${install_file_name} --strip-components=1",
    creates => "${install_dir}/license.txt",
    user    => $wp_owner,
    group   => $wp_group,
  }
  ~> exec { "Change ownership ${install_dir}":
    command     => "chown -R ${wp_owner}:${wp_group} ${install_dir}",
    refreshonly => true,
    user        => $wp_owner,
    group       => $wp_group,
  }

  if $manage_wp_content {
    file { "${install_dir}/wp-content":
      ensure  => directory,
      owner   => $wp_content_owner,
      group   => $wp_content_group,
      recurse => $wp_content_recurse,
      require => Exec["Extract wordpress ${install_dir}"],
    }
  }

  ## Configure wordpress
  #
  concat { "${install_dir}/wp-config.php":
    owner   => $wp_config_owner,
    group   => $wp_config_group,
    mode    => $wp_config_mode,
    require => Exec["Extract wordpress ${install_dir}"],
  }
  if $wp_config_content {
    concat::fragment { "${install_dir}/wp-config.php body":
      target  => "${install_dir}/wp-config.php",
      content => $wp_config_content,
      order   => '20',
    }
  } else {
    # Template uses no variables
    file { "${install_dir}/wp-keysalts.php":
      ensure  => present,
      content => template('wordpress/wp-keysalts.php.erb'),
      replace => false,
      require => Exec["Extract wordpress ${install_dir}"],
    }
    concat::fragment { "${install_dir}/wp-config.php keysalts":
      target  => "${install_dir}/wp-config.php",
      source  => "${install_dir}/wp-keysalts.php",
      order   => '10',
      require => File["${install_dir}/wp-keysalts.php"],
    }
    # Template uses:
    # - $db_name
    # - $db_user
    # - $db_password
    # - $db_host
    # - $wp_table_prefix
    # - $wp_lang
    # - $wp_plugin_dir
    # - $wp_proxy_host
    # - $wp_proxy_port
    # - $wp_site_url
    # - $wp_multisite
    # - $wp_site_domain
    # - $wp_additional_config
    # - $wp_debug
    # - $wp_debug_log
    # - $wp_debug_display
    concat::fragment { "${install_dir}/wp-config.php body":
      target  => "${install_dir}/wp-config.php",
      content => template('wordpress/wp-config.php.erb'),
      order   => '20',
    }
  }
}
