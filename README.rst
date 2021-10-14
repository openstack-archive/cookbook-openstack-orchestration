OpenStack Chef Cookbook - orchestration
=======================================

.. image:: https://governance.openstack.org/badges/cookbook-openstack-orchestration.svg
    :target: https://governance.openstack.org/reference/tags/index.html

Description
===========

This cookbook installs the OpenStack Heat service **Heat** as part of an
OpenStack reference deployment Chef for OpenStack. The `OpenStack
chef-repo`_ contains documentation for using this cookbook in the
context of a full OpenStack deployment. Heat is currently installed from
packages.

.. _OpenStack chef-repo: https://opendev.org/openstack/openstack-chef

https://docs.openstack.org/heat/latest/

Requirements
============

- Chef 16 or higher
- Chef Workstation 21.10.640 for testing (also includes Berkshelf for
  cookbook dependency resolution)

Platform
========

-  ubuntu
-  redhat
-  centos

Cookbooks
=========

The following cookbooks are dependencies:

- 'openstack-common', '>= 20.0.0'
- 'openstack-identity', '>= 20.0.0'
- 'openstackclient'

Attributes
==========

Please see the extensive inline documentation in ``attributes/*.rb`` for
descriptions of all the settable attributes for this cookbook.

Note that all attributes are in the ``default['openstack']`` "namespace"

The usage of attributes to generate the ``heat.conf`` is described in
the openstack-common cookbook.

Recipes
=======

openstack-orchestration::api-cfn
--------------------------------

- Configure and start ``heat-api-cfn`` service

openstack-orchestration::api
----------------------------

- Configure and start ``heat-api`` service

openstack-orchestration::common
-------------------------------

- Installs the ``heat`` packages and setup configuration for Heat.

openstack-orchestration::engine
-------------------------------

- Setup the heat database and start ``heat-engine`` service

openstack-orchestration::identity_registration
----------------------------------------------

- Registers the Heat API endpoint, heat service and user

License and Author
==================

+-----------------+---------------------------------------------+
| **Author**      | Zhao Fang Han (hanzhf@cn.ibm.com)           |
+-----------------+---------------------------------------------+
| **Author**      | Chen Zhiwei (zhiwchen@cn.ibm.com)           |
+-----------------+---------------------------------------------+
| **Author**      | Ionut Artarisi (iartarisi@suse.cz)          |
+-----------------+---------------------------------------------+
| **Author**      | Mark Vanderwiel (vanderwl@us.ibm.com)       |
+-----------------+---------------------------------------------+
| **Author**      | Jan Klare (j.klare@x-ion.de)                |
+-----------------+---------------------------------------------+
| **Author**      | Dr. Jens Rosenboom (j.rosenboom@x-ion.de)   |
+-----------------+---------------------------------------------+
| **Author**      | Christoph Albers (c.albers@x-ion.de)        |
+-----------------+---------------------------------------------+
| **Author**      | Lance Albertson (lance@osuosl.org)          |
+-----------------+---------------------------------------------+

+-----------------+--------------------------------------------------+
| **Copyright**   | Copyright (c) 2013-2014, IBM Corp.               |
+-----------------+--------------------------------------------------+
| **Copyright**   | Copyright (c) 2014, SUSE Linux, GmbH.            |
+-----------------+--------------------------------------------------+
| **Copyright**   | Copyright (c) 2016, x-ion GmbH.                  |
+-----------------+--------------------------------------------------+
| **Copyright**   | Copyright (c) 2019-2021, Oregon State University |
+-----------------+--------------------------------------------------+

Licensed under the Apache License, Version 2.0 (the "License"); you may
not use this file except in compliance with the License. You may obtain
a copy of the License at

::

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
