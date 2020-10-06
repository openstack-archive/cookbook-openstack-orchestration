require_relative 'spec_helper'

describe 'openstack-orchestration::common' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) { runner.converge(described_recipe) }

    include_context 'orchestration_stubs'
    include_examples 'logging'
    include_examples 'expects to create heat directories'
    include_examples 'expects to create heat conf'
    include_examples 'expects to create heat default.yaml'
    include_examples 'expect runs db migrations'
    it do
      expect(chef_run).to upgrade_package %w(heat-common python3-heat)
    end
    it do
      expect(chef_run).to upgrade_package 'python3-mysqldb'
    end
    it do
      expect(chef_run).to create_directory('/etc/heat').with(
        owner: 'heat',
        group: 'heat',
        mode: '750'
      )
    end
    it do
      expect(chef_run).to create_directory('/etc/heat/environment.d').with(
        owner: 'heat',
        group: 'heat',
        mode: '750'
      )
    end
    it do
      expect(chef_run).to create_template('/etc/heat/heat.conf').with(
        source: 'openstack-service.conf.erb',
        cookbook: 'openstack-common',
        owner: 'heat',
        group: 'heat',
        mode: '640',
        sensitive: true
      )
    end
    it do
      expect(chef_run).to create_template('/etc/heat/environment.d/default.yaml').with(
        source: 'default.yaml.erb',
        owner: 'heat',
        group: 'heat',
        mode: '644'
      )
    end
    it do
      expect(chef_run).to run_execute('heat-manage db_sync').with(
        user: 'heat',
        group: 'heat'
      )
    end
  end
end
