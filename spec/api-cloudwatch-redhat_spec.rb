require_relative "spec_helper"

describe "openstack-orchestration::api-cloudwatch" do
  before { orchestration_stubs }
  describe "redhat" do
    before do
      @chef_run = ::ChefSpec::Runner.new ::REDHAT_OPTS do |n|
        n.set["openstack"]["orchestration"]["syslog"]["use"] = true
      end
      @chef_run.converge "openstack-orchestration::api-cloudwatch"
    end

    expect_runs_openstack_orchestration_common_recipe

    expect_runs_openstack_common_logging_recipe

    it "installs heat client packages" do
      expect(@chef_run).to upgrade_package "python-heatclient"
    end

    expect_creates_api_paste "service[heat-api-cloudwatch]"

    expect_creates_policy_json "service[heat-api-cloudwatch]","heat","heat"

    it "starts heat api-cloudwatch on boot" do
      expect(@chef_run).to enable_service("openstack-heat-api-cloudwatch")
    end
  end
end
