# encoding: UTF-8
name 'openstack-orchestration'
maintainer 'openstack-chef'
maintainer_email 'openstack-dev@lists.openstack.org'
license 'Apache 2.0'
description 'Installs and configures the Heat Service'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '13.0.0'
recipe 'openstack-orchestration::api', 'Start and configure the Heat API service'
recipe 'openstack-orchestration::api-cfn', 'Start and configure the Heat API CloudFormation service'
recipe 'openstack-orchestration::api-cloudwatch', 'Start and configure the Heat API CloudWatch service'
recipe 'openstack-orchestration::client', 'Installs packages for heat client'
recipe 'openstack-orchestration::common', 'Installs packages and configures a Heat Server'
recipe 'openstack-orchestration::engine', 'Sets up Heat database and starts Heat Engine service'
recipe 'openstack-orchestration::identity_registration', 'Registers Heat service, user and endpoints with Keystone'

%w(ubuntu redhat centos).each do |os|
  supports os
end

depends 'openstack-common', '>= 13.0.0'
depends 'openstack-identity', '>= 13.0.0'
