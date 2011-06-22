class openerp::administration {

  group { "openerp-admin":
    ensure => present,
  }

  sudo::directive { "openerp-administration":
    ensure => present,
    content => template("openerp/sudoers.openerp.erb"),
    require => Group["openerp-admin"],
  }

}
