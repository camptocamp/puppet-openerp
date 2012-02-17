class openerp::server::base inherits openerp::base {
  case $lsbdistcodename {
    squeeze: {
      package {[
        "python2.6",
        ]:
      }
    }
    lenny: { 
      package {[
        "python-xml",
        "python2.4",
        "python-numeric",
        "gs-aladdin", 
        ]:
      }
    }
  }
  if !defined(Package["python-imaging"]) {
    package{"python-imaging": ensure => installed;}
  }
  if !defined(Package["php5-mysql"]) {
    package{"php5-mysql": ensure => installed;}
  }
  if !defined(Package["python-virtualenv"]) {
    package{"python-virtualenv": ensure => installed;}
  }
  package { [
              "ghostscript",
              "python-libxml2", 
              "python-libxslt1", 
              "python-numpy", 
              "python-reportlab",
              "python-pydot",
              "python-pyparsing",
              "python-matplotlib",
              "python-pychart",
              "python-profiler",
              "python-turbogears",
              "python-cheetah",
              "python-lxml",
              "python-serial",
              "python-tz",
              "graphviz",
              "python-ldap",
              "python-excelerator"]:
  }
  
  if (!defined(Package["python-psycopg"]) and $lsbdisctodename == lenny) {
    package {"python-psycopg": ;}
  }
  if !defined(Package["python-psycopg2"]) {
    package {"python-psycopg2": ; }
  }
}
