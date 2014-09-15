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

class ::Chef::Recipe # rubocop:disable Documentation
  include ::Openstack
end

identity_admin_endpoint = endpoint 'identity-admin'

token = get_secret 'openstack_identity_bootstrap_token'
auth_url = ::URI.decode identity_admin_endpoint.to_s

heat_endpoint = endpoint 'orchestration-api'
heat_cfn_endpoint = endpoint 'orchestration-api-cfn'

service_pass = get_password 'service', 'openstack-orchestration'
service_tenant_name = node['openstack']['orchestration']['service_tenant_name']
service_user = node['openstack']['orchestration']['service_user']
service_role = node['openstack']['orchestration']['service_role']
region = node['openstack']['orchestration']['region']
stack_user_role = node['openstack']['orchestration']['heat_stack_user_role']

# Do not configure a service/endpoint in keystone for heat-api-cloudwatch(Bug #1167927),
# See discussions on https://bugs.launchpad.net/heat/+bug/1167927

# Register Heat API Service
openstack_identity_register 'Register Heat Orchestration Service' do
  auth_uri auth_url
  bootstrap_token token
  service_name 'heat'
  service_type 'orchestration'
  service_description 'Heat Orchestration Service'

  action :create_service
end

# Register Heat API Endpoint
openstack_identity_register 'Register Heat Orchestration Endpoint' do
  auth_uri auth_url
  bootstrap_token token
  service_type 'orchestration'
  endpoint_region region
  endpoint_adminurl heat_endpoint.to_s
  endpoint_internalurl heat_endpoint.to_s
  endpoint_publicurl heat_endpoint.to_s

  action :create_endpoint
end

# TODO: (MRV) Revert this change until a better solution can be found
# Bug: #1309123   reverts 1279577
# if node.run_list.include?('openstack-orchestration::api-cfn')

# Register Heat API Cloudformation Service
openstack_identity_register 'Register Heat Cloudformation Service' do
  auth_uri auth_url
  bootstrap_token token
  service_name 'heat-cfn'
  service_type 'cloudformation'
  service_description 'Heat Cloudformation Service'

  action :create_service
end

# Register Heat API CloudFormation Endpoint
openstack_identity_register 'Register Heat Cloudformation Endpoint' do
  auth_uri auth_url
  bootstrap_token token
  service_type 'cloudformation'
  endpoint_region region
  endpoint_adminurl heat_cfn_endpoint.to_s
  endpoint_internalurl heat_cfn_endpoint.to_s
  endpoint_publicurl heat_cfn_endpoint.to_s

  action :create_endpoint
end
# end

# Register Service Tenant
openstack_identity_register 'Register Service Tenant' do
  auth_uri auth_url
  bootstrap_token token
  tenant_name service_tenant_name
  tenant_description 'Service Tenant'
  tenant_enabled true # Not required as this is the default

  action :create_tenant
end

# Register Service User
openstack_identity_register 'Register Heat Service User' do
  auth_uri auth_url
  bootstrap_token token
  tenant_name service_tenant_name
  user_name service_user
  user_pass service_pass
  # String until https://review.openstack.org/#/c/29498/ merged
  user_enabled true

  action :create_user
end

## Grant Admin role to Service User for Service Tenant ##
openstack_identity_register "Grant '#{service_role}' Role to #{service_user} User for #{service_tenant_name} Tenant" do
  auth_uri auth_url
  bootstrap_token token
  tenant_name service_tenant_name
  user_name service_user
  role_name service_role

  action :grant_role
end

## Create role for heat template defined users ##
openstack_identity_register "Create '#{stack_user_role}' Role for template defined users" do
  auth_uri auth_url
  bootstrap_token token
  role_name stack_user_role

  action :create_role
  not_if { stack_user_role.nil? }
end

stack_user_domain_name = node['openstack']['orchestration']['stack_user_domain_name']
stack_domain_admin = node['openstack']['orchestration']['stack_domain_admin']

if !stack_user_role.nil? && !stack_user_domain_name.nil? && !stack_domain_admin.nil?
  stack_domain_admin_password = get_password 'user', stack_domain_admin
  admin_user = node['openstack']['identity']['admin_user']
  admin_pass = get_password 'user', admin_user

  execute 'heat-keystone-setup-domain' do
    environment 'OS_USERNAME' => admin_user,
                'OS_PASSWORD' => admin_pass,
                'OS_AUTH_URL' => auth_url,
                'HEAT_DOMAIN' => stack_user_domain_name,
                'HEAT_DOMAIN_ADMIN' => stack_domain_admin,
                'HEAT_DOMAIN_PASSWORD' => stack_domain_admin_password
    action :run
  end
end
