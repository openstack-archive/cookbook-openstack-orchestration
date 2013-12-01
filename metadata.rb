name              "openstack-orchestration"
maintainer        "IBM, Inc."
license           "Apache 2.0"
description       "Installs and configures the Heat Service"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "8.0.0"
recipe            "openstack-orchestration::common", "Installs packages and set up configuraitions for a Heat Server"
recipe            "openstack-orchestration::api", "Start Heat Api service and set up configuraions for this service"
recipe            "openstack-orchestration::api-cfn", "Start Heat Api CloudFormation service and set up configuraions for this service"
recipe            "openstack-orchestration::api-cloudwatch", "Start Heat Api CloudWatch service and set up configuraions for this service"
recipe            "openstack-orchestration::engine", "Setup Heat database and start Heat Engine service"
recipe            "openstack-orchestration::identity_registration", "Registers Heat service, user and endpoints with Keystone"

%w{ ubuntu fedora redhat centos }.each do |os|
  supports os
end

depends           "openstack-common", "~> 8.0"
depends           "openstack-identity", "~> 8.0"
