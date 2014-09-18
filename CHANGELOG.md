# CHANGELOG for cookbook-openstack-orchestration

This file is used to list changes made in each version of cookbook-openstack-orchestration

## 10.0.0
* Upgrading to Juno
* Sync conf files with Juno
* Upgrading berkshelf from 2.0.18 to 3.1.5
* Update mode for heat.conf from 644 to 640
* Add cafile, memcached_servers, memcache_security_strategy, memcache_secret_key, insecure and hash_algorithms so that they are configurable.

## 9.2.0
* python_packages database client attributes have been migrated to
the -common cookbook
* bump berkshelf to 2.0.18 to allow Supermarket support
* fix fauxhai version for suse and redhat

## 9.1.6
* Allow region_name_for_services to be overridden

## 9.1.5
* Fix to properly set signing_dir

## 9.1.4
* Fix ability to configure separate endpoint and bind addresses

## 9.1.3
* Fix package reference, need keystone client not keystone

## 9.1.2
* Fix endpoint ref in heat conf

## 9.1.1
* Revert bug 1279577 Create api-cfn identity registrations bug 1309123

## 9.1.0
* Add notification attributes

## 9.0.1
* Remove policy file

## 9.0.0
* Upgrade to Icehouse

## 8.1.1
### Bug
* Fix the DB2 ODBC driver issue

## 8.1.0
* Add client recipe

## 8.0.0:
* Initial release of cookbook-openstack-orchestration.
