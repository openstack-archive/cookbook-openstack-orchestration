require_relative 'spec_helper'

describe 'openstack-orchestration::common' do
  ALL_RHEL.each do |p|
    context "redhat #{p[:version]}" do
      let(:runner) { ChefSpec::SoloRunner.new(p) }
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

      case p
      when REDHAT_7
        it do
          expect(chef_run).to upgrade_package 'MySQL-python'
        end
      when REDHAT_8
        it do
          expect(chef_run).to upgrade_package 'python3-PyMySQL'
        end
      end
    end
  end
end
