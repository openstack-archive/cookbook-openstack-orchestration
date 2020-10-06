require_relative 'spec_helper'

describe 'openstack-orchestration::dashboard' do
  describe 'redhat' do
    let(:runner) { ChefSpec::SoloRunner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) { runner.converge(described_recipe) }

    include_context 'orchestration_stubs'
    it do
      expect(chef_run).to upgrade_package 'openstack-heat-ui'
    end
  end
end
