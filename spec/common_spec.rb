# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-orchestration::common' do
  before { orchestration_stubs }
  before do
    @chef_run = ::ChefSpec::Runner.new ::UBUNTU_OPTS
    @chef_run.converge 'openstack-orchestration::common'
  end

  expect_installs_python_keystoneclient

  it 'installs the openstack-heat package' do
    expect(@chef_run).to upgrade_package 'heat-common'
  end

  it 'installs mysql python packages by default' do
    expect(@chef_run).to upgrade_package 'python-mysqldb'
  end

  it 'installs postgresql python packages if explicitly told' do
    chef_run = ::ChefSpec::Runner.new ::UBUNTU_OPTS
    node = chef_run.node
    node.set['openstack']['db']['orchestration']['service_type'] = 'postgresql'
    chef_run.converge 'openstack-orchestration::common'

    expect(chef_run).to upgrade_package 'python-psycopg2'
    expect(chef_run).not_to upgrade_package 'MySQL-python'
    expect(chef_run).not_to upgrade_package 'python-ibm-db'
    expect(chef_run).not_to upgrade_package 'python-ibm-db-sa'
  end

  describe '/etc/heat' do
    before do
      @dir = @chef_run.directory '/etc/heat'
    end

    it 'has proper owner' do
      expect(@dir.owner).to eq('heat')
    end

    it 'has proper modes' do
      expect(sprintf('%o', @dir.mode)).to eq '700'
    end

  end

  describe '/etc/heat/environment.d' do
    before do
      @dir = @chef_run.directory '/etc/heat/environment.d'
    end

    it 'has proper owner' do
      expect(@dir.owner).to eq('heat')
    end

    it 'has proper modes' do
      expect(sprintf('%o', @dir.mode)).to eq '700'
    end

  end

  describe '/var/cache/heat' do
    before do
      @dir = @chef_run.directory '/var/cache/heat'
    end

    it 'has proper owner' do
      expect(@dir.owner).to eq('heat')
    end

    it 'has proper modes' do
      expect(sprintf('%o', @dir.mode)).to eq '700'
    end
  end

  describe 'heat.conf' do
    before do
      @template = @chef_run.template '/etc/heat/heat.conf'
    end
    it 'has proper owner' do
      expect(@template.owner).to eq('heat')
      expect(@template.group).to eq('heat')
    end

    it 'has proper modes' do
      expect(sprintf('%o', @template.mode)).to eq '644'
    end

    # TODO: (MRV) Add rest of conf items
    [
      %r{^heat_metadata_server_url=http://127.0.0.1:8000$},
      %r{^heat_waitcondition_server_url=http://127.0.0.1:8000/v1/waitcondition$},
      %r{^heat_watch_server_url=http://127.0.0.1:8003$},
      %r{^signing_dir=/var/cache/heat$}
    ].each do |content|
      it "has a #{content.source[1...-1]} line" do
        expect(@chef_run).to render_file(@template.name).with_content(content)
      end
    end
  end

  describe 'default.yaml' do
    before do
      @template = @chef_run.template '/etc/heat/environment.d/default.yaml'
    end

    it 'has proper owner' do
      expect(@template.owner).to eq('heat')
      expect(@template.group).to eq('heat')
    end

    it 'has proper modes' do
      expect(sprintf('%o', @template.mode)).to eq '644'
    end
  end

  it 'runs db migrations' do
    cmd = 'heat-manage db_sync'
    expect(@chef_run).to run_execute(cmd).with(user: 'heat', group: 'heat')
  end
end
