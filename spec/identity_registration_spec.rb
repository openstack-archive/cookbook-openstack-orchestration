require_relative "spec_helper"

describe "openstack-orchestration::identity_registration" do
  before do
    orchestration_stubs
    @chef_run = ::ChefSpec::Runner.new ::REDHAT_OPTS
    @chef_run.converge "openstack-orchestration::identity_registration"
  end

  it "Register Heat Orchestration Service" do
    resource = @chef_run.find_resource(
      "openstack-identity_register",
      "Register Heat Orchestration Service"
    ).to_hash

    expect(resource).to include(
      :auth_uri => "http://127.0.0.1:35357/v2.0",
      :bootstrap_token => "bootstrap-token",
      :service_name => "heat",
      :service_type => "orchestration",
      :service_description => "Heat Orchestration Service",
      :action => [:create_service]
    )
  end

  # Pending on https://review.openstack.org/#/c/59088/
  it "Register Heat Orchestration Endpoint" do
    pending "TODO: implement"
  end


  it "Register Heat Cloudformation Service" do
   resource = @chef_run.find_resource(
      "openstack-identity_register",
      "Register Heat Cloudformation Service"
    ).to_hash

   expect(resource).to include(
      :auth_uri => "http://127.0.0.1:35357/v2.0",
      :bootstrap_token => "bootstrap-token",
      :service_name => "heat-cfn",
      :service_type => "cloudformation",
      :service_description => "Heat Cloudformation Service",
      :action => [:create_service]
    )
  end

  # Pending on https://review.openstack.org/#/c/59088/
  it "Register Heat Cloudformation Endpoint" do
    pending "TODO: implement"
  end


  it "registers service user" do
    resource = @chef_run.find_resource(
      "openstack-identity_register",
      "Register Heat Service User"
    ).to_hash

    expect(resource).to include(
      :auth_uri => "http://127.0.0.1:35357/v2.0",
      :bootstrap_token => "bootstrap-token",
      :tenant_name => "service",
      :user_name => "heat",
      :user_pass => "heat-pass",
      :user_enabled => true,
      :action => [:create_user]
    )
  end

  it "grants admin role to service user for service tenant" do
    resource = @chef_run.find_resource(
      "openstack-identity_register",
      "Grant 'admin' Role to heat User for service Tenant"
    ).to_hash

    expect(resource).to include(
      :auth_uri => "http://127.0.0.1:35357/v2.0",
      :bootstrap_token => "bootstrap-token",
      :tenant_name => "service",
      :user_name => "heat",
      :role_name => "admin",
      :action => [:grant_role]
    )
  end

end
