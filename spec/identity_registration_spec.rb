# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-orchestration::identity_registration' do
  before do
    orchestration_stubs
    @chef_run = ::ChefSpec::Runner.new ::REDHAT_OPTS
    @chef_run.converge 'openstack-orchestration::identity_registration'
  end

  it 'Register Heat Orchestration Service' do
    resource = @chef_run.find_resource(
      'openstack-identity_register',
      'Register Heat Orchestration Service'
    ).to_hash

    expect(resource).to include(
      auth_uri: 'http://127.0.0.1:35357/v2.0',
      bootstrap_token: 'bootstrap-token',
      service_name: 'heat',
      service_type: 'orchestration',
      service_description: 'Heat Orchestration Service',
      action: [:create_service]
    )
  end

  it 'Register Heat Orchestration Endpoint' do
    resource = @chef_run.find_resource(
      'openstack-identity_register',
      'Register Heat Orchestration Endpoint'
    ).to_hash

    expect(resource).to include(
      auth_uri: 'http://127.0.0.1:35357/v2.0',
      bootstrap_token: 'bootstrap-token',
      service_type: 'orchestration',
      endpoint_region: 'RegionOne',
      endpoint_adminurl: 'http://127.0.0.1:8004/v1/%(tenant_id)s',
      endpoint_internalurl: 'http://127.0.0.1:8004/v1/%(tenant_id)s',
      endpoint_publicurl: 'http://127.0.0.1:8004/v1/%(tenant_id)s',
      action: [:create_endpoint]
    )
  end

  describe 'openstack-orchestration::identity_registration-cfn' do
    before do
      orchestration_stubs
      @chef_run = ::ChefSpec::Runner.new ::REDHAT_OPTS
      @chef_run.converge 'openstack-orchestration::identity_registration'
# TODO: (MRV) Revert this change until a better solution can be found
# Bug: #1309123   reverts 1279577
#                         'openstack-orchestration::api-cfn'
    end

    it 'Register Heat Cloudformation Service' do
      resource = @chef_run.find_resource(
        'openstack-identity_register',
        'Register Heat Cloudformation Service'
      ).to_hash

      expect(resource).to include(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        service_name: 'heat-cfn',
        service_type: 'cloudformation',
        service_description: 'Heat Cloudformation Service',
        action: [:create_service]
      )
    end

    # Pending on https://review.openstack.org/#/c/59088/
    it 'Register Heat Cloudformation Endpoint' do
      resource = @chef_run.find_resource(
        'openstack-identity_register',
        'Register Heat Cloudformation Endpoint'
      ).to_hash

      expect(resource).to include(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        service_type: 'cloudformation',
        endpoint_region: 'RegionOne',
        endpoint_adminurl: 'http://127.0.0.1:8000/v1',
        endpoint_internalurl: 'http://127.0.0.1:8000/v1',
        endpoint_publicurl: 'http://127.0.0.1:8000/v1',
        action: [:create_endpoint]
      )
    end
  end

  it 'registers service user' do
    resource = @chef_run.find_resource(
      'openstack-identity_register',
      'Register Heat Service User'
    ).to_hash

    expect(resource).to include(
      auth_uri: 'http://127.0.0.1:35357/v2.0',
      bootstrap_token: 'bootstrap-token',
      tenant_name: 'service',
      user_name: 'heat',
      user_pass: 'heat-pass',
      user_enabled: true,
      action: [:create_user]
    )
  end

  it 'grants admin role to service user for service tenant' do
    resource = @chef_run.find_resource(
      'openstack-identity_register',
      "Grant 'admin' Role to heat User for service Tenant"
    ).to_hash

    expect(resource).to include(
      auth_uri: 'http://127.0.0.1:35357/v2.0',
      bootstrap_token: 'bootstrap-token',
      tenant_name: 'service',
      user_name: 'heat',
      role_name: 'admin',
      action: [:grant_role]
    )
  end

end
