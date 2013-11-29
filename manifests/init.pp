class openerp($groups=['dialout','postgres']) {
  if $::lsbdistcodename !~ /^(squeeze|wheezy|saucy)$/ {
    fail "Unsupported system ${::lsbdistcodename}"
  }

  class {
    'openerp::base': groups => $groups;
  }
  include openerp::server
}
