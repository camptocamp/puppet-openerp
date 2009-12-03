class openerp::client::sources::web::v50 inherits openerp::client::base {
  # This class is only meant to be used in single shot installs as most execs defined below
  # will run each and every time this class is run!
  # It should not break anything though but is ugly if run in a cron for example.

  openerp::sources {"web-client":
    ensure      => present,
    url         => "http://bazaar.launchpad.net/~openerp/openobject-client-web/5.0/",
    basedir     => "/srv/openerp/",
    owner       => "$openerp_source_owner",
    group       => "$openerp_source_group",
  }

  exec {"upgrade setuptools":
    command  => "easy_install -U setuptools"
  }

  exec {"install extremes":
    command => "easy_install extremes",
    require => Exec ["upgrade setuptools"]
  }

  exec {"install pyprotocols":
    command => "easy_install http://dbsprockets.googlecode.com/files/PyProtocols-1.0a0dev-r2302.zip",
    unless  => "grep --quiet PyProtocols-1.0a0dev_r2302-py2.5-linux-i686.egg /usr/lib/python2.5/site-packages/easy-install.pth",
    require => Exec ["upgrade setuptools"]
  }

  file {"/etc/openerp-web.cfg":
    ensure  => present,
    content => template("openerp/openerp-web.cfg-50.erb"),
    owner   => $openerp_source_owner,
    group   => $openerp_source_group,
    mode    => 0655,
    replace => false,
  }

  exec {"install openerp-web":
    command  => "cd /srv/openerp/web-client/ && python setup.py install",
    require  => [ Openerp::Sources["web-client"], Exec["upgrade setuptools"], Exec["install pyprotocols"], Exec["install extremes"] ], 
  }

  exec {"openerp-web startup script":
    command => "cp /srv/openerp/web-client/scripts/openerp-web /etc/init.d/",
    creates => "/etc/init.d/openerp-web",
    require => Exec["install openerp-web"],
  }

  exec {"fix openerp-web startup script":
    command  => "sed -i 's/USER=\"terp\"/USER=\"openerp\"/g' /etc/init.d/openerp-web",
    require  => Exec["openerp-web startup script"],
  }

  exec {"add web-client to startup":
    command => "update-rc.d openerp-web defaults 99 12",
    unless  => "test -e /etc/rc2.d/S20openerp-web || test -e /etc/rc2.d/S99openerp-web",
    require => [ Exec["fix openerp-web startup script"],
                 File["/etc/openerp-web.cfg"] ],
    notify  => Service["openerp-web"],
  }

  service {"openerp-web":
    ensure  => running,
    enable  => true,
    pattern => "openerp-web.cfg",
    require => [ File["/etc/openerp-web.cfg"],
                 Exec["fix openerp-web startup script"] ],
  }
}
