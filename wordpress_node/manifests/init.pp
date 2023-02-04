# Class: PerconaDB node
#
# This class installs PerconaDB XtraDB Cluster
#
# Parameters:
#
# Actions:
#   - Install PerconaDB
#   - Manage MYSQL service
#
# Requires:
#
# Sample Usage:
#

class wordpress_node {


  package {
        'percona-xtradb-cluster-server':
          ensure => installed;
        'nginx':
          ensure => installed;
        'php7.0':
          ensure => installed;
        'php7.0-curl':
          ensure => installed;
        'php7.0-gd':
          ensure => installed;
        'php7.0-intl':
          ensure => installed;
        'php7.0-mysql':
          ensure => installed;
        'php-memcached':
          ensure => installed;
        'php7.0-mbstring':
          ensure => installed;
        'php7.0-zip':
          ensure => installed;
        'php7.0-xml':
          ensure => installed;
        'php7.0-mcrypt':
          ensure => installed;
        'unzip':
          ensure => installed;
        'unison':
          ensure => installed;
        'git':
          ensure => installed;
       # 'openssh-server':
       #   ensure => installed;
         }

          service {
    'mysql':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true;

   'nginx':
     ensure     => running,
     enable     => true,
     hasrestart => true,
     hasstatus  => true;
              }


exec { 'wget https://repo.percona.com/apt/percona-release_0.1-4.$(lsb_release -sc)_all.deb':
  cwd     => '/var/tmp',
  path     => '/usr/bin:/usr/sbin:/bin',
  onlyif  => "test `dpkg -l | grep percona-release | wc -l ` -eq 0"

    }
package { "percona-release":
 provider => dpkg,
 ensure   => latest,
 source   => "/var/tmp/percona-release_0.1-4.xenial_all.deb"
       }

exec {
    'apt_update2':
      command     => '/usr/bin/apt-get update',
      refreshonly => true;
     }

exec {
    'apt_upgrade2':
      command     => '/usr/bin/apt-get upgrade',
      refreshonly => true;
    }


exec { 'add-user':
path => '/usr/bin:/usr/sbin:/bin',
unless => "/usr/bin/mysql -usstuser -p<<InsertPasswordHere>>",
command => "mysql -u root -e \"CREATE USER 'sstuser'@'localhost' IDENTIFIED BY '*LKHYTDTYDOPIJP876HGC7FGDXRJYVUYUU'; FLUSH PRIVILEGES;\"",
timeout => '60',
require => Service['mysql'];
    }

exec { 'grant-priviledges':
path => '/usr/bin:/usr/sbin:/bin',
command => "mysql -u root -e \"GRANT RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT ON *.* TO 'sstuser'@'localhost'; FLUSH PRIVILEGES;\"",
timeout => '60',
require => Service['mysql'];
     }


    file {
    '/etc/mysql':
      ensure  => directory,
      owner   => 'root',
      group   => 'mysql',
      mode    => '0755';

   '/etc/mysql/percona-xtradb-cluster.conf.d/':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755';
	  
	'/etc/nginx/nginx.conf':
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      content => template("${::puppet_dir_master}/systems/_LINUX_/etc/percona-xtradb-cluster.conf.d/nginx.conf"),
      notify  => Service['nginx'];

	'/etc/nginx/sites-available/wpintense.cluster.conf':
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      content => template("${::puppet_dir_master}/systems/_LINUX_/etc/percona-xtradb-cluster.conf.d/wpintense.cluster.conf"),
      notify  => Service['nginx'];
	  
        }


exec { 'configure_nginx':
 path     => '/usr/bin:/usr/sbin:/bin',
 command => 'git clone https://github.com/dhilditch/wordpress-cluster /root/wordpress-cluster/',
 creates => '/root/wordpress-cluster/'

     }

exec { 'copy_nginx_folder':
 path     => '/usr/bin:/usr/sbin:/bin',
 command => 'cp /root/wordpress-cluster/etc/nginx/* -R /etc/nginx/',
 creates => '/etc/nginx/snippets/acme-challenge.conf'

     }

exec { 'link_sites-available':
 path     => '/usr/bin:/usr/sbin:/bin',
 command => 'ln -s /etc/nginx/sites-available/wpintense.cluster.conf /etc/nginx/sites-enabled/',
 creates => '/etc/nginx/sites-enabled/wpintense.cluster.conf'
     }

exec { 'creating_cache':
 path     => '/usr/bin:/usr/sbin:/bin',
 command => 'mkdir /sites/wpicluster/cache -p',
 creates => '/sites/wpicluster/cache'

    }

exec { 'resrart_nginx':
 path     => '/usr/bin:/usr/sbin:/bin',
 command => 'service nginx restart'


    }
   }


