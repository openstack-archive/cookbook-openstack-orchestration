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

* `openstack['orchestration']['verbose']` - Enables/disables verbose output for heat services.
* `openstack['orchestration']['debug']` - Enables/disables debug output for heat services.
* `openstack['orchestration']['identity_service_chef_role']` - The name of the Chef role that installs the Keystone Service API
* `openstack['orchestration']['rabbit_server_chef_role']` - The name of the Chef role that knows about the message queue server
* `openstack['orchestration']['user']` - User heat runs as
* `openstack['orchestration']['group']` - Group heat runs as
* `openstack['orchestration']['num_engine_workers']` - Number of heat-engine processes to fork and run.
* `openstack['orchestration']['api']['workers']` - Number of workers for Heat api service.
* `openstack['orchestration']['api_cfn']['workers']` - Number of workers for Heat api cfn service.
* `openstack['orchestration']['api_cloudwatch']['workers']` - Number of workers for Heat api cloudwatch service.
* `openstack['orchestration']['db']['username']` - Username for heat database access
* `openstack['orchestration']['api']['adminURL']` - Used when registering heat endpoint with keystone
* `openstack['orchestration']['api']['internalURL']` - Used when registering heat endpoint with keystone
* `openstack['orchestration']['api']['publicURL']` - Used when registering heat endpoint with keystone
* `openstack['orchestration']['service_tenant_name']` - Tenant name used by heat when interacting with keystone - used in the API and registry paste.ini files
* `openstack['orchestration']['service_user']` - User name used by heat when interacting with keystone - used in the API and registry paste.ini files
* `openstack['orchestration']['service_role']` - User role used by heat when interacting with keystone - used in the API and registry paste.ini files
* `openstack['orchestration']['api']['auth']['cache_dir']` - Defaults to `/var/cache/heat`. Directory where `auth_token` middleware writes certificates for heat
* `openstack['orchestration']['syslog']['use']` - Should heat log to syslog?
* `openstack['orchestration']['syslog']['facility']` - Which facility heat should use when logging in python style (for example, `LOG_LOCAL1`)
* `openstack['orchestration']['syslog']['config_facility']` - Which facility heat should use when logging in rsyslog style (for example, local1)
* `openstack['orchestration']['rpc_thread_pool_size']` - size of RPC thread pool
* `openstack['orchestration']['rpc_conn_pool_size']` - size of RPC connection pool
* `openstack['orchestration']['rpc_response_timeout']` - seconds to wait for a response from call or multicall
* `openstack['orchestration']['platform']` - hash of platform specific package/service names and options
* `openstack['orchestration']['api']['auth']['version']` - Select v2.0 or v3.0. Default v2.0. The auth API version used to interact with identity service.
* `openstack['orchestration']['api']['auth']['memcached_servers']` - A list of memcached server(s) for caching
* `openstack['orchestration']['api']['auth']['memcache_security_strategy']` - Whether token data should be authenticated or authenticated and encrypted. Acceptable values are MAC or ENCRYPT.
* `openstack['orchestration']['api']['auth']['memcache_secret_key']` - This string is used for key derivation.
* `openstack['orchestration']['api']['auth']['hash_algorithms']` - Hash algorithms to use for hashing PKI tokens.
* `openstack['orchestration']['api']['auth']['cafile']` - A PEM encoded Certificate Authority to use when verifying HTTPs connections.
* `openstack['orchestration']['api']['auth']['insecure']` - Whether to allow the client to perform insecure SSL (https) requests.

Clients configurations
----------------------
* `openstack['orchestration']['clients']['ca_file']` - A PEM encoded Certificate Authority to use for clients when verifying HTTPs connections.
* `openstack['orchestration']['clients']['cert_file']` - Cert file to use for clients when verifying HTTPs connections.
* `openstack['orchestration']['clients']['key_file']` - Private key file to use for clients when verifying HTTPs connections.
* `openstack['orchestration']['clients']['insecure']` - Whether to allow insecure SSL (https) requests when calling clients.

clients_ceilometer configurations
---------------------------------
* `openstack['orchestration']['clients_ceilometer']['ca_file']` - A PEM encoded Certificate Authority to use for clients_ceilometer when verifying HTTPs connections.
* `openstack['orchestration']['clients_ceilometer']['cert_file']` - Cert file to use for clients_ceilometer when verifying HTTPs connections.
* `openstack['orchestration']['clients_ceilometer']['key_file']` - Private key file to use for clients_ceilometer when verifying HTTPs connections.
* `openstack['orchestration']['clients_ceilometer']['insecure']` - Whether to allow insecure SSL (https) requests when calling clients_ceilometer.

clients_cinder configurations
-----------------------------
* `openstack['orchestration']['clients_cinder']['ca_file']` - A PEM encoded Certificate Authority to use for clients_cinder when verifying HTTPs connections.
* `openstack['orchestration']['clients_cinder']['cert_file']` - Cert file to use for clients_cinder when verifying HTTPs connections.
* `openstack['orchestration']['clients_cinder']['key_file']` - Private key file to use for clients_cinder when verifying HTTPs connections.
* `openstack['orchestration']['clients_cinder']['insecure']` - Whether to allow insecure SSL (https) requests when calling clients_cinder.

clients_glance configurations
-----------------------------
* `openstack['orchestration']['clients_glance']['ca_file']` - A PEM encoded Certificate Authority to use for clients_glance when verifying HTTPs connections.
* `openstack['orchestration']['clients_glance']['cert_file']` - Cert file to use for clients_glance when verifying HTTPs connections.
* `openstack['orchestration']['clients_glance']['key_file']` - Private key file to use for clients_glance when verifying HTTPs connections.
* `openstack['orchestration']['clients_glance']['insecure']` - Whether to allow insecure SSL (https) requests when calling clients_glance.

clients_heat configurations
---------------------------
* `openstack['orchestration']['clients_heat']['ca_file']` - A PEM encoded Certificate Authority to use for clients_heat when verifying HTTPs connections.
* `openstack['orchestration']['clients_heat']['cert_file']` - Cert file to use for clients_heat when verifying HTTPs connections.
* `openstack['orchestration']['clients_heat']['key_file']` - Private key file to use for clients_heat when verifying HTTPs connections.
* `openstack['orchestration']['clients_heat']['insecure']` - Whether to allow insecure SSL (https) requests when calling clients_heat.

clients_keystone configurations
-------------------------------
* `openstack['orchestration']['clients_keystone']['ca_file']` - A PEM encoded Certificate Authority to use for clients_keystone when verifying HTTPs connections.
* `openstack['orchestration']['clients_keystone']['cert_file']` - Cert file to use for clients_keystone when verifying HTTPs connections.
* `openstack['orchestration']['clients_keystone']['key_file']` - Private key file to use for clients_keystone when verifying HTTPs connections.
* `openstack['orchestration']['clients_keystone']['insecure']` - Whether to allow insecure SSL (https) requests when calling clients_keystone.

clients_neutron configurations
------------------------------
* `openstack['orchestration']['clients_neutron']['ca_file']` - A PEM encoded Certificate Authority to use for clients_neutron when verifying HTTPs connections.
* `openstack['orchestration']['clients_neutron']['cert_file']` - Cert file to use for clients_neutron when verifying HTTPs connections.
* `openstack['orchestration']['clients_neutron']['key_file']` - Private key file to use for clients_neutron when verifying HTTPs connections.
* `openstack['orchestration']['clients_neutron']['insecure']` - Whether to allow insecure SSL (https) requests when calling clients_neutron.

clients_nova configurations
---------------------------------
* `openstack['orchestration']['clients_nova']['ca_file']` - A PEM encoded Certificate Authority to use for clients_nova when verifying HTTPs connections.
* `openstack['orchestration']['clients_nova']['cert_file']` - Cert file to use for clients_nova when verifying HTTPs connections.
* `openstack['orchestration']['clients_nova']['key_file']` - Private key file to use for clients_nova when verifying HTTPs connections.
* `openstack['orchestration']['clients_nova']['insecure']` - Whether to allow insecure SSL (https) requests when calling clients_nova.

Notification definitions
------------------------
* `openstack['orchestration']['notification_driver']` - driver
* `openstack['orchestration']['default_notification_level']` - level
* `openstack['orchestration']['default_publisher_id']` - publisher id
* `openstack['orchestration']['list_notifier_drivers']` - list of drivers
* `openstack['orchestration']['notification_topics']` - notifications topics

MQ attributes
-------------
* `openstack["orchestration"]["mq"]["service_type"]` - Select qpid or rabbitmq. default rabbitmq
TODO: move rabbit parameters under openstack["orchestration"]["mq"]
* `openstack["orchestration"]["rabbit"]["username"]` - Username for nova rabbit access
* `openstack["orchestration"]["rabbit"]["vhost"]` - The rabbit vhost to use
* `openstack["orchestration"]["rabbit"]["port"]` - The rabbit port to use
* `openstack["orchestration"]["rabbit"]["host"]` - The rabbit host to use (must set when `openstack["orchestration"]["rabbit"]["ha"]` false).
* `openstack["orchestration"]["rabbit"]["ha"]` - Whether or not to use rabbit ha

* `openstack["orchestration"]["mq"]["qpid"]["host"]` - The qpid host to use
* `openstack["orchestration"]["mq"]["qpid"]["port"]` - The qpid port to use
* `openstack["orchestration"]["mq"]["qpid"]["qpid_hosts"]` - Qpid hosts. TODO. use only when ha is specified.
* `openstack["orchestration"]["mq"]["qpid"]["username"]` - Username for qpid connection
* `openstack["orchestration"]["mq"]["qpid"]["password"]` - Password for qpid connection
* `openstack["orchestration"]["mq"]["qpid"]["sasl_mechanisms"]` - Space separated list of SASL mechanisms to use for auth
* `openstack["orchestration"]["mq"]["qpid"]["reconnect_timeout"]` - The number of seconds to wait before deciding that a reconnect attempt has failed.
* `openstack["orchestration"]["mq"]["qpid"]["reconnect_limit"]` - The limit for the number of times to reconnect before considering the connection to be failed.
* `openstack["orchestration"]["mq"]["qpid"]["reconnect_interval_min"]` - Minimum number of seconds between connection attempts.
* `openstack["orchestration"]["mq"]["qpid"]["reconnect_interval_max"]` - Maximum number of seconds between connection attempts.
* `openstack["orchestration"]["mq"]["qpid"]["reconnect_interval"]` - Equivalent to setting qpid_reconnect_interval_min and qpid_reconnect_interval_max to the same value.
* `openstack["orchestration"]["mq"]["qpid"]["heartbeat"]` - Seconds between heartbeat messages sent to ensure that the connection is still alive.
* `openstack["orchestration"]["mq"]["qpid"]["protocol"]` - Protocol to use. Default tcp.
* `openstack["orchestration"]["mq"]["qpid"]["tcp_nodelay"]` - Disable the Nagle algorithm. default disabled.

The following attributes are defined in attributes/default.rb of the common cookbook, but are documented here due to their relevance:

* `openstack['endpoints']['orchestration-api-bind']['host']` - The IP address to bind the service to
* `openstack['endpoints']['orchestration-api-bind']['port']` - The port to bind the service to
* `openstack['endpoints']['orchestration-api-bind']['bind_interface']` - The interface name to bind the service to

* `openstack['endpoints']['orchestration-api-cfn-bind']['host']` - The IP address to bind the service to
* `openstack['endpoints']['orchestration-api-cfn-bind']['port']` - The port to bind the service to
* `openstack['endpoints']['orchestration-api-cfn-bind']['bind_interface']` - The interface name to bind the-cfn service to

* `openstack['endpoints']['orchestration-api-cloudwatch-bind']['host']` - The IP address to bind the service to
* `openstack['endpoints']['orchestration-api-cloudwatch-bind']['port']` - The port to bind the service to
* `openstack['endpoints']['orchestration-api-cloudwatch-bind']['bind_interface']` - The interface name to bind the-cloudwatch service to

If the value of the 'bind_interface' attribute is non-nil, then the service will be bound to the first IP address on that interface. If the value of the 'bind_interface' attribute is nil, then the service will be bound to the IP address specifie>

Miscellaneous Options
---------------------

Arrays whose elements will be copied exactly into the respective config files (contents e.g. ['option1=value1', 'option2=value2']).

* `openstack["orchestration"]["misc_heat"]` - Array of bare options for `heat.conf`.
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
|                      |                                                    |
| **Copyright**        |  Copyright (c) 2013-2014, IBM Corp.                |
| **Copyright**        |  Copyright (c) 2014, SUSE Linux, GmbH.             |

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
