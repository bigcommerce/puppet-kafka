# == Class: kafka::connect::config
#
# This private class is meant to be called from `kafka::connect`.
# It manages the connect config files
#
class kafka::connect::config(
  $config          = $kafka::connect::config,
  $config_defaults = $kafka::connect::config_defaults,
  $install_dir     = $kafka::connect::install_dir,
  $service_restart = $kafka::connect::service_restart,
  $service_install = $kafka::connect::service_install,
  $mode            = $kafka::connect::mode,
) {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if ! ($mode in ['distributed', 'standalone']) {
    fail('${connect_mode} must be one of "distributed" or "standalone"')
  }

  $connect_config = deep_merge($config_defaults, $config)
  $service_name = "kafka-connect-${mode}"

  if $service_install {
    $config_notify = $service_restart ? {
      true  => Service[$service_name],
      false => undef
    }
  } else {
    $config_notify = undef
  }

  file { "/opt/kafka/config/connect-${mode}.properties":
    ensure  => present,
    owner   => 'kafka',
    group   => 'kafka',
    mode    => '0644',
    content => template('kafka/connect.properties.erb'),
    notify  => $config_notify,
    require => File['/opt/kafka/config'],
  }
}
