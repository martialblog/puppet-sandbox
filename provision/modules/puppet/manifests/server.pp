# == Class: puppet::server
#
# This class installs and manages the Puppet server daemon.
#
# === Parameters
#
# [*ensure*]
#   What state the package should be in. Defaults to +latest+. Valid values are
#   +present+ (also called +installed+), +absent+, +purged+, +held+, +latest+,
#   or a specific version number.
#
# [*package_name*]
#   The name of the package on the relevant distribution. Default is set by
#   Class['puppet::params'].
#
# === Actions
#
# - Install Puppet server package
# - Install puppet-lint gem
# - Configure Puppet to autosign puppet client certificate requests
# - Configure Puppet to use nodes.pp and modules from /vagrant directory
# - Ensure puppet-master daemon is running
#
# === Requires
#
# === Sample Usage
#
#   class { 'puppet::server': }
#
#   class { 'puppet::server':
#     ensure => 'puppet-2.7.17-1.el6',
#   }
#
class puppet::server(
  $ensure       = $puppet::params::server_ensure,
  $package_name = $puppet::params::server_package_name,
  $service_name = $puppet::params::server_service_name,
) inherits puppet::params {

  # required to prevent syslog error on ubuntu
  # https://bugs.launchpad.net/ubuntu/+source/puppet/+bug/564861
  file { [ '/etc/puppet', '/etc/puppet/files' ]:
    ensure => directory,
    before => Package[ $package_name ],
  }

  package { $package_name:
    ensure => $ensure,
    name   => $package_name,
  }

  package { 'puppet-lint':
    ensure   => latest,
    provider => gem,
  }

  exec { 'puppetserver_java_args':
    command => "/bin/sed -i 's/-Xms2g -Xmx2g/-Xms512m -Xmx512m/g' /etc/default/puppetserver",
    onlyif  => '/usr/bin/test -f /etc/default/puppetserver',
    require => Package[ $package_name ],
    before  => Service[ $service_name ],
  }

  file { 'puppet.conf':
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0644',
    source  => 'puppet:///modules/puppet/puppet.conf',
    require => Package[ $package_name ],
    notify  => Service[ $service_name ],
  }

file { 'site.pp':
    path    => '/etc/puppetlabs/code/environments/production/manifests/site.pp',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0644',
    source  => 'puppet:///modules/puppet/site.pp',
    require => Package[ $package_name ],
  }

  file { 'autosign.conf':
    path    => '/etc/puppet/autosign.conf',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0644',
    content => '*',
    require => Package[ $package_name ],
  }

  file { '/etc/puppetlabs/code/environments/production/manifests/nodes.pp':
    ensure  => link,
    target  => '/vagrant/nodes.pp',
    require => Package[ $package_name ],
  }

  # initialize a template file then ignore
  file { '/vagrant/nodes.pp':
    ensure  => present,
    replace => false,
    source  => 'puppet:///modules/puppet/nodes.pp',
  }

  service { $service_name:
    ensure  => running,
    enable  => true,
    require => Package[ $package_name ],
  }

}
