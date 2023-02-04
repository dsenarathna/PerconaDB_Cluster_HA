# Class: PerconaLB
#
# This class installs PerconaLB
#
# Parameters:
#
# Actions:
#   - Install Nginx
#   - Manage Nginx service
#
# Requires:
#
# Sample Usage:
#

class wordpress_lb  {


  package {

        'nginx':
          ensure => installed;

         }

          service {
    'nginx':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true;
                  }




    file {
    '/etc/nginx':
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0755';
         }
		 
		 if $::fqdn == 'wordpress-lb-01.us-wdc.ignitionone.com' {
			file {
    '/etc/nginx/sites-available/default':
      owner  => 'root',
      group  => 'root',
      mode    => '0644',
      content => template("${::puppet_dir_master}/systems/_LINUX_/etc/percona-xtradb-cluster.conf.d/default"),
      notify  => Service['nginx'];

        }}

		if $::fqdn == 'curatedby-lb-01.us-wdc.ignitionone.com' {
			file {
    '/etc/nginx/sites-available/default':
      owner  => 'root',
      group  => 'root',
      mode    => '0644',
      content => template("${::puppet_dir_master}/systems/_LINUX_/etc/percona-xtradb-cluster.conf.d/default1"),
      notify  => Service['nginx'];

        }}

		 




      }


