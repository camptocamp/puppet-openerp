class openerp::server::base inherits openerp::base {

  package { [
    'ghostscript',
    'graphviz',
    ]:
  }
}
