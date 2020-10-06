#
# Cookbook:: openstack-orchestration
# Recipe:: dashboard
#
# Copyright:: 2018, x-ion Gmbh
# Copyright:: 2020, Oregon State University
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

platform_options = node['openstack']['orchestration']['platform']

package platform_options['heat_dashboard_packages'] do
  options platform_options['package_overrides']
  action :upgrade
end
