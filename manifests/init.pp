class rancid_git (
) {
  $module_path = 'puppet:///modules/rancid_git/',
  $bin_path = '/usr/lib/rancid/bin/',
  $etc_path = '/etc/rancid/',
  $home_path = '/var/lib/rancid/',
  $deb_file = 'rancid-git_2.3.8-1_amd64.deb',
  $deb_path = "/var/tmp/${deb_file}",
  $rancidconf_path = "${etc_path}rancid.conf",
  $controlrancid_path = "${bin_path}control_rancid",
  $jlogin_path = "${bin_path}jlogin",
  $cloginrc_path = "${home_path}.cloginrc"

  include stdlib

  user { 'rancid':
    name   => 'rancid',
    ensure => present,
    home   => '/var/lib/rancid',
    shell  => '/bin/bash',
  }

  File { ensure => file }

  $files = {
    "${rancidconf_path}" => {
      'path' => "${etc_path}rancid.conf" ,
      'source' => "${module_path}rancid.conf",
      'owner' => 'root',
    },
    "${controlrancid_path}" => {
      'path' => "${bin_path}control_rancid",
      'source' => "${module_path}control_rancid.PATCHED",
      'mode' => 0755
    },
    "${jlogin_path}" => {
      'source' => "${module_path}jlogin.PATCHED",
      'path' => "${bin_path}jlogin",
      'mode' => 0755
    },
    "${cloginrc_path}" => {
      'source' => "${module_path}cloginrc.SAMPLE",
      'path' => "${home_path}.cloginrc",
      'mode' => 0600,
      'owner' => 'rancid',
    },
    "${deb_path}" => {
      path => "${deb_path}",
      source => "${module_path}${deb_file}"
    }
  }

  create_resources(file,$files)

  User['rancid'] -> File["${cloginrc_path}"]

  package { 'rancid-git':
    name        => 'rancid-git',
    ensure      => installed,
    source      => "${deb_path}",
    provider    => 'dpkg',
    before      => [
      File["${cloginrc_path}"], File["${controlrancid_path}"],
      File["${jlogin_path}"], File["${rancidconf_path}"]
    ],
    require => [
      File["${deb_path}"], Package['expect', 'git', 'telnet', 'exim4']
    ],
  }

  package { ['expect', 'git', 'telnet', 'exim4']:
    ensure => installed,
  }

  cron { 'rancid-git':
    command => '/usr/lib/rancid/bin/rancid-run',
    user    => 'rancid',
    hour    => 3,
    minute  => 0,
    require => User['rancid'],
  }
}
