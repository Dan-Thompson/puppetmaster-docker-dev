
accounts::user {'daniel':
  shell		=> '/bin/bash',
  password	=> hiera('ssh_password::daniel'),
  sshkeys  	=> hiera_array('ssh_keys::daniel', []),
  purge_sshkeys => true,
}


accounts::user { 'root':
  ensure   => present,
  comment  => 'root account',
  groups   => [ 'root' ],
  sshkeys  => hiera_array('ssh_keys::root', []),
  locked   => false,
  purge_sshkeys => true,
}
