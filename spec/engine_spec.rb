require_relative 'spec_helper'

describe 'openstack-orchestration::engine' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) { runner.converge(described_recipe) }

    include_context 'orchestration_stubs'
    include_examples 'expect runs openstack orchestration common recipe'

    it 'installs heat engine package' do
      expect(chef_run).to upgrade_package 'heat-engine'
    end

    it 'enables heat engine on boot' do
      expect(chef_run).to enable_service('heat_engine')
    end

    it 'starts heat engine on boot' do
      expect(chef_run).to start_service('heat_engine')
    end
  end
end
