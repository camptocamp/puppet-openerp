class openerp::server::sources::v50 inherits openerp::server::sources {
  # purpose : install an openerp server from stable bzr sources.

  Openerp::Sources ["addons"] {
    url     => "http://bazaar.launchpad.net/%7Eopenerp/openobject-addons/5.0/"
  }
  
  Openerp::Sources ["extra-addons"] {
    url     => "http://bazaar.launchpad.net/%7Eopenerp-commiter/openobject-addons/stable_5.0_extra-addons/"
  }

  Openerp::Sources ["server"] {
    url     => "http://bazaar.launchpad.net/%7Eopenerp/openobject-server/5.0/",
  }
  
}
