class rancid_git {

  file { '/etc/rancid/rancid.conf':
    path   => '/etc/rancid/rancid.conf',
    ensure => present,
    owner  => 'rancid',
    source => 'puppet:///modules/rancid_git/rancid.conf',
  }

  file { '/usr/lib/rancid/bin/control_rancid':
    path   => '/usr/lib/rancid/bin/control_rancid',
    ensure => present,
    owner  => 'rancid',
    source => 'puppet:///modules/rancid_git/control_rancid.PATCHED',
  }

  file { '/usr/lib/rancid/bin/jlogin':
    path   => '/usr/lib/rancid/bin/jlogin',
    ensure => present,
    owner  => 'rancid',
    source => 'puppet:///modules/rancid_git/jlogin.PATCHED',
  }

  file { '/var/lib/rancid/.cloginrc':
    path   => '/var/lib/rancid/bin/.cloginrc',
    ensure => present,
    mode   => 0600,
    owner  => 'rancid',
    source => 'puppet:///modules/rancid_git/cloginrc.SAMPLE',
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

  Package { ensure => "installed" }

  $enhancers = [ "expect", "git", "telnet", "exim4" ]

  package { $enhancers: }

  file { "$debpath":
    path    => "$debpath",
    ensure  => present,
    source  => 'puppet:///modules/rancid_git/rancid-git_2.3.8-1_amd64.deb',
  }

  # add a cron for rancid-git
  # check everything belongs to user rancid
}
