 file { '/tmp/dir':
    ensure => 'directory',
    recurse => 'true',
    purge => true,
    force => true,
    source => 'puppet:///files/test/test-dir',
    owner  => root,
    group  => root,
    mode   => '0644'
  }

