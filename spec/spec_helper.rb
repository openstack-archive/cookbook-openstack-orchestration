# encoding: UTF-8
require 'chefspec'
require 'chefspec/berkshelf'

ChefSpec::Coverage.start! { add_filter 'openstack-orchestration' }

require 'chef/application'

LOG_LEVEL = :fatal
REDHAT_OPTS = {
  platform: 'redhat',
  version: '6.5',
  log_level: ::LOG_LEVEL
}
UBUNTU_OPTS = {
  platform: 'ubuntu',
  version: '12.04',
  log_level: ::LOG_LEVEL
}
SUSE_OPTS = {
  platform: 'suse',
  version: '11.3',
  log_level: ::LOG_LEVEL
}

shared_context 'orchestration_stubs' do
  before do
    allow_any_instance_of(Chef::Recipe).to receive(:rabbit_servers)
      .and_return '1.1.1.1:5672,2.2.2.2:5672'
    allow_any_instance_of(Chef::Recipe).to receive(:address_for)
      .with('lo')
      .and_return '127.0.1.1'
    allow_any_instance_of(Chef::Recipe).to receive(:get_secret)
      .with('openstack_identity_bootstrap_token')
      .and_return 'bootstrap-token'

    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('db', 'heat')
      .and_return 'heat'
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'guest')
      .and_return 'mq-pass'
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'admin-user')
      .and_return 'admin-pass'
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('service', 'openstack-orchestration')
      .and_return 'heat-pass'
    allow(Chef::Application).to receive(:fatal!)
  end
end

shared_examples 'expect runs openstack orchestration common recipe' do
  it 'runs orchestration common recipe' do
    expect(chef_run).to include_recipe 'openstack-orchestration::common'
  end
end

shared_examples 'expect installs python keystoneclient' do
  it 'installs python-keystoneclient' do
    expect(chef_run).to upgrade_package 'python-keystoneclient'
  end
end

shared_examples 'expect runs openstack common logging recipe' do
  it 'runs logging recipe if node attributes say to' do
    expect(chef_run).to include_recipe 'openstack-common::logging'
  end
end

def expect_creates_api_paste(service, action = :restart) # rubocop:disable MethodLength
  describe 'api-paste.ini' do
    let(:template) { chef_run.template('/etc/heat/api-paste.ini') }

    it 'creates the heat.conf file' do
      expect(chef_run).to create_template(template.name).with(
        owner: 'heat',
        group: 'heat',
        mode: 0644
      )
    end

    it 'notifies heat-api restart' do
      expect(template).to notify(service).to(action)
    end
  end
end

shared_examples 'expect installs common heat package' do
  it 'installs the openstack-heat package' do
    expect(chef_run).to upgrade_package 'openstack-heat'
  end
end

shared_examples 'expect installs mysql package' do
  it 'installs mysql python packages by default' do
    expect(chef_run).to upgrade_package 'MySQL-python'
  end
end

shared_examples 'expect runs db migrations' do
  it 'runs db migrations' do
    expect(chef_run).to run_execute('heat-manage db_sync').with(user: 'heat', group: 'heat')
  end
end

shared_examples 'expects to create heat directories' do
  it 'creates /etc/heat' do
    expect(chef_run).to create_directory('/etc/heat').with(
          owner: 'heat',
          group: 'heat',
          mode: 0700
        )
  end

  it 'creates /etc/heat/environment.d' do
    expect(chef_run).to create_directory('/etc/heat/environment.d').with(
          owner: 'heat',
          group: 'heat',
          mode: 0700
        )
  end

  it 'creates /var/cache/heat' do
    expect(chef_run).to create_directory('/var/cache/heat').with(
          owner: 'heat',
          group: 'heat',
          mode: 0700
        )
  end
end

shared_examples 'expects to create heat conf' do
  describe 'heat.conf' do
    let(:file) { chef_run.template('/etc/heat/heat.conf') }

    it 'creates the heat.conf file' do
      expect(chef_run).to create_template(file.name).with(
        owner: 'heat',
        group: 'heat',
        mode: 0640
      )
    end

    it 'uses default values for these attributes and they are not set' do
      expect(chef_run).not_to render_file(file.name).with_content(
        /^memcached_servers=/)
      expect(chef_run).not_to render_file(file.name).with_content(
        /^memcache_security_strategy=/)
      expect(chef_run).not_to render_file(file.name).with_content(
        /^memcache_secret_key=/)
      expect(chef_run).not_to render_file(file.name).with_content(
        /^cafile=/)
    end

    it 'sets memcached server(s)' do
      node.set['openstack']['orchestration']['api']['auth']['memcached_servers'] = 'localhost:11211'
      expect(chef_run).to render_file(file.name).with_content(/^memcached_servers=localhost:11211$/)
    end

    it 'sets memcache security strategy' do
      node.set['openstack']['orchestration']['api']['auth']['memcache_security_strategy'] = 'MAC'
      expect(chef_run).to render_file(file.name).with_content(/^memcache_security_strategy=MAC$/)
    end

    it 'sets memcache secret key' do
      node.set['openstack']['orchestration']['api']['auth']['memcache_secret_key'] = '0123456789ABCDEF'
      expect(chef_run).to render_file(file.name).with_content(/^memcache_secret_key=0123456789ABCDEF$/)
    end

    it 'sets cafile' do
      node.set['openstack']['orchestration']['api']['auth']['cafile'] = 'dir/to/path'
      expect(chef_run).to render_file(file.name).with_content(%r{^cafile=dir/to/path$})
    end

    it 'sets token hash algorithms' do
      node.set['openstack']['orchestration']['api']['auth']['hash_algorithms'] = 'sha2'
      expect(chef_run).to render_file(file.name).with_content(/^hash_algorithms=sha2$/)
    end

    it 'sets insecure' do
      node.set['openstack']['orchestration']['api']['auth']['insecure'] = false
      expect(chef_run).to render_file(file.name).with_content(/^insecure=false$/)
    end

    describe 'default values' do
      it 'has default conf values' do
        [
          %r{^sql_connection=mysql://heat:heat@127.0.0.1:3306/heat\?charset=utf8$},
          %r{^heat_metadata_server_url=http://127.0.0.1:8000$},
          %r{^heat_waitcondition_server_url=http://127.0.0.1:8000/v1/waitcondition$},
          %r{^heat_watch_server_url=http://127.0.0.1:8003$},
          %r{^signing_dir=/var/cache/heat$},
          /^debug=False$/,
          /^verbose=False$/,
          /^notification_driver = heat.openstack.common.notifier.rpc_notifier$/,
          /^default_notification_level = INFO$/,
          /^default_publisher_id = $/,
          /^list_notifier_drivers = heat.openstack.common.notifier.no_op_notifier$/,
          /^notification_topics = notifications$/,
          /^rpc_thread_pool_size=64$/,
          /^rpc_conn_pool_size=30$/,
          /^rpc_response_timeout=60$/,
          /^amqp_durable_queues=false$/,
          /^amqp_auto_delete=false$/,
          /^rabbit_host=127.0.0.1$/,
          /^rabbit_port=5672$/,
          /^rabbit_use_ssl=false$/,
          /^rabbit_userid=guest$/,
          /^rabbit_password=mq-pass$/,
          /^rabbit_virtual_host=\/$/,
          /^bind_host=127.0.0.1$/,
          /^bind_port=8004$/,
          /^auth_host=127.0.0.1$/,
          /^auth_port=35357$/,
          /^auth_protocol=http$/,
          %r{^auth_uri=http://127.0.0.1:5000/v2.0$},
          /^auth_version=v2.0$/,
          /^hash_algorithms=md5$/,
          /^insecure=false$/,
          /^admin_user=heat$/,
          /^admin_password=heat-pass$/,
          /^admin_tenant_name=service$/,
          %r{^signing_dir=/var/cache/heat$},
          /^region_name_for_services=RegionOne$/
        ].each do |line|
          expect(chef_run).to render_file(file.name).with_content(line)
        end
      end
    end

    describe 'has qpid values' do
      it 'has default qpid_* values' do
        node.set['openstack']['mq']['orchestration']['service_type'] = 'qpid'

        [
          /^qpid_hostname=127.0.0.1$/,
          /^qpid_port=5672$/,
          /^qpid_username=guest$/,
          /^qpid_password=mq-pass$/,
          /^qpid_sasl_mechanisms=$/,
          /^qpid_heartbeat=60$/,
          /^qpid_protocol=tcp$/,
          /^qpid_tcp_nodelay=true$/,
          /^qpid_reconnect_timeout=0$/,
          /^qpid_reconnect_limit=0$/,
          /^qpid_reconnect_interval_min=0$/,
          /^qpid_reconnect_interval_max=0$/,
          /^qpid_reconnect_interval=0$/,
          /^qpid_topology_version=1$/
        ].each do |line|
          expect(chef_run).to render_file(file.name).with_content(line)
        end
      end
    end
  end
end

shared_examples 'expects to create heat default.yaml' do
  describe 'default.yaml' do
    let(:file) { chef_run.template('/etc/heat/environment.d/default.yaml') }

    it 'creates the default.yaml file' do
      expect(chef_run).to create_template(file.name).with(
        owner: 'heat',
        group: 'heat',
        mode: 0644
      )
    end
  end
end

shared_examples 'logging' do
  context 'with logging enabled' do
    before do
      node.set['openstack']['orchestration']['syslog']['use'] = true
    end

    it 'runs logging recipe if node attributes say to' do
      expect(chef_run).to include_recipe 'openstack-common::logging'
    end
  end

  context 'with logging disabled' do
    before do
      node.set['openstack']['orchestration']['syslog']['use'] = false
    end

    it "doesn't run logging recipe" do
      expect(chef_run).not_to include_recipe 'openstack-common::logging'
    end
  end
end
