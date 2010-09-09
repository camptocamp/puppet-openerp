class openerp::server::base inherits openerp::base {

  package { [ "python2.4", 
              "python-xml",
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
              "gs",
              "aladin",
              "gs-aladdin",
              "graphviz",
              "python-ldap",
              "python-numeric",
              "python-excelerator"]:

    ensure => installed,
  }

  if !defined(Package["python-psycopg"]) {
    package {"python-psycopg": ;}
  }
  if !defined(Package["python-psycopg2"]) {
    package {"python-psycopg2": ; }
  }

}
