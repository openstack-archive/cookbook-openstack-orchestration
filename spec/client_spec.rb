# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-orchestration::client' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:chef_run) { runner.converge(described_recipe) }

    it 'installs packages' do
      expect(chef_run).to upgrade_package('python-heatclient')
    end
  end
end
