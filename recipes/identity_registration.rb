# encoding: UTF-8
#
# Cookbook Name:: openstack-orchestration
# Recipe:: identity_registration
#
# Copyright 2013, IBM Corp.
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

require 'uri'

class ::Chef::Recipe
  include ::Openstack
end

identity_admin_endpoint = admin_endpoint 'identity'

auth_url = ::URI.decode identity_admin_endpoint.to_s

admin_heat_endpoint = admin_endpoint 'orchestration-api'
internal_heat_endpoint = internal_endpoint 'orchestration-api'
public_heat_endpoint = public_endpoint 'orchestration-api'
admin_heat_cfn_endpoint = admin_endpoint 'orchestration-api-cfn'
internal_heat_cfn_endpoint = internal_endpoint 'orchestration-api-cfn'
public_heat_cfn_endpoint = public_endpoint 'orchestration-api-cfn'

service_pass = get_password 'service', 'openstack-orchestration'
service_project_name = node['openstack']['orchestration']['conf']['keystone_authtoken']['project_name']
service_user = node['openstack']['orchestration']['conf']['keystone_authtoken']['username']
service_role = node['openstack']['orchestration']['service_role']
service_type = 'orchestration'
service_name = 'heat'
service_domain_name = node['openstack']['orchestration']['conf']['keystone_authtoken']['user_domain_name']
admin_user = node['openstack']['identity']['admin_user']
admin_pass = get_password 'user', node['openstack']['identity']['admin_user']
admin_project = node['openstack']['identity']['admin_project']
admin_domain = node['openstack']['identity']['admin_domain_name']
region = node['openstack']['region']

# Do not configure a service/endpoint in keystone for heat-api-cloudwatch(Bug #1167927),
# See discussions on https://bugs.launchpad.net/heat/+bug/1167927

connection_params = {
  openstack_auth_url:     "#{auth_url}/auth/tokens",
  openstack_username:     admin_user,
  openstack_api_key:      admin_pass,
  openstack_project_name: admin_project,
  openstack_domain_name:    admin_domain,
}

# Register Orchestration Service
openstack_service service_name do
  type service_type
  connection_params connection_params
end

# Register Orchestration Public-Endpoint
openstack_endpoint service_type do
  service_name service_name
  interface 'public'
  url public_heat_endpoint.to_s
  region region
  connection_params connection_params
end

# Register Orchestration Internal-Endpoint
openstack_endpoint service_type do
  service_name service_name
  url internal_heat_endpoint.to_s
  region region
  connection_params connection_params
end

# Register Orchestration Admin-Endpoint
openstack_endpoint service_type do
  service_name service_name
  interface 'admin'
  url admin_heat_endpoint.to_s
  region region
  connection_params connection_params
end

# Register Service Tenant
openstack_project service_project_name do
  connection_params connection_params
end

# Register Service User
openstack_user service_user do
  project_name service_project_name
  role_name service_role
  password service_pass
  connection_params connection_params
end

## Grant Service role to Service User for Service Tenant ##
openstack_user service_user do
  role_name service_role
  project_name service_project_name
  connection_params connection_params
  action :grant_role
end

openstack_user service_user do
  domain_name service_domain_name
  role_name service_role
  user_name service_user
  connection_params connection_params
  action :grant_domain
end

# TODO: (MRV) Revert this change until a better solution can be found
# Bug: #1309123   reverts 1279577
# if node.run_list.include?('openstack-orchestration::api-cfn')

# Register Heat API Cloudformation Service
openstack_service 'heat-cfn' do
  type 'cloudformation'
  connection_params connection_params
end

# Register Heat API CloudFormation Public-Endpoint
openstack_endpoint 'cloudformation' do
  service_name 'heat-cfn'
  interface 'public'
  url public_heat_cfn_endpoint.to_s
  region region
  connection_params connection_params
end

# Register Heat API CloudFormation Internal-Endpoint
openstack_endpoint 'cloudformation' do
  service_name 'heat-cfn'
  url internal_heat_cfn_endpoint.to_s
  region region
  connection_params connection_params
end

# Register Heat API CloudFormation Admin-Endpoint
openstack_endpoint 'cloudformation' do
  service_name 'heat-cfn'
  interface 'admin'
  url admin_heat_cfn_endpoint.to_s
  region region
  connection_params connection_params
end

# Register Service Tenant
openstack_project service_project_name do
  connection_params connection_params
end

# Register Service User
openstack_user service_user do
  project_name service_project_name
  role_name service_role
  password service_pass
  connection_params connection_params
end

## Grant Service role to Service User for Service Tenant ##
openstack_user service_user do
  role_name service_role
  project_name service_project_name
  connection_params connection_params
  action :grant_role
end

openstack_user service_user do
  domain_name service_domain_name
  role_name service_role
  user_name service_user
  connection_params connection_params
  action :grant_domain
end
