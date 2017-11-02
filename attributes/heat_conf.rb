# encoding: UTF-8
#
# Cookbook Name:: openstack-orchestration
# Attributes:: default
#
# Copyright 2013, IBM Corp.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['openstack']['orchestration']['conf']['DEFAULT']['log_dir'] = '/var/log/heat'
default['openstack']['orchestration']['conf']['DEFAULT']['stack_domain_admin'] = 'heat_domain_admin'
default['openstack']['orchestration']['conf']['DEFAULT']['stack_user_domain_name'] = 'heat'
default['openstack']['orchestration']['conf']['oslo_messaging_notifications']['driver'] = 'heat.openstack.common.notifier.rpc_notifier'
default['openstack']['orchestration']['conf']['keystone_authtoken']['auth_type'] = 'v3password'
default['openstack']['orchestration']['conf']['keystone_authtoken']['username'] = 'heat'
default['openstack']['orchestration']['conf']['keystone_authtoken']['project_name'] = 'service'
default['openstack']['orchestration']['conf']['keystone_authtoken']['project_domain_name'] = 'Default'
default['openstack']['orchestration']['conf']['keystone_authtoken']['user_domain_name'] = 'Default'
default['openstack']['orchestration']['conf']['trustee']['auth_type'] = 'v3password'
default['openstack']['orchestration']['conf']['trustee']['username'] = 'heat'
default['openstack']['orchestration']['conf']['trustee']['user_domain_name'] = node['openstack']['orchestration']['conf']['keystone_authtoken']['user_domain_name']
