# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-orchestration::common' do
  describe 'redhat' do
    let(:runner) { ChefSpec::SoloRunner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    include_context 'orchestration_stubs'
    include_examples 'logging'
    include_examples 'expects to create heat directories'
    include_examples 'expects to create heat conf'
    include_examples 'expects to create heat default.yaml'
    include_examples 'expect installs common heat package'
    include_examples 'expect installs mysql package'
    include_examples 'expect runs db migrations'
  end
end
