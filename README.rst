=====================
OpenERP Puppet module
=====================

This module is provided to you by Camptocamp_.

.. _Camptocamp: http://www.camptocamp.com/

-------------------------
Openerp Standard Platform
-------------------------

In order to install OpenERP platform according to Camptocamp_ best practices, you have two solutions:
#. either add this module in your Puppetmaster (Master/Agent Puppet) or apply it locally (Serverless Puppet)
#. realize the described instruction on your server (if you don't want to use puppet)

Regarding the Python libraries, we're using python virtual environments allowing us to have more than one OpenERP_ installation
on the same server, with partitioned environments.

The best way to know Python libraries depedencies is to go on `this page`_ or to contact our OpenERP_ specialists.


................................
Multi-instance mode explaination
................................

Instead of a standard installation with, for example, Debian/Ubuntu packages, our installation allows to have many OpenERP_ versions installed
in parallel. Here's the directory structure of /srv/openerp/instances::

  /srv/openerp/instances
  ├── instance1
  │   ├── autorun 
  │   ├── bin 
  │   ├── config 
  │   ├── init.d 
  │   ├── log 
  │   ├── run 
  │   └── src 
  ├── intance2
  │   ├── autorun 
  │   ├── bin 
  │   ├── config 
  │   ├── init.d 
  │   ├── log 
  │   ├── run 
  │   └── src 
  └── instance3 
      ├── autorun 
      ├── bin 
      ├── config 
      ├── init.d 
      ├── log 
      ├── run 
      └── src 

This structure is deployed by a bluidout_ receipt (not opensourced for now). It installs the wanted OpenERP_ version through bazaar. The init-script_ simply execute
the startup scripts present in the *autorun* directory. Scripts in autorun directory are symlink to init.d content, this allow to activate or not instances at server startup.



-------------------
Install with Puppet
-------------------

If you don't know Puppet but are interested in it, the best is to read the `Puppet documentation`_.

Our standard OpenERP_ platform includes different components, all provided as Puppet modules:
- puppet-openerp
- puppet-postgresql_
- puppet-bazaar_
- puppet-buildenv_
- puppet-python_

Based on those modules, here are the element you have to add in your Puppet manifest::

  Exec {
    path => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin',
  }

  $postgresql_version = '9.0'
  include postgresql
  include python::dev
  include python::virtualenv
  include buildenv::postgresql
  include openerp

In «Puppet serverless» mode, you just have to download the modules in a directory, and run the following command::

  puppet apply --modulepath modules --verbose manifest.pp

-------------------
Manual installation
-------------------

- create an "openerp" user (as in `openerp::base`_)
    - home directory: /srv/openerp
    - shell: /bin/bash
    - groups: dialout, postgres, adm (you may override this list - see examples)
- create a /srv/openerp/instances directory (as in `openerp::server::multiinstance`_)
    - directory owner: openerp
    - directory group: openerp
    - mode: 0755
- install a special init-script (as in `openerp::server::multiinstance`_)
    - file located in `files/etc/init.d/openerp-multi-instances`_
    - command used : update-rc.d openerp-multi-instances defaults 99 12
- install required python libraries (as in `openerp::server::base`_)


.. _`OpenERP`: http://openerp.camptocamp.com/
.. _`Puppet documentation`: http://docs.puppetlabs.com/learning/
.. _`init-script`: blob/master/files/etc/init.d/openerp-multi-instances
.. _`buildout`: http://www.buildout.org/
.. _`this page`: http://doc.openerp.com/v6.1/install/index.html#installation-link
.. _`puppet-postgresql`: http://github.com/camptocamp/puppet-postgresql
.. _`puppet-postgresql`: http://github.com/camptocamp/puppet-bazaar
.. _`puppet-buildenv`: http://github.com/camptocamp/puppet-buildenv
.. _`puppet-python`: https://github.com/camptocamp/puppet-python
.. _`openerp::base`: blob/master/manifests/base.pp
.. _`openerp::server::multiinstance`: blob/master/manifests/server/multiinstance.pp
.. _`files/etc/init.d/openerp-multi-instances`: blob/master/files/etc/init.d/openerp-multi-instances
.. _`openerp::server::base`: blob/master/manifests/server/base.pp

-------
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
