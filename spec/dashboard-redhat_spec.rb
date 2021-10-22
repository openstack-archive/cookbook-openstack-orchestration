require_relative 'spec_helper'

describe 'openstack-orchestration::dashboard' do
  ALL_RHEL.each do |p|
    context "redhat #{p[:version]}" do
      let(:runner) { ChefSpec::SoloRunner.new(p) }
      let(:node) { runner.node }
      cached(:chef_run) { runner.converge(described_recipe) }

      include_context 'orchestration_stubs'
      it do
        expect(chef_run).to upgrade_package 'openstack-heat-ui'
      end
    end
  end
end
