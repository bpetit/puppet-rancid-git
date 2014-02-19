class rancid_git {

  Package { ensure => "installed" }

  user { 'rancid':
    name   => 'rancid',
    ensure => present,
    home   => '/var/lib/rancid',
    shell  => '/bin/bash',
  }

  file { '/etc/rancid/rancid.conf':
    path    => '/etc/rancid/rancid.conf',
    ensure  => present,
    owner   => 'root',
    source  => 'puppet:///modules/rancid_git/rancid.conf',
  }

  file { '/usr/lib/rancid/bin/control_rancid':
    path    => '/usr/lib/rancid/bin/control_rancid',
    ensure  => present,
    owner   => 'root',
    source  => 'puppet:///modules/rancid_git/control_rancid.PATCHED',
    mode    => 0755,
  }

  file { '/usr/lib/rancid/bin/jlogin':
    path   => '/usr/lib/rancid/bin/jlogin',
    ensure => present,
    owner  => 'root',
    source => 'puppet:///modules/rancid_git/jlogin.PATCHED',
    mode   => 0755,
  }

  file { '/var/lib/rancid/.cloginrc':
    path    => '/var/lib/rancid/.cloginrc',
    ensure  => present,
    mode    => 0600,
    owner   => 'rancid',
    source  => 'puppet:///modules/rancid_git/cloginrc.SAMPLE',
    require => User['rancid'],
  }

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
      Package ['exim4']
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
