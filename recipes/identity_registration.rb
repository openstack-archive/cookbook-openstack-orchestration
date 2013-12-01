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

require "uri"

class ::Chef::Recipe
  include ::Openstack
end

identity_admin_endpoint = endpoint "identity-admin"

token = secret "secrets", "openstack_identity_bootstrap_token"
auth_url = ::URI.decode identity_admin_endpoint.to_s

heat_endpoint = endpoint "orchestration-api"
heat_cfn_endpoint = endpoint "orchestration-api-cfn"

service_pass = service_password "openstack-orchestration"
service_tenant_name = node["openstack"]["orchestration"]["service_tenant_name"]
service_user = node["openstack"]["orchestration"]["service_user"]
service_role = node["openstack"]["orchestration"]["service_role"]
region = node["openstack"]["orchestration"]["region"]

#Do not configure a service/endpoint in keystone for heat-api-cloudwatch(Bug #1167927),
#See discussions on https://bugs.launchpad.net/heat/+bug/1167927

# Register Heat API Service
openstack_identity_register "Register Heat Orchestration Service" do
  auth_uri auth_url
  bootstrap_token token
  service_name "heat"
  service_type "orchestration"
  service_description "Heat Orchestration Service"

  action :create_service
end

# Register Heat API Cloudformation Service
openstack_identity_register "Register Heat Cloudformation Service" do
  auth_uri auth_url
  bootstrap_token token
  service_name "heat-cfn"
  service_type "cloudformation"
  service_description "Heat Cloudformation Service"

  action :create_service
end

# Register Heat API Endpoint
openstack_identity_register "Register Heat Orchestration Endpoint" do
  auth_uri auth_url
  bootstrap_token token
  service_type "orchestration"
  endpoint_region region
  endpoint_adminurl heat_endpoint.to_s
  endpoint_internalurl heat_endpoint.to_s
  endpoint_publicurl heat_endpoint.to_s

  action :create_endpoint
end

# Register Heat API CloudFormation Endpoint
openstack_identity_register "Register Heat Cloudformation Endpoint" do
  auth_uri auth_url
  bootstrap_token token
  service_type "cloudformation"
  endpoint_region region
  endpoint_adminurl heat_cfn_endpoint.to_s
  endpoint_internalurl heat_cfn_endpoint.to_s
  endpoint_publicurl heat_cfn_endpoint.to_s

  action :create_endpoint
end

# Register Service Tenant
openstack_identity_register "Register Service Tenant" do
  auth_uri auth_url
  bootstrap_token token
  tenant_name service_tenant_name
  tenant_description "Service Tenant"
  tenant_enabled true # Not required as this is the default

  action :create_tenant
end

# Register Service User
openstack_identity_register "Register Heat Service User" do
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
