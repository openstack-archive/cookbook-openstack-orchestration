require_relative 'spec_helper'

describe 'openstack-orchestration::api-cfn' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) { runner.converge(described_recipe) }

    include_context 'orchestration_stubs'
    include_examples 'expect runs openstack orchestration common recipe'

    it 'installs heat cfn packages' do
      expect(chef_run).to upgrade_package 'heat-api-cfn'
    end

    it 'enables heat api-cfn on boot' do
      expect(chef_run).to enable_service('heat-api-cfn')
    end

    it 'starts heat api-cfn on boot' do
      expect(chef_run).to start_service('heat-api-cfn')
    end
  end
end
