# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-orchestration::common' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    include_context 'orchestration_stubs'
    include_examples 'logging'
    include_examples 'expects to create heat directories'
    include_examples 'expects to create heat conf'
    include_examples 'expects to create heat default.yaml'
    include_examples 'expect runs db migrations'
    %w(heat-common python-heat).each do |p|
      it "installs the #{p} package" do
        expect(chef_run).to upgrade_package p
      end
    end

    it 'installs mysql python packages by default' do
      expect(chef_run).to upgrade_package 'python-mysqldb'
    end
  end
end
