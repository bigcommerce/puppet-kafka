# == Class: kafka::connect::service
#
# This private class is meant to be called from `kafka::connect`.
# It manages the kafka service
#
class kafka::connect::service(
  $service_install            = $kafka::connect::service_install,
  $service_ensure             = $kafka::connect::service_ensure,
  $service_requires_zookeeper = $kafka::connect::service_requires_zookeeper,
  $jmx_opts                   = $kafka::connect::jmx_opts,
  $log4j_opts                 = $kafka::connect::log4j_opts,
  $heap_opts                  = $kafka::connect::heap_opts,
  $opts                       = $kafka::connect::opts,
  $mode                       = $kafka::connect::mode,
  $connector_config_files     = $kafka::connect::connector_config_files,
) {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # There's a lot more work to do here. Should probably wrap the unit/init file
  # creation in a create_resources call.
  #
  # For now, only really support distributed mode
  if $mode == 'standalone' {
    fail('standalone mode not supported yet')

    if empty($standalone_connector_configs) {
      fail('must specify at least one connector configuration file in standalone mode')
    }
  }

  $service_name = "kafka-connect-${mode}"

  if $service_install {
    if $::service_provider == 'systemd' {
      include ::systemd

      file { "${service_name}.service":
        ensure  => file,
        path    => "/etc/systemd/system/${service_name}.service",
        mode    => '0644',
        content => template('kafka/unit.erb'),
      }

      file { "/etc/init.d/${service_name}":
        ensure => absent,
      }

      File["${service_name}.service"] ~>
      Exec['systemctl-daemon-reload'] ->
      Service[$service_name]

    } else {
      file { "${service_name}.service":
        ensure  => file,
        path    => "/etc/init.d/${service_name}",
        mode    => '0755',
        content => template('kafka/init.erb'),
        before  => Service[$service_name],
      }
    }

    service { $service_name:
      ensure     => $service_ensure,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  } else {
    debug('Skipping service install')
  }
}
