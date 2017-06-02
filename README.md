Team and repository tags
========================

[![Team and repository tags](https://governance.openstack.org/badges/cookbook-openstack-orchestration.svg)](https://governance.openstack.org/reference/tags/index.html)

<!-- Change things from this point on -->

![Chef OpenStack Logo](https://www.openstack.org/themes/openstack/images/project-mascots/Chef%20OpenStack/OpenStack_Project_Chef_horizontal.png)

Description
===========

This cookbook installs the OpenStack Heat service **Heat** as part of an
OpenStack reference deployment Chef for OpenStack.

https://wiki.openstack.org/wiki/Heat

Requirements
============

- Chef 12 or higher
- chefdk 0.9.0 or higher for testing (also includes berkshelf for cookbook
  dependency resolution)

Platform
========

- ubuntu
- redhat
- centos

Cookbooks
=========

The following cookbooks are dependencies:

- 'openstack-common', '>= 14.0.0'
- 'openstack-identity', '>= 14.0.0'
- 'openstackclient', '>= 0.1.0'

Attributes
==========

Please see the extensive inline documentation in `attributes/*.rb` for
descriptions of all the settable attributes for this cookbook.

Note that all attributes are in the `default['openstack']` "namespace"

The usage of attributes to generate the heat.conf is decribed in the
openstack-common cookbook.

Recipes
=======

## openstack-orchestration::api-cloudwatch
- Configure and start heat-api-cloudwatch service

## openstack-orchestration::api-cfn
- Configure and start heat-api-cfn service

## openstack-orchestration::api
- Configure and start heat-api service

## openstack-orchestration::client
- Install the heat client packages

## openstack-orchestration::common
- Installs the heat packages and setup configuration for Heat.

## openstack-orchestration::engine
- Setup the heat database and start heat-engine service

## openstack-orchestration::identity_registration
- Registers the Heat API endpoint, heat service and user

License and Author
==================

|                      |                                                    |
|:---------------------|:---------------------------------------------------|
| **Author**           |  Zhao Fang Han (<hanzhf@cn.ibm.com>)               |
| **Author**           |  Chen Zhiwei (<zhiwchen@cn.ibm.com>)               |
| **Author**           |  Ionut Artarisi (<iartarisi@suse.cz>)              |
| **Author**           |  Mark Vanderwiel (<vanderwl@us.ibm.com>)           |
| **Author**           |  Jan Klare (<j.klare@x-ion.de>)                    |
| **Author**           |  Dr. Jens Rosenboom (<j.rosenboom@x-ion.de>)       |
| **Author**           |  Christoph Albers (<c.albers@x-ion.de>)            |
|                      |                                                    |
| **Copyright**        |  Copyright (c) 2013-2014, IBM Corp.                |
| **Copyright**        |  Copyright (c) 2014, SUSE Linux, GmbH.             |
| **Copyright**        |  Copyright (c) 2016, x-ion GmbH.                   |

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
