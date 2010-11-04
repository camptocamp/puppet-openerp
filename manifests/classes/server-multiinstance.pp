class openerp::server::multiinstance inherits openerp::server::base {
  file {"/srv/openerp/instances":
    ensure  => directory,
    mode    => 755,
    owner   => "openerp",
    group   => "openerp",
    require => User["openerp"]
  }

  file {"/etc/init.d/openerp-multi-instances":
    ensure => present,
    owner  => root,
    group  => root,
    mode   => 755,
    source => "puppet:///openerp/etc/init.d/openerp-multi-instances",
  }
  
  exec {"install openerp-multi-instances init script":
    command => "update-rc.d openerp-multi-instances defaults 99 12",
    unless  => "test -f /etc/rc2.d/S99openerp-multi-instances",
    require => File["/etc/init.d/openerp-multi-instances"],
  }

  file {"/srv/openerp/openerp-admin.py":
    ensure  => present,
    source  => 'puppet:///openerp/srv/openerp/openerp-admin.py',
    owner   => 'openerp',
    group   => 'openerp',
    mode    => 0755,
    replace => false,
    require => User['openerp']
  }

#  case $lsbdistcodename {
#    "lenny": { include openerp::server::multiinstance::lenny }
#    "hardy": { include openerp::server::multiinstance::hardy }
#  }

}
