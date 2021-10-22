require_relative 'spec_helper'

describe 'openstack-orchestration::api-cfn' do
  ALL_RHEL.each do |p|
    context "redhat #{p[:version]}" do
      let(:runner) { ChefSpec::SoloRunner.new(p) }
      let(:node) { runner.node }
      cached(:chef_run) { runner.converge(described_recipe) }

      include_context 'orchestration_stubs'
      include_examples 'expect runs openstack orchestration common recipe'

      it 'installs heat cfn packages' do
        expect(chef_run).to upgrade_package 'openstack-heat-api-cfn'
      end

      it 'enables heat api-cfn on boot' do
        expect(chef_run).to enable_service('openstack-heat-api-cfn')
      end

      it 'starts heat api-cfn on boot' do
        expect(chef_run).to start_service('openstack-heat-api-cfn')
      end
    end
  end
end
