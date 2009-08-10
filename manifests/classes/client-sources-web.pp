class openerp::client::sources::web inherits openerp::client::base {

  openerp::sources {"web-client":
    ensure      => present,
    url         => "http://bazaar.launchpad.net/%7Eopenerp/openobject-client-web/trunk/",
    basedir     => "/srv/openerp/",
    owner       => "$openerp_source_owner",
    group       => "$openerp_source_group",
  }

  file {"/etc/init.d/openerp-web":
    ensure  => "/srv/openerp/web-client/scripts/openerp-web",
    require => Openerp::Sources["web-client"],
    notify  => Exec["add web-client to startup"],
  }

  file {"/etc/openerp-web.cfg":
    ensure  => present,
    content => template("openerp/openerp-web.cfg.erb"),
    owner   => $openerp_source_owner,
    group   => $openerp_source_group,
    mode    => 0655,
    replace => false,
  }

  file {"/usr/bin/openerp-web":
    ensure => "/srv/openerp/web-client/openerp-web.py",
    require => Openerp::Sources["web-client"]
  }

  exec {"add web-client to startup":
    command => "update-rc.d openerp-web defaults 99 12",
    unless  => "test -e /etc/rc2.d/S20openerp-web || test -e /etc/rc2.d/S99openerp-web",
    require => [File["/etc/init.d/openerp-web"], File["/etc/openerp-web.cfg"]],
  }

  exec {"install openerp-web":
    command  => "cd /srv/openerp/web-client/lib && sh populate.sh",
    creates  => "/srv/openerp/web-client/lib/cherrypy",
    require  => Openerp::Sources["web-client"],
  }

  service {"openerp-web":
    ensure  => running,
    enable  => true,
    pattern => "openerp-web.cfg",
    require => [ File["/etc/openerp-web.cfg"], Exec["install openerp-web"] ],
  }

}
