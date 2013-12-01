#
# Cookbook Name:: openstack-orchestration
# Recipe:: engine
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

class ::Chef::Recipe
  include ::Openstack
end

if node["openstack"]["orchestration"]["syslog"]["use"]
  include_recipe "openstack-common::logging"
end

package "python-keystone" do
  action :upgrade
end

platform_options = node["openstack"]["orchestration"]["platform"]

platform_options["heat_common_packages"].each do |pkg|
  package pkg do
    options platform_options["package_overrides"]

    action :upgrade
  end
end

db_type = node['openstack']['db']['orchestration']['db_type']
platform_options["#{db_type}_python_packages"].each do |pkg|
  package pkg do
    action :upgrade
  end
end

db_user = node["openstack"]["orchestration"]["db"]["username"]
db_pass = db_password "heat"
sql_connection = db_uri("orchestration", db_user, db_pass)

identity_endpoint = endpoint "identity-api"
identity_admin_endpoint = endpoint "identity-admin"
heat_api_endpoint = endpoint "orchestration-api"
heat_api_cfn_endpoint = endpoint "orchestration-api-cfn"
heat_api_cloudwatch_endpoint = endpoint "orchestration-api-cloudwatch"

service_pass = service_password "openstack-orchestration"

#TODO(jaypipes): Move this logic and stuff into the openstack-common
# library cookbook.
auth_uri = identity_endpoint.to_s
if node["openstack"]["orchestration"]["api"]["auth"]["version"] != "v2.0"
  # The auth_uri should contain /v2.0 in most cases, but if the
  # auth_version is v3.0, we leave it off. This is only necessary
  # for environments that need to support V3 non-default-domain
  # tokens, which is really the only reason to set version to
  # something other than v2.0 (the default)
  auth_uri = auth_uri.gsub('/v2.0', '')
end

if node["openstack"]["orchestration"]["mq"]["service_type"] == "rabbitmq"
  if node["openstack"]["orchestration"]["rabbit"]["ha"]
    rabbit_hosts = rabbit_servers
  end
  rabbit_pass = user_password node["openstack"]["orchestration"]["rabbit"]["username"]
end

directory "/etc/heat" do
  group  node["openstack"]["orchestration"]["group"]
  owner  node["openstack"]["orchestration"]["user"]
  mode 00700
  action :create
end

directory "/etc/heat/environment.d" do
  group  node["openstack"]["orchestration"]["group"]
  owner  node["openstack"]["orchestration"]["user"]
  mode 00700
  action :create
end

directory node["openstack"]["orchestration"]["api"]["auth"]["cache_dir"] do
  owner node["openstack"]["orchestration"]["user"]
  group node["openstack"]["orchestration"]["group"]
  mode 00700
end

template "/etc/heat/heat.conf" do
  source "heat.conf.erb"
  group  node["openstack"]["orchestration"]["group"]
  owner  node["openstack"]["orchestration"]["user"]
  mode   00644
  variables(
    :rabbit_password => rabbit_pass,
    :rabbit_hosts => rabbit_hosts,
    :auth_uri => auth_uri,
    :identity_admin_endpoint => identity_admin_endpoint,
    :service_pass => service_pass,
    :sql_connection => sql_connection,
    :heat_api_endpoint => heat_api_endpoint,
    :heat_api_cfn_endpoint => heat_api_cfn_endpoint,
    :heat_api_cloudwatch_endpoint => heat_api_cloudwatch_endpoint
  )
end

template "/etc/heat/environment.d/default.yaml" do
  source "default.yaml.erb"
  group  node["openstack"]["orchestration"]["group"]
  owner  node["openstack"]["orchestration"]["user"]
  mode   00644
end

execute "heat-manage db_sync" do
  command "heat-manage db_sync"
  action :run
end
