require_relative 'spec_helper'

describe 'openstack-orchestration::dashboard' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) { runner.converge(described_recipe) }

    include_context 'orchestration_stubs'
    it do
      expect(chef_run).to upgrade_package 'python3-heat-dashboard'
    end
  end
end
