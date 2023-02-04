class wordpress-admin::params {
  if ($::lsbdistcodename == 'xenial')  {
    $mysql_version = '5.7'
  }
  }
