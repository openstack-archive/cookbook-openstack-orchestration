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

    it 'register heat-api endpoint with different admin url' do
      admin_url = 'https://admin.host:123/admin_path'
      general_url = 'http://general.host:456/general_path'

      # Set the general endpoint
      node.set['openstack']['endpoints']['orchestration-api']['uri'] = general_url
      # Set the admin endpoint override
      node.set['openstack']['endpoints']['admin']['orchestration-api']['uri'] = admin_url

      expect(chef_run).to create_endpoint_openstack_identity_register(
        'Register Heat Orchestration Endpoint'
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        service_type: 'orchestration',
        endpoint_region: 'RegionOne',
        endpoint_adminurl: admin_url,
        endpoint_internalurl: general_url,
        endpoint_publicurl: general_url,
        action: [:create_endpoint]
      )
    end

    it 'register heat-api endpoint with different public url' do
      public_url = 'https://public.host:789/public_path'
      general_url = 'http://general.host:456/general_path'

      # Set the general endpoint
      node.set['openstack']['endpoints']['orchestration-api']['uri'] = general_url
      # Set the public endpoint override
      node.set['openstack']['endpoints']['public']['orchestration-api']['uri'] = public_url

      expect(chef_run).to create_endpoint_openstack_identity_register(
        'Register Heat Orchestration Endpoint'
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        service_type: 'orchestration',
        endpoint_region: 'RegionOne',
        endpoint_adminurl: general_url,
        endpoint_internalurl: general_url,
        endpoint_publicurl: public_url,
        action: [:create_endpoint]
      )
    end

    it 'register heat-api endpoint with different internal url' do
      internal_url = 'http://internal.host:456/internal_path'
      general_url = 'http://general.host:456/general_path'

      # Set general endpoint
      node.set['openstack']['endpoints']['orchestration-api']['uri'] = general_url
      # Set the internal endpoint override
      node.set['openstack']['endpoints']['internal']['orchestration-api']['uri'] = internal_url

      expect(chef_run).to create_endpoint_openstack_identity_register(
        'Register Heat Orchestration Endpoint'
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        service_type: 'orchestration',
        endpoint_region: 'RegionOne',
        endpoint_adminurl: general_url,
        endpoint_internalurl: internal_url,
        endpoint_publicurl: general_url,
        action: [:create_endpoint]
      )
    end

    it 'register heat-api endpoint with all different urls' do
      admin_url = 'https://admin.host:123/admin_path'
      internal_url = 'http://internal.host:456/internal_path'
      public_url = 'https://public.host:789/public_path'

      node.set['openstack']['endpoints']['admin']['orchestration-api']['uri'] = admin_url
      node.set['openstack']['endpoints']['internal']['orchestration-api']['uri'] = internal_url
      node.set['openstack']['endpoints']['public']['orchestration-api']['uri'] = public_url

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

    it 'register heat-cfn endpoint with different admin url' do
      admin_url = 'https://admin.host:123/admin_path'
      general_url = 'http://general.host:456/general_path'
      # Set the general endpoint
      node.set['openstack']['endpoints']['orchestration-api-cfn']['uri'] = general_url
      # Set the admin endpoint override
      node.set['openstack']['endpoints']['admin']['orchestration-api-cfn']['uri'] = admin_url
      expect(chef_run).to create_endpoint_openstack_identity_register(
        'Register Heat Cloudformation Endpoint'
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        service_type: 'cloudformation',
        endpoint_region: 'RegionOne',
        endpoint_adminurl: admin_url,
        endpoint_internalurl: general_url,
        endpoint_publicurl: general_url,
        action: [:create_endpoint]
      )
    end

    it 'register heat-cfn endpoint with different public url' do
      public_url = 'https://public.host:789/public_path'
      general_url = 'http://general.host:456/general_path'
      # Set the general endpoint
      node.set['openstack']['endpoints']['orchestration-api-cfn']['uri'] = general_url
      # Set the public endpoint override
      node.set['openstack']['endpoints']['public']['orchestration-api-cfn']['uri'] = public_url
      expect(chef_run).to create_endpoint_openstack_identity_register(
        'Register Heat Cloudformation Endpoint'
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        service_type: 'cloudformation',
        endpoint_region: 'RegionOne',
        endpoint_adminurl: general_url,
        endpoint_internalurl: general_url,
        endpoint_publicurl: public_url,
        action: [:create_endpoint]
      )
    end

    it 'register heat-cfn endpoint with different internal url' do
      internal_url = 'http://internal.host:456/internal_path'
      general_url = 'http://general.host:456/general_path'
      # Set the general endpoint
      node.set['openstack']['endpoints']['orchestration-api-cfn']['uri'] = general_url
      # Set the internal endpoint override
      node.set['openstack']['endpoints']['internal']['orchestration-api-cfn']['uri'] = internal_url
      expect(chef_run).to create_endpoint_openstack_identity_register(
        'Register Heat Cloudformation Endpoint'
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        service_type: 'cloudformation',
        endpoint_region: 'RegionOne',
        endpoint_adminurl: general_url,
        endpoint_internalurl: internal_url,
        endpoint_publicurl: general_url,
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

    it 'creates role for template defined users' do
      node.set['openstack']['orchestration']['heat_stack_user_role'] = 'heat_stack_user'
      expect(chef_run).to create_role_openstack_identity_register(
        "Create 'heat_stack_user' Role for template defined users"
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        role_name: 'heat_stack_user',
        action: [:create_role]
      )
    end

    it 'does not call domain setup script by default' do
      expect(chef_run).not_to run_execute('heat-keystone-setup-domain')
    end

    it 'calls domain setup script with insecure mode' do
      node.set['openstack']['orchestration']['heat_stack_user_role'] = 'heat_stack_user'
      node.set['openstack']['orchestration']['stack_user_domain_name'] = 'stack_user_domain_name'
      node.set['openstack']['orchestration']['stack_domain_admin'] = 'stack_domain_admin'
      node.set['openstack']['orchestration']['clients']['insecure'] = true
      node.set['openstack']['endpoints']['identity-admin']['scheme'] = 'https'

      expect(chef_run).to run_execute('heat-keystone-setup-domain --insecure')
        .with(
          environment: { 'OS_USERNAME' => 'admin',
                         'OS_PASSWORD' => 'admin_pass',
                         'OS_AUTH_URL' => 'https://127.0.0.1:35357/v2.0',
                         'OS_CACERT' => nil,
                         'OS_CERT' => nil,
                         'OS_KEY' => nil,
                         'HEAT_DOMAIN' => 'stack_user_domain_name',
                         'HEAT_DOMAIN_ADMIN' => 'stack_domain_admin',
                         'HEAT_DOMAIN_PASSWORD' => 'stack_domain_admin_pass'
          }
        )
    end

    it 'calls domain setup script with secure mode' do
      node.set['openstack']['orchestration']['heat_stack_user_role'] = 'heat_stack_user'
      node.set['openstack']['orchestration']['stack_user_domain_name'] = 'stack_user_domain_name'
      node.set['openstack']['orchestration']['stack_domain_admin'] = 'stack_domain_admin'
      node.set['openstack']['orchestration']['clients']['insecure'] = false
      node.set['openstack']['orchestration']['clients']['ca_file'] = 'path/cacert'
      node.set['openstack']['orchestration']['clients']['cert_file'] = 'path/cert_file'
      node.set['openstack']['orchestration']['clients']['key_file'] = 'path/key_file'
      node.set['openstack']['endpoints']['identity-admin']['scheme'] = 'https'

      expect(chef_run).to run_execute('heat-keystone-setup-domain ')
        .with(
          environment: { 'OS_USERNAME' => 'admin',
                         'OS_PASSWORD' => 'admin_pass',
                         'OS_AUTH_URL' => 'https://127.0.0.1:35357/v2.0',
                         'OS_CACERT' => 'path/cacert',
                         'OS_CERT' => 'path/cert_file',
                         'OS_KEY' => 'path/key_file',
                         'HEAT_DOMAIN' => 'stack_user_domain_name',
                         'HEAT_DOMAIN_ADMIN' => 'stack_domain_admin',
                         'HEAT_DOMAIN_PASSWORD' => 'stack_domain_admin_pass'
          }
        )
    end
  end
end
