vcsrepo { '/tmp/git-test':
  ensure   => present,
  provider => git,
  source   => 'https://github.com/Dan-Thompson/Puppetmaster-Puppetserver.git',
}
