require "chefspec"
require "chef/application"

::LOG_LEVEL = :fatal
::REDHAT_OPTS = {
  :platform  => "redhat",
  :version   => "6.3",
  :log_level => ::LOG_LEVEL
}

def orchestration_stubs
  ::Chef::Recipe.any_instance.stub(:rabbit_servers).
    and_return "1.1.1.1:5672,2.2.2.2:5672"
  ::Chef::Recipe.any_instance.stub(:address_for).
    with("lo").
    and_return "127.0.1.1"
  ::Chef::Recipe.any_instance.stub(:secret).
    with("secrets", "openstack_identity_bootstrap_token").
    and_return "bootstrap-token"
  ::Chef::Recipe.any_instance.stub(:db_password).and_return String.new
  ::Chef::Recipe.any_instance.stub(:user_password).and_return String.new
  ::Chef::Recipe.any_instance.stub(:user_password).
    with("guest").
    and_return "rabbit-pass"
  ::Chef::Recipe.any_instance.stub(:user_password).
    with("admin-user").
    and_return "admin-pass"
  ::Chef::Recipe.any_instance.stub(:service_password).with("openstack-orchestration").
    and_return "heat-pass"
  ::Chef::Application.stub(:fatal!)
end

def expect_runs_openstack_orchestration_common_recipe
  it "runs orchestration common recipe" do
    expect(@chef_run).to include_recipe "openstack-orchestration::common"
  end
end

def expect_installs_python_keystone
  it "installs python-keystone" do
    expect(@chef_run).to upgrade_package "python-keystone"
  end
end

def expect_runs_openstack_common_logging_recipe
  it "runs logging recipe if node attributes say to" do
    expect(@chef_run).to include_recipe "openstack-common::logging"
  end
end

def expect_creates_api_paste service, action=:restart
  describe "api-paste.ini" do
    before do
      @template = @chef_run.template "/etc/heat/api-paste.ini"
    end

    it "has proper owner" do
      expect(@template.owner).to eq("heat")
      expect(@template.group).to eq("heat")
    end

    it "has proper modes" do
      expect(sprintf("%o", @template.mode)).to eq "644"
    end

    it "template contents" do
      pending "TODO: implement"
    end

    it "notifies heat-api restart" do
      expect(@template).to notify(service).to(action)
    end
  end
end

def expect_creates_policy_json service, user, group, action=:restart
  describe "policy.json" do
    before do
      @template = @chef_run.template "/etc/heat/policy.json"
    end

    it "has proper owner" do
      expect(@template.owner).to eq(user)
      expect(@template.group).to eq(group)
    end

    it "has proper modes" do
      expect(sprintf("%o", @template.mode)).to eq "644"
    end

    it "notifies service restart" do
      expect(@template).to notify(service).to(action)
    end
  end
end
