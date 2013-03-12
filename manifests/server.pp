class openerp::server {
  include openerp::server::packages

  file {'/srv/openerp/instances':
    ensure  => directory,
    mode    => '0755',
    owner   => 'openerp',
    group   => 'openerp',
    require => Class['openerp::base']
  }

  file {'/etc/init.d/openerp-multi-instances':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/openerp/etc/init.d/openerp-multi-instances',
  }

  service { 'openerp-multi-instances':
    ensure    => undef,
    enable    => true,
    hasstatus => false,
    require   => File['/etc/init.d/openerp-multi-instances'],
  }

}
