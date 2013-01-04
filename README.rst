.. contents:: Documentation
   :depth: 1

===========================================
OpenERP Standard Platform (english version)
===========================================

.. contents::
  :local:

In order to install an OpenERP_ platform according to Camptocamp_ best practices, you have two solutions:
  #. either add this module in your Puppetmaster (Master/Agent Puppet) or apply it locally (Serverless Puppet) → `Install with Puppet`_
  #. realize the described instruction on your server (if you don't want to use puppet) → `Manual installation`_

Regarding the Python libraries, we're using buildout_ Python syspath encapsulation system allowing us to have more than one OpenERP_ installation
on the same server, with partitioned environments.

The best way to know Python libraries depedencies is to go on `this page`_ or to contact our OpenERP_ specialists.

................................
Multi-instance mode explaination
................................

Instead of a standard installation with, for example, Debian/Ubuntu packages, our installation allows to have many OpenERP_ versions installed
in parallel. Here's the directory structure of /srv/openerp/instances (OpenERP v6.x)::

  /srv/openerp/instances
  ├── instance1
  │   ├── auto-run
  │   ├── bin 
  │   ├── config 
  │   ├── init.d
  │   ├── log 
  │   ├── run 
  │   └── src 
  ├── intance2
  │   ├── auto-run
  │   ├── bin 
  │   ├── config 
  │   ├── init.d
  │   ├── log 
  │   ├── run 
  │   └── src 
  └── instance3 
      ├── auto-run
      ├── bin 
      ├── config 
      ├── init.d
      ├── log 
      ├── run 
      └── src 
  …

This structure is deployed by a buildout_ receipt (not opensourced for now). It installs the wanted OpenERP_ version through bazaar.

Note about the init-script_: The init-script first checks if a symlink to an init script is found in the ``auto-run`` directory. If found, it will call this script with the argument ``start`` or ``stop`` to manage the OpenERP instance. If no such link is found, it checks for a ``supervisord`` installation in ``bin/`` and starts or stops this daemon to manage the OpenERP instance. It is your job to configure the OpenERP service in supervisord's configuration.


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

Serverless Puppet
~~~~~~~~~~~~~~~~

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

You just have to download the modules in a directory, and run the following command::

  puppet apply --modulepath modules --verbose manifest.pp

Master/Agent Puppet
~~~~~~~~~~~~~~~~~~

Add the listed modules to your Puppetmaster. Here's how you may want to set up your node.

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
- install required python libraries (as in `this page`_)

------------
Contributing
------------

Please report bugs and feature request using [GitHub issue
tracker](https://github.com/camptocamp/puppet-openerp/issues).

For pull requests, it is very much appreciated to check your Puppet manifest
with [puppet-lint](https://github.com/camptocamp/puppet-apt/issues) to follow the recommended Puppet style guidelines from the
[Puppet Labs style guide](http://docs.puppetlabs.com/guides/style_guide.html).

-------
License
-------

Copyright (c) 2012 <mailto:puppet@camptocamp.com> All rights reserved.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.


-----

===============================================
Plate-forme standard OpenERP (version francais)
===============================================

.. contents::
  :local:

De manière à mettre cette plate-forme de base OpenERP_ selon les bonnes pratiques de Camptocamp_, vous avez deux solutions:
  #. intégrer ce module dans votre Puppetmaster (Master/Agent Puppet) ou l'appliquer localement (Serverless Puppet) → `Installer avec Puppet`_
  #. réaliser les instructions ci-dessous sur votre serveur (si vous n'utilisez ni ne souhaitez employer Puppet) → `Installation manuelle`_

Concernant les librairies Python nécessaires, nous utilisons des environnements virtuels permettant d'avoir plusieurs installations d'OpenERP sur le même serveur avec des environnements cloisonnés. 

Pour connaître la liste des librairies Python nécessaires le mieux est sans doute de consulter la `page suivante`_ ou de prendre contact avec notre équipe de spécialistes OpenERP.

...............................
Principe du mode multi-instance
...............................

Contrairement à une installation standard via p.ex. le paquet Debian/Ubuntu, notre plate-forme d'installation permet d'installer en parallèle plusieurs versions d'OpenERP_ totalement cloisonnées.
Voici la structure type du dossier /srv/openerp/instances (OpenERP v6.x)::

  /srv/openerp/instances
  ├── instance1
  │   ├── autorun 
  │   ├── bin 
  │   ├── config 
  │   ├── init.d 
  │   ├── log 
  │   ├── run 
  │   └── src 
  ├── intance2
  │   ├── autorun 
  │   ├── bin 
  │   ├── config 
  │   ├── init.d 
  │   ├── log 
  │   ├── run 
  │   └── src 
  └── instance3 
      ├── autorun 
      ├── bin 
      ├── config 
      ├── init.d 
      ├── log 
      ├── run 
      └── src 
  …

Le déploiement de cette structure est réalisé par une recette buildout_ spécifique (pas fournie pour l'instant en OpenSource) qui installe via bazaar la version d'OpenERP souhaitée dans le dossier srv.

Note concernant l'init-script_ : Le script d'init vérifie si un lien symbolique vers un script de lancement est trouvé dans le dossier ``auto-run``. S'il est trouvé, il appelle ce script avec les arguments
``start`` ou ``stop`` pour gérer l'instance OpenERP. Si un tel script n'est pas trouvé, il recherche une installation de ``supervisord`` dans ``bin/`` démarre ou arrête ce démon
pour gérer l'instance OpenERP. La configuration de supervisord pour effectivement lancer openerp doit être faîte par vos soins.

---------------------
Installer avec Puppet
---------------------

Si vous ne connaissez pas Puppet mais que vous êtes très intéressé à la découvrir, le mieux est de commencer par lire la `documentation Puppet`_.

Notre plate-forme OpenERP_ standard inclut différents composants tous fournis sous la forme de module Puppet, dont voici la liste:
  - puppet-openerp
  - puppet-postgresql_
  - puppet-bazaar_
  - puppet-buildenv_
  - puppet-python_

Serverless Puppet
~~~~~~~~~~~~~~~~

Sur la base des modules listés ci-dessus, voici ce qu'il convient de mettre dans *manifest.pp*::

  Exec {
    path => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin',
  }

  $postgresql_version = '9.0'
  include postgresql
  include python::dev
  include python::virtualenv
  include buildenv::postgresql
  include openerp

Il faut télécharger les modules sur la machine locale, dans le dossier "modules". Ensuite, il suffit de lancer ```puppet apply --modulepath modules --verbose manifest.pp```

Master/Agent Puppet
~~~~~~~~~~~~~~~~~~

Il vous faut ajouter les modules listés à votre Puppetmaster. Voici à quoi ressemblerait un node::

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

Ou comment overrider les groupes dont est membre le user "puppet"::

  node 'openerp.domain.ltd' {
    …
    class {
      openerp::base: groups => ['dialout','postgres','adm','www-data'];
    }
    …
  }

---------------------
Installation manuelle
---------------------

- Créer un utilisateur "openerp" (voir `openerp::base`_)
    - dossier personnel : /srv/openerp
    - shell : /bin/bash
    - groupes : dialout, postgres, adm (vous pouvez ajouter d'autres groupes)
- Créer un dossier /srv/openerp/instances (voir `openerp::server::multiinstance`_)
    - propriétaire : openerp
    - groupe : openerp
    - mode : 0775
- Installer le script d'init (voir `openerp::server::multiinstance`_)
    - fichier situé dans `files/etc/init.d/openerp-multi-instances`_
    - commande à employer : update-rc.d openerp-multi-instances defaults 99 12
Installer les librairies Python requises (voir `cette page`_)


.. _`Camptocamp`: http://www.camptocamp.com/
.. _`OpenERP`: http://openerp.camptocamp.com/
.. _`Puppet documentation`: http://docs.puppetlabs.com/learning/
.. _`documentation Puppet`: http://docs.puppetlabs.com/learning/
.. _`init-script`: files/etc/init.d/openerp-multi-instances
.. _`script d'init`: files/etc/init.d/openerp-multi-instances
.. _`buildout`: http://www.buildout.org/
.. _`this page`: http://doc.openerp.com/v6.1/install/index.html#installation-link
.. _`page suivante`: http://doc.openerp.com/v6.1/install/index.html#installation-link
.. _`cette page`: http://doc.openerp.com/v6.1/install/index.html#installation-link
.. _`puppet-postgresql`: http://github.com/camptocamp/puppet-postgresql
.. _`puppet-bazaar`: http://github.com/camptocamp/puppet-bazaar
.. _`puppet-buildenv`: http://github.com/camptocamp/puppet-buildenv
.. _`puppet-python`: https://github.com/camptocamp/puppet-python
.. _`openerp::base`: manifests/base.pp
.. _`openerp::server::multiinstance`: manifests/server/multiinstance.pp
.. _`files/etc/init.d/openerp-multi-instances`: files/etc/init.d/openerp-multi-instances
.. _`openerp::server::base`: manifests/server/base.pp
