=====================
OpenERP Puppet module
=====================

This module is provided to you by Camptocamp_.

.. _Camptocamp: http://www.camptocamp.com/


------------
Dependencies
------------
you must have postgresql installed. You can use this postgresql module if you want:
http://github.com/camptocamp/puppet-postgresql/tree/master

You must define a class named "bazaar::client" in your template/node. One is available here:
http://github.com/camptocamp/puppet-bazaar/tree/master


-------
Purpose
-------
Allow you to install OpenERP server or client from sources (bzr on launchpad), native packages (when available) 
or using a multi-instance script.


-------
Example
-------
Server node, with web-client, from sources::
  node "myserver.node" {
  include openerp::server::sources
  include openerp::client::sources::web
  }

Client node, from sources::
  node "myclient.node" {
  include openerp::client::sources::gtk
  }
