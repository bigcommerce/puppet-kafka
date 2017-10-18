# == Class: kafka::connect
#
# This class will install kafka with the connect role.
#
# === Requirements/Dependencies
#
# Currently requires the puppetlabs/stdlib module on the Puppet Forge in
# order to validate much of the the provided configuration.
#
# === Parameters
#
# [*version*]
# The version of kafka that should be installed.
#
# [*scala_version*]
# The scala version what kafka was built with.
#
# [*install_dir*]
# The directory to install kafka to.
#
# [*mirror_url*]
# The url where the kafka is downloaded from.
#
# [*config*]
# A hash of the configuration options.
#
# [*install_java*]
# Install java if it's not already installed.
#
# [*package_dir*]
# The directory to install kafka.
#
# [*service_restart*]
# Boolean, if the configuration files should trigger a service restart
#
# === Examples
#
# Create a single connect instance which bootstraps from a local kafka instance.
#
# class { 'kafka::connect':
#  config => { 'bootstrap.servers' => 'localhost:9092' }
# }
#
class kafka::connect (
  $version                    = $kafka::params::version,
  $scala_version              = $kafka::params::scala_version,
  $install_dir                = $kafka::params::install_dir,
  $mirror_url                 = $kafka::params::mirror_url,
  $config                     = {},
  $config_defaults            = $kafka::params::connect_config_defaults,
  $install_java               = $kafka::params::install_java,
  $package_dir                = $kafka::params::package_dir,
  $service_install            = $kafka::params::connect_service_install,
  $service_ensure             = $kafka::params::connect_service_ensure,
  $service_restart            = $kafka::params::service_restart,
  $service_requires_zookeeper = $kafka::params::service_requires_zookeeper,
  $jmx_opts                   = $kafka::params::connect_jmx_opts,
  $heap_opts                  = $kafka::params::connect_heap_opts,
  $log4j_opts                 = $kafka::params::connect_log4j_opts,
  $opts                       = $kafka::params::connect_opts,
  $group_id                   = $kafka::params::group_id,
  $user_id                    = $kafka::params::user_id,
  $mode                       = $kafka::params::connect_mode,
  $connector_config_files     = [],
) inherits kafka::params {

  validate_re($::osfamily, 'RedHat|Debian\b', "${::operatingsystem} not supported")
  validate_re($mirror_url, $kafka::params::mirror_url_regex, "${mirror_url} is not a valid url")
  validate_hash($config)
  validate_bool($install_java)
  validate_absolute_path($package_dir)
  validate_bool($service_install)
  validate_re($service_ensure, '^(running|stopped)$')
  validate_bool($service_restart)
  validate_array($connector_config_files)

  class { '::kafka::connect::install': } ->
  class { '::kafka::connect::config': } ->
  class { '::kafka::connect::service': } ->
  Class['kafka::connect']
}
