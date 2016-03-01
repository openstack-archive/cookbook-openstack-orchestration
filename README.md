Description
===========

This cookbook installs the OpenStack Heat service **Heat** as part of an OpenStack reference deployment Chef for OpenStack.

https://wiki.openstack.org/wiki/Heat

Requirements
============

Chef 11 or higher required (for Chef environment use).

Cookbooks
---------

The following cookbooks are dependencies:

* openstack-common
* openstack-identity

Usage
=====

api
------
- Configure and start heat-api service

api-cfn
------
- Configure and start heat-api-cfn service

api-cloudwatch
------
- Configure and start heat-api-cloudwatch service

client
----
- Install the heat client packages

common
------
- Installs the heat packages and setup configuration for Heat.

engine
------
- Setup the heat database and start heat-engine service

identity_registration
---------------------
- Registers the Heat API endpoint, heat service and user

Attributes
==========

Attributes for the Heat service are in the ['openstack']['orchestration'] namespace.

* `openstack['orchestration']['identity_service_chef_role']` - The name of the Chef role that installs the Keystone Service API
* `openstack['orchestration']['rabbit_server_chef_role']` - The name of the Chef role that knows about the message queue server
* `openstack['orchestration']['user']` - User heat runs as
* `openstack['orchestration']['group']` - Group heat runs as
* `openstack['db']['orchestration']['username']` - Username for heat database access
* `openstack['orchestration']['service_role']` - User role used by heat when interacting with keystone, defaults to 'service'. Used in the API and registry paste.ini files
* `openstack['orchestration']['syslog']['use']` - Should heat log to syslog?
* `openstack['orchestration']['platform']` - hash of platform specific package/service names and options
* `openstack['orchestration']['api']['auth']['version']` - Select v2.0 or v3.0. Default v2.0. The auth API version used to interact with the identity service.

TODO: update this section adding new attributes

MQ attributes
-------------

TODO: update this section with the new attributes

Service bindings
----------------

* `openstack['bind_service']['all']['orchestration-api']['host']` - The IP address to bind the service to
* `openstack['bind_service']['all']['orchestration-api']['port']` - The port to bind the service to
* `openstack['bind_service']['all']['orchestration-api']['interface']` - The interface to bind the service to

* `openstack['bind_service']['all']['orchestration-api-cfn']['host']` - The IP address to bind the service to
* `openstack['bind_service']['all']['orchestration-api-cfn']['port']` - The port to bind the service to
* `openstack['bind_service']['all']['orchestration-api-cfn']['interface']` - The interface to bind the service to

* `openstack['bind_service']['all']['orchestration-api-cloudwatch']['host']` - The IP address to bind the service to
* `openstack['bind_service']['all']['orchestration-api-cloudwatch']['port']` - The port to bind the service to
* `openstack['bind_service']['all']['orchestration-api-cloudwatch']['interface']` - The interface to bind the service to

If the value of the 'interface' attribute is non-nil, then the service will be bound to the first IP address on that interface and
the 'host' attribute will be ignored. 
If the value of the 'interface' attribute is nil (which is the default), then the service will be bound to the IP address specified
in the 'host' attribute.

Miscellaneous Options
---------------------

* `orchestration_auth_encryption_key` - Key used to encrypt authentication info in the database. Length of this key must be 16, 24 or 32 characters. Comes from secrets databag.

Testing
=====

Please refer to the [TESTING.md](TESTING.md) for instructions for testing the cookbook.

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
|                      |                                                    |
| **Copyright**        |  Copyright (c) 2013-2014, IBM Corp.                |
| **Copyright**        |  Copyright (c) 2014, SUSE Linux, GmbH.             |
| **Copyright**        |  Copyright (c) 2016, x-ion GmbH.                   |

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
