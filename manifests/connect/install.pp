# == Class: kafka::connect::install
#
# This private class is meant to be called from `kafka::connect`.
# It downloads the package and installs it.
#
class kafka::connect::install {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $version = $kafka::version
  if $version and versioncmp($version, '0.9.0.0') < 0 {
    fail('[Connect] Kafka Connect requires version 0.9.0.0 or greater')
  }

  if !defined(Class['::kafka']) {
    class { '::kafka':
      version       => $kafka::broker::version,
      scala_version => $kafka::broker::scala_version,
      install_dir   => $kafka::broker::install_dir,
      mirror_url    => $kafka::broker::mirror_url,
      install_java  => $kafka::broker::install_java,
      package_dir   => $kafka::broker::package_dir,
      group_id      => $kafka::broker::group_id,
      user_id       => $kafka::broker::user_id,
    }
  }
}
