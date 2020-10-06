require_relative 'spec_helper'

describe 'openstack-orchestration::identity_registration' do
  describe 'redhat' do
    let(:runner) { ChefSpec::SoloRunner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) { runner.converge(described_recipe) }

    include_context 'orchestration_stubs'

    connection_params = {
      openstack_auth_url: 'http://127.0.0.1:5000/v3',
      openstack_username: 'admin',
      openstack_api_key: 'admin-pass',
      openstack_project_name: 'admin',
      openstack_domain_name: 'default',
    }
    service_name = 'heat'
    service_type = 'orchestration'
    service_user = 'heat'
    stack_domain_admin = 'heat_domain_admin'
    stack_domain_name = 'heat'
    stack_domain_password = 'heat_domain_pass'
    url = 'http://127.0.0.1:8004/v1/%(tenant_id)s'
    region = 'RegionOne'
    project_name = 'service'
    role_name = 'service'
    password = 'heat-pass'
    domain_name = 'Default'

    it "registers #{project_name} Project" do
      expect(chef_run).to create_openstack_project(
        project_name
      ).with(
        connection_params: connection_params
      )
    end

    it "registers #{service_name} service" do
      expect(chef_run).to create_openstack_service(
        service_name
      ).with(
        connection_params: connection_params,
        type: service_type
      )
    end

    context "registers #{service_name} endpoint" do
      %w(internal public).each do |interface|
        it "#{interface} endpoint with default values" do
          expect(chef_run).to create_openstack_endpoint(
            service_type
          ).with(
            service_name: service_name,
            # interface: interface,
            url: url,
            region: region,
            connection_params: connection_params
          )
        end
      end
    end

    it 'registers service user' do
      expect(chef_run).to create_openstack_user(
        service_user
      ).with(
        domain_name: domain_name,
        project_name: project_name,
        password: password,
        connection_params: connection_params
      )
    end

    it do
      expect(chef_run).to create_openstack_role(
        'heat_stack_owner'
      ).with(
        connection_params: connection_params
      )
    end

    it do
      expect(chef_run).to create_openstack_role(
        'heat_stack_user'
      ).with(
        connection_params: connection_params
      )
    end

    it do
      expect(chef_run).to grant_role_openstack_user(
        service_user
      ).with(
        project_name: project_name,
        role_name: role_name,
        connection_params: connection_params
      )
    end

    it do
      expect(chef_run).to create_openstack_domain(
        stack_domain_name
      ).with(
        connection_params: connection_params
      )
    end

    it 'registers stack domain admin user' do
      expect(chef_run).to create_openstack_user(
        stack_domain_admin
      ).with(
        password: stack_domain_password,
        connection_params: connection_params
      )
    end

    it do
      expect(chef_run).to grant_domain_openstack_user(
        stack_domain_admin
      ).with(
        domain_name: stack_domain_name,
        role_name: 'admin',
        connection_params: connection_params
      )
    end
    it 'register heat cloudformation service' do
      expect(chef_run).to create_openstack_service(
        'heat-cfn'
      ).with(
        connection_params: connection_params
      )
    end
    %w(internal public).each do |interface|
      it "#{interface} cloudformation endpoint with default values" do
        expect(chef_run).to create_openstack_endpoint(
          'cloudformation'
        ).with(
          service_name: 'heat-cfn',
          url: 'http://127.0.0.1:8000/v1',
          region: region,
          connection_params: connection_params
        )
      end
    end
  end
end
