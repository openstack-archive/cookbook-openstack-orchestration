# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-orchestration::identity_registration' do
  describe 'redhat' do
    let(:runner) { ChefSpec::SoloRunner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    include_context 'orchestration_stubs'

    it 'register heat orchestration service' do
      expect(chef_run).to create_service_openstack_identity_register(
        'Register Heat Orchestration Service'
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        service_name: 'heat',
        service_type: 'orchestration',
        service_description: 'Heat Orchestration Service',
        action: [:create_service]
      )
    end

    it 'register heat orchestration endpoint' do
      expect(chef_run).to create_endpoint_openstack_identity_register(
        'Register Heat Orchestration Endpoint'
      ).with(
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

    it 'register heat orchestration endpoint with custom region override' do
      node.set['openstack']['network']['region'] = 'region123'

      expect(chef_run).to create_endpoint_openstack_identity_register(
        'Register Heat Orchestration Endpoint'
      ).with(
        endpoint_region: 'region123',
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

    it 'register heat cloudformation service' do
      expect(chef_run).to create_service_openstack_identity_register(
        'Register Heat Cloudformation Service'
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        service_name: 'heat-cfn',
        service_type: 'cloudformation',
        service_description: 'Heat Cloudformation Service',
        action: [:create_service]
      )
    end

    it 'registers heat-api endpoint with different urls' do
      admin_url = 'https://admin.host:123/admin_path'
      public_url = 'http://public.host:456/public_path'
      internal_url = 'http://internal.host:456/internal_path'

      node.set['openstack']['endpoints']['admin']['orchestration-api']['uri'] = admin_url
      node.set['openstack']['endpoints']['public']['orchestration-api']['uri'] = public_url
      node.set['openstack']['endpoints']['internal']['orchestration-api']['uri'] = internal_url

      expect(chef_run).to create_endpoint_openstack_identity_register(
        'Register Heat Orchestration Endpoint'
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        service_type: 'orchestration',
        endpoint_region: 'RegionOne',
        endpoint_adminurl: admin_url,
        endpoint_internalurl: internal_url,
        endpoint_publicurl: public_url,
        action: [:create_endpoint]
      )
    end

    it 'register heat cloudformation endpoint' do
      expect(chef_run).to create_endpoint_openstack_identity_register(
        'Register Heat Cloudformation Endpoint'
      ).with(
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

    it 'register heat-cfn endpoint with all different urls' do
      admin_url = 'https://admin.host:123/admin_path'
      internal_url = 'http://internal.host:456/internal_path'
      public_url = 'https://public.host:789/public_path'

      node.set['openstack']['endpoints']['admin']['orchestration-api-cfn']['uri'] = admin_url
      node.set['openstack']['endpoints']['internal']['orchestration-api-cfn']['uri'] = internal_url
      node.set['openstack']['endpoints']['public']['orchestration-api-cfn']['uri'] = public_url
      expect(chef_run).to create_endpoint_openstack_identity_register(
        'Register Heat Cloudformation Endpoint'
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        service_type: 'cloudformation',
        endpoint_region: 'RegionOne',
        endpoint_adminurl: admin_url,
        endpoint_internalurl: internal_url,
        endpoint_publicurl: public_url,
        action: [:create_endpoint]
      )
    end

    it 'registers service tenant' do
      expect(chef_run).to create_tenant_openstack_identity_register(
        'Register Service Tenant'
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        tenant_name: 'service',
        tenant_description: 'Service Tenant'
      )
    end

    it 'registers heat service user' do
      expect(chef_run).to create_user_openstack_identity_register(
        'Register Heat Service User'
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        tenant_name: 'service',
        user_name: 'heat',
        user_pass: 'heat-pass',
        user_enabled: true,
        action: [:create_user]
      )
    end

    it 'grants service role to service user for service tenant' do
      expect(chef_run).to grant_role_openstack_identity_register(
        "Grant 'service' Role to heat User for service Tenant"
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        tenant_name: 'service',
        user_name: 'heat',
        role_name: 'service',
        action: [:grant_role]
      )
    end

    it 'does not create role for template defined users by default' do
      expect(chef_run).not_to create_role_openstack_identity_register(
        "Create '' Role for template defined users"
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        role_name: '',
        action: [:create_role]
      )
    end
  end
end
