class openerp::server::multiinstance inherits openerp::server::base {

  if $openerp_version == "" {
    $openerp_admin_version = $lsbdistcodename ? {
      'lenny'   => "5",
      'squeeze' => "6",
      default   => "6",
    }
  }
  else {
    $openerp_admin_version = $openerp_version
  }

  openerp::sources {"openerp-admin":
    ensure      => "present",
    url         => "http://bazaar.camptocamp.net/bzr/c2c_tinyerp/server_management_tools/openerp_admin_${openerp_admin_version}/",
    basedir     => "/srv/openerp/",
    owner       => "openerp",
    group       => "openerp",
  }

  file {"/srv/openerp/openerp-admin/openerp-admin.py":
    mode    => 0755,
    owner   => "openerp",
    group   => "openerp",
    require => Openerp::Sources["openerp-admin"],
  }

  file {"/srv/openerp/instances":
    ensure  => directory,
    mode    => 755,
    owner   => "openerp",
    group   => "openerp",
    require => User["openerp"]
  }

  $initscript = $openerp_init ? {
    '6' => 'puppet:///modules/openerp/etc/init.d/openerp-multi-instances-6',
    default => 'puppet:///modules/openerp/etc/init.d/openerp-multi-instances',
  }

  file {"/etc/init.d/openerp-multi-instances":
    ensure => present,
    owner  => root,
    group  => root,
    mode   => 755,
    source => $initscript,
  }
  
  exec {"install openerp-multi-instances init script":
    command => "update-rc.d openerp-multi-instances defaults 99 12",
    creates => $lsbdistcodename ? {
      "lenny" => "/etc/rc2.d/S99openerp-multi-instances",
      "squeeze" => "/etc/rc2.d/S03openerp-multi-instances",
      default => "/etc/rc2.d/S03openerp-multi-instances",
    },
    require => File["/etc/init.d/openerp-multi-instances"],
  }

}
