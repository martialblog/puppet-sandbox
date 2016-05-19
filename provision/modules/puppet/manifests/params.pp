# == Class: puppet::params
#
# This class manages the Puppet parameters.
#
# === Parameters
#
# === Actions
#
# === Requires
#
# === Sample Usage
#
# This class file is not called directly.
#
class puppet::params {

  $client_ensure = 'latest'
  $server_ensure = 'latest'

  # Puppet 3:
  #$client_package_name = 'puppet'
  # Puppet 4:
  $client_package_name = 'puppet-agent'
  $client_service_name = 'puppet'

  $server_service_name = 'puppetserver'

  case $::osfamily {
    'redhat': {
      $server_package_name = 'puppet-server'
    }
    'debian': {
      # Puppet 3:
      #$server_package_name = 'puppetmaster'
      # Puppet 4:
      $server_package_name = 'puppetserver'
    }
    default: {
      fail("Module 'puppet' is not currently supported by Puppet Sandbox on ${::operatingsystem}")
    }
  }

}
