require_relative "spec_helper"

describe "openstack-orchestration::engine" do
  before { orchestration_stubs }
  describe "redhat" do
    before do
      @chef_run = ::ChefSpec::Runner.new ::REDHAT_OPTS
      @chef_run.converge "openstack-orchestration::engine"
    end

    expect_runs_openstack_orchestration_common_recipe

    it "doesn't run logging recipe" do
      expect(@chef_run).not_to include_recipe "openstack-common::logging"
    end

    it "starts heat engine on boot" do
      expect(@chef_run).to enable_service("openstack-heat-engine")
    end
  end
end
