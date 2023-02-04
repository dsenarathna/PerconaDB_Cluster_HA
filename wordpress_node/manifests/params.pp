class wordpress_node::params {
  if ($::lsbdistcodename == 'xenial')  {
    $mysql_version = '5.7'
  }
  }
