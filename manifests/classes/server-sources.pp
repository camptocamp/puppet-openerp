class openerp::server::sources inherits openerp::server::base {
  # purpose : install an openerp server from latest bzr sources.

  openerp::sources {"addons":
    ensure  => present,
    url     => "http://bazaar.launchpad.net/%7Eopenerp/openobject-addons/trunk/",
    basedir => "/srv/openerp/",
    owner   => "$openerp_source_owner",
    group   => "$openerp_source_group",
  }
  
  openerp::sources {"extra-addons":
    ensure  => present,
    url     => "http://bazaar.launchpad.net/%7Eopenerp-commiter/openobject-addons/trunk-extra-addons/",
    basedir => "/srv/openerp/",
    owner   => "$openerp_source_owner",
    group   => "$openerp_source_group",
  }

  openerp::sources {"server":
    ensure  => present,
    url     => "http://bazaar.launchpad.net/%7Eopenerp/openobject-server/trunk/",
    basedir => "/srv/openerp/",
    owner   => "$openerp_source_owner",
    group   => "$openerp_source_group",
  }
  
  # init file and first config file
  file {"/etc/init.d/openerp-server":
    ensure   => present,
    content  => template("openerp/openerp-server.erb"),
    owner    => "root",
    group    => "root",
    mode     => "0755",
    notify   => Exec["add openerp-server in rc"],
  }

  file {"/srv/openerp/openerp-server.conf":
    ensure      => present,
    content     => template("openerp/openerp-server.conf.erb"),
    require     => File["/etc/init.d/openerp-server"],
    owner       => "$openerp_source_owner",
    group       => "$openerp_source_group",
    mode        => 0600,
    replace     => false,
  }

  exec {"add openerp-server in rc":
    command => "update-rc.d openerp-server defaults 99 12",
    unless  => "test -e /etc/rc2.d/S99openerp-server",
  }

  file {"/var/run/openerp/":
    ensure => directory,
    owner  => "$openerp_source_owner",
    group  => "$openerp_source_group",
    mode   => 0755
  }

  service {"openerp-server":
    ensure  => running,
    pattern => "openerp-server.py",
    require => [ File["/srv/openerp/openerp-server.conf"], File["/var/run/openerp/"] ]
  }

}
