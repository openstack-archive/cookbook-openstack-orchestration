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

class ::Chef::Recipe
  include ::Openstack
end

if node['openstack']['orchestration']['syslog']['use']
  include_recipe 'openstack-common::logging'
end

platform_options = node['openstack']['orchestration']['platform']

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

if node['openstack']['mq']['service_type'] == 'rabbit'
  node.default['openstack']['orchestration']['conf_secrets']['DEFAULT']['transport_url'] = rabbit_transport_url 'orchestration'
end

db_user = node['openstack']['db']['orchestration']['username']
db_pass = get_password 'db', 'heat'
stack_domain_admin = node['openstack']['orchestration']['conf']['DEFAULT']['stack_domain_admin']

identity_endpoint = internal_endpoint 'identity'
identity_admin_endpoint = admin_endpoint 'identity'

bind_services = node['openstack']['bind_service']['all']
api_bind = bind_services['orchestration-api']
api_cfn_bind = bind_services['orchestration-api-cfn']
api_cfn_endpoint = internal_endpoint 'orchestration-api-cfn'
api_cw_bind = bind_services['orchestration-api-cloudwatch']
api_cw_endpoint = internal_endpoint 'orchestration-api-cloudwatch'

ec2_auth_uri = auth_uri_transform identity_endpoint.to_s, node['openstack']['orchestration']['ec2authtoken']['auth']['version']
auth_uri = auth_uri_transform identity_endpoint.to_s, node['openstack']['orchestration']['api']['auth']['version']
base_auth_uri = identity_uri_transform auth_uri

# We need these URIs without their default path
metadata_uri = "#{api_cfn_endpoint.scheme}://#{api_cfn_endpoint.host}:#{api_cfn_endpoint.port}"
watch_uri = "#{api_cw_endpoint.scheme}://#{api_cw_endpoint.host}:#{api_cw_endpoint.port}"

# define attributes that are needed in the heat.conf
node.default['openstack']['orchestration']['conf'].tap do |conf|
  conf['DEFAULT']['heat_metadata_server_url'] = metadata_uri
  conf['DEFAULT']['heat_waitcondition_server_url'] = "#{api_cfn_endpoint}/waitcondition"
  conf['DEFAULT']['heat_watch_server_url'] = watch_uri
  conf['DEFAULT']['region_name_for_services'] = node['openstack']['region']
  conf['clients_keystone']['auth_uri'] = base_auth_uri
  conf['ec2authtoken']['auth_uri'] = ec2_auth_uri
  conf['heat_api']['bind_host'] = bind_address api_bind
  conf['heat_api']['bind_port'] = api_bind['port']
  conf['heat_api_cfn']['bind_host'] = bind_address api_cfn_bind
  conf['heat_api_cfn']['bind_port'] = api_cfn_bind['port']
  conf['heat_api_cloudwatch']['bind_host'] = bind_address api_cw_bind
  conf['heat_api_cloudwatch']['bind_port'] = api_cw_bind['port']
  conf['keystone_authtoken']['auth_url'] = auth_uri
  conf['trustee']['auth_url'] = identity_admin_endpoint
end

# define secrets that are needed in the heat.conf
node.default['openstack']['orchestration']['conf_secrets'].tap do |conf_secrets|
  conf_secrets['DEFAULT']['auth_encryption_key'] =
    get_password 'token', 'orchestration_auth_encryption_key'
  conf_secrets['database']['connection'] =
    db_uri('orchestration', db_user, db_pass)
  conf_secrets['keystone_authtoken']['password'] =
    get_password 'service', 'openstack-orchestration'
  conf_secrets['trustee']['password'] =
    get_password 'service', 'openstack-orchestration'
  conf_secrets['DEFAULT']['stack_domain_admin_password'] =
    get_password 'user', stack_domain_admin
end

# merge all config options and secrets to be used in the heat.conf
heat_conf_options = merge_config_options 'orchestration'

directory '/etc/heat' do
  owner node['openstack']['orchestration']['user']
  group node['openstack']['orchestration']['group']
  mode 0o0750
  action :create
end

directory '/etc/heat/environment.d' do
  owner node['openstack']['orchestration']['user']
  group node['openstack']['orchestration']['group']
  mode 0o0750
  action :create
end

template '/etc/heat/heat.conf' do
  source 'openstack-service.conf.erb'
  cookbook 'openstack-common'
  owner node['openstack']['orchestration']['user']
  group node['openstack']['orchestration']['group']
  mode 0o0640
  variables(
    service_config: heat_conf_options
  )
end

template '/etc/heat/environment.d/default.yaml' do
  source 'default.yaml.erb'
  owner node['openstack']['orchestration']['user']
  group node['openstack']['orchestration']['group']
  mode 0o0644
end

execute 'heat-manage db_sync' do
  user node['openstack']['orchestration']['user']
  group node['openstack']['orchestration']['group']
  command 'heat-manage db_sync'
  action :run
end
