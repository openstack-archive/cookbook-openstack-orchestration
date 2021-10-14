#
# Cookbook:: openstack-orchestration
# Recipe:: api-cfn
#
# Copyright:: 2013-2021, IBM Corp.
# Copyright:: 2019-2021, Oregon State University
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

include_recipe 'openstack-orchestration::common'

platform_options = node['openstack']['orchestration']['platform']

package platform_options['heat_api_cfn_packages'] do
  options platform_options['package_overrides']
  action :upgrade
end

service 'heat-api-cfn' do
  service_name platform_options['heat_api_cfn_service']
  supports status: true, restart: true

  action [:enable, :start]
  subscribes :restart, 'template[/etc/heat/heat.conf]'
end
