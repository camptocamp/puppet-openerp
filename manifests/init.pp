class openerp {
  if $::lsbdistcodename != 'squeeze' {
    fail "Unsupported system ${::lsbdistcodename}"
  }
  include openerp::server
}
