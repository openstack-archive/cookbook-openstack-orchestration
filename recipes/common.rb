# encoding: UTF-8
#
# Cookbook Name:: openstack-orchestration
# Recipe:: engine
#
# Copyright 2013, IBM Corp.
# Copyright 2014, SUSE Linux, GmbH.
#
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

class ::Chef::Recipe # rubocop:disable Documentation
  include ::Openstack
end

if node['openstack']['orchestration']['syslog']['use']
  include_recipe 'openstack-common::logging'
end

platform_options = node['openstack']['orchestration']['platform']

package 'python-keystoneclient' do
  options platform_options['package_overrides']
  action :upgrade
end

platform_options['heat_common_packages'].each do |pkg|
  package pkg do
    options platform_options['package_overrides']

    action :upgrade
  end
end

db_type = node['openstack']['db']['orchestration']['service_type']
node['openstack']['db']['python_packages'][db_type].each do |pkg|
  package pkg do
    action :upgrade
  end
end

db_user = node['openstack']['db']['orchestration']['username']
db_pass = get_password 'db', 'heat'
sql_connection = db_uri('orchestration', db_user, db_pass)

identity_endpoint = internal_endpoint 'identity-internal'
identity_admin_endpoint = admin_endpoint 'identity-admin'
heat_api_bind = internal_endpoint 'orchestration-api-bind'
heat_api_endpoint = internal_endpoint 'orchestration-api'
heat_api_cfn_bind = internal_endpoint 'orchestration-api-cfn-bind'
heat_api_cfn_endpoint = internal_endpoint 'orchestration-api-cfn'
heat_api_cloudwatch_bind = internal_endpoint 'orchestration-api-cloudwatch-bind'
heat_api_cloudwatch_endpoint = internal_endpoint 'orchestration-api-cloudwatch'

service_pass = get_password 'service', 'openstack-orchestration'
auth_encryption_key = get_password 'token', 'orchestration_auth_encryption_key'

stack_domain_admin_password = nil
if node['openstack']['orchestration']['stack_domain_admin']
  stack_domain_admin_password = get_password 'user', node['openstack']['orchestration']['stack_domain_admin']
end

ec2_auth_uri = auth_uri_transform identity_endpoint.to_s, node['openstack']['orchestration']['ec2authtoken']['auth']['version']
auth_uri = auth_uri_transform identity_endpoint.to_s, node['openstack']['orchestration']['api']['auth']['version']
identity_uri = identity_uri_transform(identity_admin_endpoint)

mq_service_type = node['openstack']['mq']['orchestration']['service_type']

if mq_service_type == 'rabbitmq'
  if node['openstack']['mq']['orchestration']['rabbit']['ha']
    rabbit_hosts = rabbit_servers
  end
  mq_password = get_password 'user', node['openstack']['mq']['orchestration']['rabbit']['userid']
elsif mq_service_type == 'qpid'
  mq_password = get_password 'user', node['openstack']['mq']['orchestration']['qpid']['username']
end

directory '/etc/heat' do
  group node['openstack']['orchestration']['group']
  owner node['openstack']['orchestration']['user']
  mode 00700
  action :create
end

directory '/etc/heat/environment.d' do
  group node['openstack']['orchestration']['group']
  owner node['openstack']['orchestration']['user']
  mode 00700
  action :create
end

directory node['openstack']['orchestration']['api']['auth']['cache_dir'] do
  owner node['openstack']['orchestration']['user']
  group node['openstack']['orchestration']['group']
  mode 00700
end

template '/etc/heat/heat.conf' do
  source 'heat.conf.erb'
  group node['openstack']['orchestration']['group']
  owner node['openstack']['orchestration']['user']
  mode 00640
  variables(
    stack_domain_admin_password: stack_domain_admin_password,
    mq_service_type: mq_service_type,
    mq_password: mq_password,
    rabbit_hosts: rabbit_hosts,
    ec2_auth_uri: ec2_auth_uri,
    auth_uri: auth_uri,
    identity_uri: identity_uri,
    service_pass: service_pass,
    auth_encryption_key: auth_encryption_key,
    sql_connection: sql_connection,
    heat_api_bind: heat_api_bind,
    heat_api_endpoint: heat_api_endpoint,
    heat_api_cfn_bind: heat_api_cfn_bind,
    heat_api_cfn_endpoint: heat_api_cfn_endpoint,
    heat_api_cloudwatch_bind: heat_api_cloudwatch_bind,
    heat_api_cloudwatch_endpoint: heat_api_cloudwatch_endpoint
  )
end

template '/etc/heat/environment.d/default.yaml' do
  source 'default.yaml.erb'
  group node['openstack']['orchestration']['group']
  owner node['openstack']['orchestration']['user']
  mode 00644
end

execute 'heat-manage db_sync' do
  user node['openstack']['orchestration']['user']
  group node['openstack']['orchestration']['group']
  command 'heat-manage db_sync'
  action :run
end
