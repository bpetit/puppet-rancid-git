include stdlib

class rancid_git {

  $module_path = 'puppet:///modules/rancid_git/'
  $bin_path = '/usr/lib/rancid/bin/'
  $etc_path = '/etc/rancid/'
  $home_path = '/var/lib/rancid/'

  Package { ensure => "installed" }

  user { 'rancid':
    name   => 'rancid',
    ensure => present,
    home   => '/var/lib/rancid',
    shell  => '/bin/bash',
  }

  $files = {
    "${etc_path}rancid.conf" => {
      'path' => "${etc_path}rancid.conf" ,
      'source' => "${module_path}rancid.conf",
      'owner' => 'root',
    },
    "${bin_path}control_rancid" => {
      'path' => "${bin_path}control_rancid",
      'source' => "${module_path}control_rancid.PATCHED",
      'mode' => 0755
    },
    "${bin_path}jlogin" => {
      'source' => "${module_path}jlogin.PATCHED",
      'path' => "${bin_path}jlogin",
      'mode' => 0755
    },
    "${home_path}.cloginrc" => {
      'source' => "${module_path}cloginrc.SAMPLE",
      'path' => "${home_path}.cloginrc",
      'mode' => 0600,
      'owner' => 'rancid',
      'require' => User['rancid'],
    },
  }

  create_resources(file,$files)

  #User['rancid'] -> File["${home_path}.cloginrc"]

  $debpath = '/var/tmp/rancid-git_2.3.8-1_amd64.deb'

  package { 'rancid-git':
    name        => 'rancid-git',
    ensure      => installed,
    source      => "$debpath",
    provider    => 'dpkg',
    before      => [
      File['/etc/rancid/rancid.conf'], File['/usr/lib/rancid/bin/control_rancid'],
      File['/usr/lib/rancid/bin/jlogin'], File['/var/lib/rancid/.cloginrc']
    ],
    require => [
      File["$debpath"], Package['expect'], Package['git'], Package['telnet'],
      Package['exim4']
    ],
  }

  $enhancers = [ "expect", "git", "telnet", "exim4" ]

  package { $enhancers: }

  file { "$debpath":
    path    => "$debpath",
    ensure  => present,
    source  => 'puppet:///modules/rancid_git/rancid-git_2.3.8-1_amd64.deb',
  }

  cron { 'rancid-git':
    command => '/usr/lib/rancid/bin/rancid-run',
    user    => 'rancid',
    hour    => 3,
    minute  => 0,
    require => User['rancid'],
  }
}
