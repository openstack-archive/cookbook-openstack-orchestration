require_relative 'spec_helper'

describe 'openstack-orchestration::common' do
  describe 'redhat' do
    let(:runner) { ChefSpec::SoloRunner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) { runner.converge(described_recipe) }

    include_context 'orchestration_stubs'
    include_examples 'logging'
    include_examples 'expects to create heat directories'
    include_examples 'expects to create heat conf'
    include_examples 'expects to create heat default.yaml'
    include_examples 'expect installs common heat package'
    include_examples 'expect installs mysql package'
    include_examples 'expect runs db migrations'
    it do
      expect(chef_run).to upgrade_package 'openstack-heat-common'
    end
    it do
      expect(chef_run).to upgrade_package 'MySQL-python'
    end
  end
end
