class openerp::server {
  include openerp::base
  include openerp::server::packages

  file {'/srv/openerp/instances':
    ensure  => directory,
    mode    => '0755',
    owner   => 'openerp',
    group   => 'openerp',
    require => User['openerp']
  }

  file {'/etc/init.d/openerp-multi-instances':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/openerp/etc/init.d/openerp-multi-instances',
  }

  $init_check = $::lsbdistcodename ? {
    'lenny'   => '/etc/rc2.d/S99openerp-multi-instances',
    'squeeze' => '/etc/rc2.d/S03openerp-multi-instances',
    default   => '/etc/rc2.d/S03openerp-multi-instances',
  }

  exec {'install openerp-multi-instances init script':
    command => 'update-rc.d openerp-multi-instances defaults 99 12',
    creates => $init_check,
    require => File['/etc/init.d/openerp-multi-instances'],
  }

}
