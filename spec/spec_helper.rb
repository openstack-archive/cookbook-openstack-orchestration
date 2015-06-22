# encoding: UTF-8
require 'chefspec'
require 'chefspec/berkshelf'

ChefSpec::Coverage.start! { add_filter 'openstack-orchestration' }

require 'chef/application'

LOG_LEVEL = :fatal
REDHAT_OPTS = {
  platform: 'redhat',
  version: '7.1',
  log_level: ::LOG_LEVEL
}
UBUNTU_OPTS = {
  platform: 'ubuntu',
  version: '14.04',
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
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('token', 'openstack_identity_bootstrap_token')
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
      .with('user', 'heat_stack_admin')
      .and_return 'heat_stack_domain_admin_password'
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('service', 'openstack-orchestration')
      .and_return 'heat-pass'
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'stack_domain_admin')
      .and_return 'stack_domain_admin_pass'
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'admin')
      .and_return 'admin_pass'
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('token', 'orchestration_auth_encryption_key')
      .and_return 'auth_encryption_key_secret'
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

    describe 'workers' do
      it 'has default worker values' do
        [
          'heat_api',
          'heat_api_cfn',
          'heat_api_cloudwatch'
        ].each do |section|
          expect(chef_run).to render_config_file(file.name).with_section_content(section, /^workers=0$/)
        end
      end

      it 'has engine workers not set by default' do
        expect(chef_run).not_to render_config_file(file.name).with_section_content('DEFAULT', /^num_engine_workers=/)
      end

      it 'allows engine workers override' do
        node.set['openstack']['orchestration']['num_engine_workers'] = 5
        expect(chef_run).to render_config_file(file.name).with_section_content('DEFAULT', /^num_engine_workers=5$/)
      end
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

    it 'sets auth_encryption_key' do
      expect(chef_run).to render_config_file(file.name).with_section_content('DEFAULT', /^auth_encryption_key=auth_encryption_key_secret$/)
    end

    describe 'default values for certificates files' do
      it 'has no such values' do
        [
          /^ca_file=/,
          /^cert_file=/,
          /^key_file=/
        ].each do |line|
          expect(chef_run).not_to render_file(file.name).with_content(line)
        end
      end

      it 'sets clients ca_file cert_file key_file insecure' do
        node.set['openstack']['orchestration']['clients']['ca_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients']['cert_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients']['key_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients']['insecure'] = true
        expect(chef_run).to render_file(file.name).with_content(%r{^ca_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(%r{^cert_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(%r{^key_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(/^insecure=true$/)
      end

      it 'sets clients_ceilometer ca_file cert_file key_file insecure' do
        node.set['openstack']['orchestration']['clients_ceilometer']['ca_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_ceilometer']['cert_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_ceilometer']['key_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_ceilometer']['insecure'] = true
        expect(chef_run).to render_file(file.name).with_content(%r{^ca_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(%r{^cert_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(%r{^key_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(/^insecure=true$/)
      end

      it 'sets clients_cinder ca_file cert_file key_file insecure' do
        node.set['openstack']['orchestration']['clients_cinder']['ca_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_cinder']['cert_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_cinder']['key_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_cinder']['insecure'] = true
        expect(chef_run).to render_file(file.name).with_content(%r{^ca_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(%r{^cert_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(%r{^key_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(/^insecure=true$/)
      end

      it 'sets clients_glance ca_file cert_file key_file insecure' do
        node.set['openstack']['orchestration']['clients_glance']['ca_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_glance']['cert_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_glance']['key_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_glance']['insecure'] = true
        expect(chef_run).to render_file(file.name).with_content(%r{^ca_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(%r{^cert_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(%r{^key_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(/^insecure=true$/)
      end

      it 'sets clients_heat ca_file cert_file key_file insecure' do
        node.set['openstack']['orchestration']['clients_heat']['ca_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_heat']['cert_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_heat']['key_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_heat']['insecure'] = true
        expect(chef_run).to render_file(file.name).with_content(%r{^ca_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(%r{^cert_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(%r{^key_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(/^insecure=true$/)
      end

      it 'sets clients_keystone ca_file cert_file key_file insecure' do
        node.set['openstack']['orchestration']['clients_keystone']['ca_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_keystone']['cert_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_keystone']['key_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_keystone']['insecure'] = true
        expect(chef_run).to render_file(file.name).with_content(%r{^ca_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(%r{^cert_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(%r{^key_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(/^insecure=true$/)
      end

      it 'sets clients_neutron ca_file cert_file key_file insecure' do
        node.set['openstack']['orchestration']['clients_neutron']['ca_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_neutron']['cert_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_neutron']['key_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_neutron']['insecure'] = true
        expect(chef_run).to render_file(file.name).with_content(%r{^ca_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(%r{^cert_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(%r{^key_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(/^insecure=true$/)
      end

      it 'sets clients_nova ca_file cert_file key_file insecure' do
        node.set['openstack']['orchestration']['clients_nova']['ca_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_nova']['cert_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_nova']['key_file'] = 'dir/to/path'
        node.set['openstack']['orchestration']['clients_nova']['insecure'] = true
        expect(chef_run).to render_file(file.name).with_content(%r{^ca_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(%r{^cert_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(%r{^key_file=dir/to/path$})
        expect(chef_run).to render_file(file.name).with_content(/^insecure=true$/)
      end
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
          %r{^log_dir=/var/log/heat$},
          /^notification_driver = heat.openstack.common.notifier.rpc_notifier$/,
          /^default_notification_level = INFO$/,
          /^default_publisher_id = $/,
          /^list_notifier_drivers = heat.openstack.common.notifier.no_op_notifier$/,
          /^notification_topics = notifications$/,
          /^rpc_thread_pool_size=64$/,
          /^rpc_response_timeout=60$/,
          /^bind_host=127.0.0.1$/,
          /^bind_port=8004$/,
          %r{^auth_uri=http://127.0.0.1:5000/v2.0$},
          %r{^identity_uri=http://127.0.0.1:35357/$},
          /^auth_version=v2.0$/,
          /^hash_algorithms=md5$/,
          /^insecure=false$/,
          /^admin_user=heat$/,
          /^admin_password=heat-pass$/,
          /^admin_tenant_name=service$/,
          /^deferred_auth_method=trusts$/,
          /^stack_scheduler_hints=false$/,
          /^region_name_for_services=RegionOne$/
        ].each do |line|
          expect(chef_run).to render_file(file.name).with_content(line)
        end
      end

      it 'overrides the schemes' do
        node.set['openstack']['endpoints']['orchestration-api-cfn']['scheme'] = 'https'
        node.set['openstack']['endpoints']['orchestration-api-cloudwatch']['scheme'] = 'https'
        expect(chef_run).to render_file(file.name).with_content(%r{^heat_metadata_server_url=https://127.0.0.1:8000$})
        expect(chef_run).to render_file(file.name).with_content(%r{^heat_waitcondition_server_url=https://127.0.0.1:8000/v1/waitcondition$})
        expect(chef_run).to render_file(file.name).with_content(%r{^heat_watch_server_url=https://127.0.0.1:8003$})
      end
    end

    describe 'domain values' do
      it 'has no default domain values' do
        [
          /^heat_stack_user_role=/,
          /^stack_user_domain_name=/,
          /^stack_user_domain_id=/,
          /^stack_domain_admin=/,
          /^stack_domain_admin_password=/
        ].each do |line|
          expect(chef_run).not_to render_file(file.name).with_content(line)
        end
      end

      it 'has domain override values' do
        node.set['openstack']['orchestration']['heat_stack_user_role'] = 'heat_stack_user'
        node.set['openstack']['orchestration']['stack_user_domain_name'] = 'heat'
        node.set['openstack']['orchestration']['stack_user_domain_id'] = '123'
        node.set['openstack']['orchestration']['stack_domain_admin'] = 'heat_stack_admin'
        [
          /^heat_stack_user_role=heat_stack_user$/,
          /^stack_user_domain_name=heat$/,
          /^stack_user_domain_id=123$/,
          /^stack_domain_admin=heat_stack_admin$/,
          /^stack_domain_admin_password=heat_stack_domain_admin_password$/
        ].each do |line|
          expect(chef_run).to render_file(file.name).with_content(line)
        end
      end
    end

    describe 'has qpid values' do
      it 'has default qpid_* values' do
        node.set['openstack']['mq']['orchestration']['service_type'] = 'qpid'

        [
          /^rpc_conn_pool_size=30$/,
          /^amqp_durable_queues=false$/,
          /^amqp_auto_delete=false$/,
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
          expect(chef_run).to render_config_file(file.name).with_section_content('oslo_messaging_qpid', line)
        end
        expect(chef_run).to render_config_file(file.name).with_section_content('DEFAULT', /^rpc_backend=heat.openstack.common.rpc.impl_qpid$/)
      end
    end

    describe 'has rabbit values' do
      before do
        node.set['openstack']['mq']['orchestration']['service_type'] = 'rabbitmq'
      end

      it 'has default rabbit values' do
        [/^rpc_conn_pool_size=30$/,
         /^amqp_durable_queues=false$/,
         /^amqp_auto_delete=false$/,
         /^heartbeat_timeout_threshold=0$/,
         /^heartbeat_rate=2$/
        ].each do |line|
          expect(chef_run).to render_config_file(file.name).with_section_content('oslo_messaging_rabbit', line)
        end
      end

      it 'does not have rabbit ha values' do
        [
          /^rabbit_host=127.0.0.1$/,
          /^rabbit_port=5672$/,
          /^rabbit_ha_queues=False$/
        ].each do |line|
          expect(chef_run).to render_config_file(file.name).with_section_content('oslo_messaging_rabbit', line)
        end
      end

      it 'has rabbit ha values' do
        node.set['openstack']['mq']['orchestration']['rabbit']['ha'] = true
        [
          /^rabbit_hosts=1.1.1.1:5672,2.2.2.2:5672$/,
          /^rabbit_ha_queues=True$/
        ].each do |line|
          expect(chef_run).to render_config_file(file.name).with_section_content('oslo_messaging_rabbit', line)
        end
      end

      it 'does not have ssl config set' do
        [/^rabbit_use_ssl=/,
         /^kombu_ssl_version=/,
         /^kombu_ssl_keyfile=/,
         /^kombu_ssl_certfile=/,
         /^kombu_ssl_ca_certs=/,
         /^kombu_reconnect_delay=/,
         /^kombu_reconnect_timeout=/].each do |line|
          expect(chef_run).not_to render_config_file(file.name).with_section_content('oslo_messaging_rabbit', line)
        end
      end

      it 'sets ssl config' do
        node.set['openstack']['mq']['orchestration']['rabbit']['use_ssl'] = true
        node.set['openstack']['mq']['orchestration']['rabbit']['kombu_ssl_version'] = 'TLSv1.2'
        node.set['openstack']['mq']['orchestration']['rabbit']['kombu_ssl_keyfile'] = 'keyfile'
        node.set['openstack']['mq']['orchestration']['rabbit']['kombu_ssl_certfile'] = 'certfile'
        node.set['openstack']['mq']['orchestration']['rabbit']['kombu_ssl_ca_certs'] = 'certsfile'
        node.set['openstack']['mq']['orchestration']['rabbit']['kombu_reconnect_delay'] = 123.123
        node.set['openstack']['mq']['orchestration']['rabbit']['kombu_reconnect_timeout'] = 123
        [/^rabbit_use_ssl=true/,
         /^kombu_ssl_version=TLSv1.2$/,
         /^kombu_ssl_keyfile=keyfile$/,
         /^kombu_ssl_certfile=certfile$/,
         /^kombu_ssl_ca_certs=certsfile$/,
         /^kombu_reconnect_delay=123.123$/,
         /^kombu_reconnect_timeout=123$/].each do |line|
          expect(chef_run).to render_config_file(file.name).with_section_content('oslo_messaging_rabbit', line)
        end
      end

      it 'has the default rabbit_retry_interval set' do
        expect(chef_run).to render_config_file(file.name).with_section_content('oslo_messaging_rabbit', /^rabbit_retry_interval=1$/)
      end

      it 'has the default rabbit_max_retries set' do
        expect(chef_run).to render_config_file(file.name).with_section_content('oslo_messaging_rabbit', /^rabbit_max_retries=0$/)
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
