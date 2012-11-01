OpenERP Puppet module
=====================

This module is provided to you by Camptocamp_.

.. _Camptocamp: http://www.camptocamp.com/


Dependencies
------------
- you must have postgresql installed. You can use this `postgresql module`_ if you want
- you must provide python-virtualenv and python-dev. You may use this `python module`_
    - include python::dev
    - include python::virtualenv

Importante note
---------------

Module purpose
..............
This module is compatible for OpenERP 6.x. More over, it follows Camptocamp practices, meaning it will prepare the system
for OpenERP server, but will not install it.

Python libraries
................
As needed python libraries depend on OpenERP activated modules, we're using some buildout receipe.

What does this module
---------------------

- create an "openerp" user (as in `openerp::base`_)
    - home directory: /srv/openerp
    - shell: /bin/bash
    - groups: dialout, postgres, adm (you may override this list - see examples)
- create a /srv/openerp/instances directory (as in `openerp::server::multiinstance`_)
    - directory owner: openerp
    - directory group: openerp
    - mode: 0755
- install a special init-script (as in openerp::server::multiinstance)
    - file located in `files/etc/init.d/openerp-multi-instances`_
    - command used : update-rc.d openerp-multi-instances defaults 99 12
- install required python libraries (as in `openerp::server::base`_)

.. _`postgresql module`: http://github.com/camptocamp/puppet-postgresql
.. _`python module`: https://github.com/camptocamp/puppet-python
.. _`openerp::base`: blob/master/manifests/base.pp
.. _`openerp::server::multiinstance`: blob/master/manifests/server/multiinstance.pp
.. _`files/etc/init.d/openerp-multi-instances`: blob/master/files/etc/init.d/openerp-multi-instances
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
