name             'openstack-orchestration'
maintainer       'openstack-chef'
maintainer_email 'openstack-discuss@lists.openstack.org'
license          'Apache-2.0'
description      'Installs and configures the Heat Service'
version          '18.0.0'

recipe 'openstack-orchestration::api-cfn', 'Configure and start heat-api-cfn service'
recipe 'openstack-orchestration::api', 'Configure and start heat-api service'
recipe 'openstack-orchestration::common', 'Installs the heat packages and setup configuration for Heat.'
recipe 'openstack-orchestration::engine', 'Setup the heat database and start heat-engine service'
recipe 'openstack-orchestration::identity_registration', 'Registers the Heat API endpoint, heat service and user'

%w(ubuntu redhat centos).each do |os|
  supports os
end

depends 'openstackclient'
depends 'openstack-common', '>= 18.0.0'
depends 'openstack-identity', '>= 18.0.0'

issues_url 'https://launchpad.net/openstack-chef'
source_url 'https://opendev.org/openstack/cookbook-openstack-orchestration'
chef_version '>= 14.0'
