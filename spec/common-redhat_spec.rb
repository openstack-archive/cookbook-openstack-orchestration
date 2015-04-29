# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-orchestration::common' do
  describe 'redhat' do
    let(:runner) { ChefSpec::SoloRunner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    include_context 'orchestration_stubs'
    include_examples 'logging'
    include_examples 'expect installs python keystoneclient'
    include_examples 'expects to create heat directories'
    include_examples 'expects to create heat conf'
    include_examples 'expects to create heat default.yaml'
    include_examples 'expect installs common heat package'
    include_examples 'expect installs mysql package'
    include_examples 'expect runs db migrations'

    it 'installs postgresql python packages if explicitly told' do
      node.set['openstack']['db']['orchestration']['service_type'] = 'postgresql'

      expect(chef_run).to upgrade_package 'python-psycopg2'
      expect(chef_run).not_to upgrade_package 'MySQL-python'
      expect(chef_run).not_to upgrade_package 'python-ibm-db'
      expect(chef_run).not_to upgrade_package 'python-ibm-db-sa'
    end

    it 'installs db2 python packages if explicitly told' do
      node.set['openstack']['db']['orchestration']['service_type'] = 'db2'

      expect(chef_run).to upgrade_package 'python-ibm-db'
      expect(chef_run).to upgrade_package 'python-ibm-db-sa'
      expect(chef_run).not_to upgrade_package 'python-psycopg2'
      expect(chef_run).not_to upgrade_package 'MySQL-python'
    end
  end
end
