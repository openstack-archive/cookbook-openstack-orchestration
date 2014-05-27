# encoding: UTF-8
name              'openstack-orchestration'
maintainer        'IBM, Inc.'
license           'Apache 2.0'
description       'Installs and configures the Heat Service'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '9.1.5'
recipe            'openstack-orchestration::api', 'Start and configure the Heat API service'
recipe            'openstack-orchestration::api-cfn', 'Start and configure the Heat API CloudFormation service'
recipe            'openstack-orchestration::api-cloudwatch', 'Start and configure the Heat API CloudWatch service'
recipe            'openstack-orchestration::client', 'Installs packages for heat client'
recipe            'openstack-orchestration::common', 'Installs packages and configures a Heat Server'
recipe            'openstack-orchestration::engine', 'Sets up Heat database and starts Heat Engine service'
recipe            'openstack-orchestration::identity_registration', 'Registers Heat service, user and endpoints with Keystone'

%w{ ubuntu fedora redhat centos }.each do |os|
  supports os
end

depends           'openstack-common', '~> 9.0'
depends           'openstack-identity', '~> 9.0'
