class openerp::base {
  user {"openerp":
    ensure  => present,
    shell   => "/bin/bash",
    home    => "/srv/openerp",
    managehome => true,
  }

}
