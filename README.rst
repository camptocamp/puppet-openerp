OpenERP Puppet module
=====================

This module is provided to you by Camptocamp_.

.. _Camptocamp: http://www.camptocamp.com/


Dependencies
------------
you must have postgresql installed. You can use this postgresql module if you want:
http://github.com/camptocamp/puppet-postgresql

Importante note
---------------
This module is compatible for OpenERP 6.x. More over, it follows Camptocamp practices, meaning it will prepare the system
for OpenERP server, but will not install it.

What does this module
---------------------
- create an "openerp" user (as in `openerp::base`_)
  - home directory: /srv/openerp
  - shell: /bin/bash
  - groups: dialout, postgres, adm (you may override this list - see examples)
- create a /srv/openerp/instances directory (as in `openerp::server::multiinstance`_)
- install a special init-script (as in openerp::server::multiinstance)
  - file located in `files/etc/init.d/openerp-multi-instances-6`_
  - command used : update-rc.d openerp-multi-instances defaults 99 12
- install required python libraries (as in `openerp::server::base`_)
.. _`openerp::base`: blob/master/manifests/base.pp
.. _`openerp::server::multiinstance`: blob/master/manifests/server/multiinstance.pp
.. _`files/etc/init.d/openerp-multi-instances-6`: blob/master/files/etc/init.d/openerp-multi-instances-6
.. _`openerp::server::base`: blob/master/manifests/server/base.pp

Example
-------

Node::

  node 'openerp.domain.ltd' {
    # using puppet-postgresql provided
    # by Camptocamp
    include postgresql
    include postgresql::backup

    # set up basics for openerp server
    include openerp::server::multiinstance
    class {
      openerp::administration: admin => 'my-user';
    }
  }

Override openerp groups::

  node 'openerp.domain.ltd' {
    …
    class {
      openerp::base: groups => ['dialout','postgres','adm','www-data'];
    }
    …
  }
