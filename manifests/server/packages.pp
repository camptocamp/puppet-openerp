class openerp::server::packages {

  package { [
    'ghostscript',
    'graphviz',
    'libjpeg62-dev',
    'libldap2-dev',
    'libgeos-c1',
    'libsasl2-dev',
    'libxml2-dev',
    'libxslt1-dev',
    'poppler-utils',
    'zlib1g-dev',
    'zlib1g',
    ]:
  }
}
