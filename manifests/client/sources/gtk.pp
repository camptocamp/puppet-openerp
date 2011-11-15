class openerp::client::sources::gtk inherits openerp::client::base {
  openerp::sources {"client":
    ensure      => present,
    url         => "http://bazaar.launchpad.net/%7Eopenerp/openobject-client/5.0/",
    basedir     => "/srv/openerp/",
    owner       => "$openerp_source_owner",
    group       => "$openerp_source_group",
  }
}
