# == Class: puppet
#
# This class installs and manages the Puppet client daemon.
#
# === Parameters
#
# [*ensure*]
#   What state the package should be in. Defaults to +latest+. Valid values are
#   +present+ (also called +installed+), +absent+, +purged+, +held+, +latest+,
#   or a specific version number.
#
# === Actions
#
# - Install Puppet client package
# - Ensure puppet-agent daemon is running
#
# === Requires
#
# === Sample Usage
#
#   class { 'puppet': }
#
#   class { 'puppet':
#     ensure => '2.6.8-0.5.el5',
#   }
#
class puppet(
  $ensure = $puppet::params::client_ensure,
  $package_name = $puppet::params::client_package_name,
  $service_name = $puppet::params::client_service_name,
) inherits puppet::params {

  package { $package_name:
    ensure => $ensure,
  }

  # required to start client agent on ubuntu
  exec { 'start_puppet':
    command => '/bin/sed -i /etc/default/puppet -e "s/START=no/START=yes/"',
    onlyif  => '/usr/bin/test -f /etc/default/puppet',
    require => Package[ $package_name ],
    before  => Service[ $service_name ],
  }

  # templatedir is deprecated
  exec { 'remove_templatedir_setting':
    command => '/bin/sed -i /etc/puppet/puppet.conf -e "/templatedir=/d"',
    onlyif  => '/bin/grep templatedir /etc/puppet/puppet.conf',
    require => Package[ $package_name ],
    before  => Service[ $service_name ],
  }

  service { $service_name:
    ensure  => running,
    enable  => true,
    require => Package[ $package_name ],
  }

}
