include motd

$packages = [
'htop',
'screen',
'git',
]

package { $packages:
    ensure => present,
    require => Exec['apt-get update']
}

node default {
  notify { hiera(motd::content): }
}

exec { 'apt-get update':
  command => '/usr/bin/apt-get update'
}


