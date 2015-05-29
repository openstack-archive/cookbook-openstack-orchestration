# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-orchestration::common' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    include_context 'orchestration_stubs'
    include_examples 'logging'
    include_examples 'expect installs python keystoneclient'
    include_examples 'expects to create heat directories'
    include_examples 'expects to create heat conf'
    include_examples 'expects to create heat default.yaml'
    include_examples 'expect runs db migrations'

    it 'installs the openstack-heat package' do
      expect(chef_run).to upgrade_package 'heat-common'
    end

    it 'installs mysql python packages by default' do
      expect(chef_run).to upgrade_package 'python-mysqldb'
    end

    it 'installs postgresql python packages if explicitly told' do
      node.set['openstack']['db']['orchestration']['service_type'] = 'postgresql'

      expect(chef_run).to upgrade_package 'python-psycopg2'
      expect(chef_run).not_to upgrade_package 'MySQL-python'
      expect(chef_run).not_to upgrade_package 'python-ibm-db'
      expect(chef_run).not_to upgrade_package 'python-ibm-db-sa'
    end

    describe 'heat.conf' do
      let(:file) { chef_run.template('/etc/heat/heat.conf') }

      it 'adds misc_heat array correctly' do
        node.set['openstack']['orchestration']['misc_heat'] = ['MISC_OPTION=FOO']
        expect(chef_run).to render_file(file.name).with_content('MISC_OPTION=FOO')
      end
    end
  end
end
