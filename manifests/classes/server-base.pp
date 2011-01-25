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
        "python-2.4",
        "python-numeric",
        ]:
      }
    }
  }

  package { [
              "gs",
              "gs-aladdin", 
              "python-libxml2", 
              "python-libxslt1", 
              "python-numpy", 
              "python-reportlab",
              "python-imaging",
              "python-pydot",
              "python-pyparsing",
              "python-matplotlib",
              "python-pychart",
              "python-profiler",
              "python-turbogears",
              "python-cheetah",
              "python-lxml",
              "python-serial",
              "php5",
              "php5-mysql",
              "libapache2-mod-php5",
              "python-tz",
              "graphviz",
              "python-ldap",
              "python-virtualenv",
              "python-excelerator"]:
  }
  
  if (!defined(Package["python-psycopg"]) and $lsbdisctodename == lenny) {
    package {"python-psycopg": ;}
  }
  if !defined(Package["python-psycopg2"]) {
    package {"python-psycopg2": ; }
  }
}
