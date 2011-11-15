class openerp::client::base inherits openerp::base {
  package {[ "python-gtk2",
             "python-glade2",
             "python-egenix-mxdatetime",
             "python-numpy-ext",
  ]:
    ensure => present,
  }
}
