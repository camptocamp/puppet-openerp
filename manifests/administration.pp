class openerp::administration (
  $admin='openerp-admin',
  $command='/etc/init.d/openerp-multi-instances') {

  group { 'openerp-admin':
    ensure => present,
  }

  sudo::directive { 'openerp-administration':
    ensure  => present,
    content => template('openerp/sudoers.openerp.erb'),
    require => Group['openerp-admin'],
  }

}
