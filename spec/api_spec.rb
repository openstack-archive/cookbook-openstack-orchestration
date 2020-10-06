require_relative 'spec_helper'

describe 'openstack-orchestration::api' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) { runner.converge(described_recipe) }

    include_context 'orchestration_stubs'
    include_examples 'expect runs openstack orchestration common recipe'

    it 'installs heat api packages' do
      expect(chef_run).to upgrade_package 'heat-api'
    end

    it 'enables heat api on boot' do
      expect(chef_run).to enable_service('heat-api')
    end

    it 'starts heat api on boot' do
      expect(chef_run).to start_service('heat-api')
    end
  end
end
