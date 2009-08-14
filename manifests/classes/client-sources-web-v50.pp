class openerp::client::sources::web::v50 inherits openerp::client::base {
  # This class is only meant to be used in single shot installs as most execs defined below
  # will run each and every time this class is run!
  # It should not break anything though but is ugly if run in a cron for example.

  openerp::sources {"web-client":
    ensure      => present,
    url         => "http://bazaar.launchpad.net/%7Eopenerp/openobject-client-web/5.0/",
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

  exec {"install openerp-web":
    command  => "cd /srv/openerp/web-client/ && python setup.py install",
    require  => [ Openerp::Sources["web-client"], Exec["upgrade setuptools"], Exec["install pyprotocols"], Exec["install extremes"] ], 
  }

  file {"/etc/openerp-web.cfg":
    ensure  => present,
    content => template("openerp/openerp-web.cfg-50.erb"),
    owner   => $openerp_source_owner,
    group   => $openerp_source_group,
    mode    => 0655,
    replace => false,
  }

  exec {"fix openerp-web startup script":
    command  => "sed -i 's/USER=\"terp\"/USER=\"openerp\"/g' /etc/init.d/openerp-web",
    require  => Exec["install openerp-web"],
  }

}
