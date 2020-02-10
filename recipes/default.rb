include_recipe "java"

domain_name= node['hopsworks']['domain_name']
domains_dir = node['hopsworks']['domains_dir']
# This is set correctly in hopsworks::install by the chef-glassfish recipe. As each recipe has it's own 
# instance of chef we need to re-set it here.
# If you set it in the attributes it will break glassfish installation.
node.override['glassfish']['install_dir'] = "#{node['glassfish']['install_dir']}/glassfish/versions/current"
theDomain="#{domains_dir}/#{domain_name}"

if node['hopsworks']['dela']['enabled'] == "true"
  if node['hopssite']['manual_register'].empty? || node['hopssite']['manual_register'] == "false"
    hopsworks_certs "sign-ca-with-root-hopssite-ca" do
      action :sign_hopssite
    end
  end
end

if not node['zfs']['pools'].eql?("")
  node.override['hopsworks']['zfs_key_rotation_enabled'] = "true"
end  

public_ip=my_public_ip()
hopsworks_db = "hopsworks"
realmname = "kthfsrealm"

begin
  elastic_ips = all_elastic_ips_str()
rescue
  elastic_ips = ""
  Chef::Log.warn "could not find the elastic server ip for HopsWorks!"
end

begin
  hopsworks_ip = private_recipe_ip("hopsworks","default")
rescue
  hopsworks_ip = ""
  Chef::Log.warn "could not find the hopsworks server ip for HopsWorks!"
end

begin
  spark_history_server_ip = private_recipe_ip("hadoop_spark","historyserver")
rescue
  spark_history_server_ip = node['hostname']
  Chef::Log.warn "could not find the spark history server ip for HopsWorks!"
end

begin
  jhs_ip = private_recipe_ip("hops","jhs")
rescue
  jhs_ip = node['hostname']
  Chef::Log.warn "could not find the MR job history server ip!"
end

begin
  rm_ip = private_recipe_ip("hops","rm")
rescue
  rm_ip = node['hostname']
  Chef::Log.warn "could not find the Resource Manager ip!"
end

begin
  rm_port = node['hops']['rm']['http_port']
rescue
  rm_port = 8088
  Chef::Log.warn "could not find the Resource Manager Port!"
end

begin
  logstash_ip = private_recipe_ip("hopslog","default")
rescue
  logstash_ip = node['hostname']
  Chef::Log.warn "could not find the Logstash ip!"
end

begin
  logstash_port = node['logstash']['http']['port']
rescue
  logstash_port = 3456
  Chef::Log.warn "could not find the Logstash Port!"
end

begin
  livy_ip = private_recipe_ip("livy","default")
rescue
  livy_ip = node['hostname']
  Chef::Log.warn "could not find livy server ip!"
end

begin
  epipe_ip = private_recipe_ip("epipe","default")
rescue
  epipe_ip = node['hostname']
  Chef::Log.warn "could not find th epipe server ip!"
end

begin
  zk_ip = private_recipe_ip("kzookeeper","default")
rescue
  zk_ip = node['hostname']
  Chef::Log.warn "could not find th zk server ip!"
end

begin
  kafka_ip = private_recipe_ip("kkafka","default")
rescue
  kafka_ip = node['hostname']
  Chef::Log.warn "could not find the kafka server ip!"
end

begin
  drelephant_ip = private_recipe_ip("drelephant","default")
rescue
  drelephant_ip = node['hostname']
  Chef::Log.warn "could not find the dr elephant server ip!"
end

begin
  dela_ip = private_recipe_ip("dela","default")
rescue
  dela_ip = node['hostname']
  Chef::Log.warn "could not find the dela server ip!"
end

begin
  kibana_ip = private_recipe_ip("hopslog","default")
rescue
  kibana_ip = node['hostname']
  Chef::Log.warn "could not find the logstash server ip!"
end

begin
  grafana_ip = private_recipe_ip("hopsmonitor","default")
  influxdb_ip = private_recipe_ip("hopsmonitor","default")
rescue
  grafana_ip = node['hostname']
  influxdb_ip = node['hostname']
  Chef::Log.warn "could not find the hopsmonitor server ip!"
end

begin
  hiveserver_ip = private_recipe_ip("hive2","default")
rescue
  hiveserver_ip = node['hostname']
  Chef::Log.warn "could not find the Hive server ip!"
end

begin
  python_kernel = "#{node['jupyter']['python']}".downcase
rescue
  python_kernel = "true"
  Chef::Log.warn "could not find the jupyter/python variable defined as an attribute!"
end



exec = "#{node['ndb']['scripts_dir']}/mysql-client.sh"

bash 'create_hopsworks_db' do
  user "root"
  code <<-EOF
      set -e
      #{exec} -e \"CREATE DATABASE IF NOT EXISTS #{node['hopsworks']['db']} CHARACTER SET latin1\"
    EOF
end

timerTable = "ejbtimer_mysql.sql"
timerTablePath = "#{Chef::Config['file_cache_path']}/#{timerTable}"

# Need to delete the sql file so that the create_timers action is triggered
file timerTablePath do
  action :delete
  ignore_failure true
end

hopsworks_grants "timers_tables" do
  tables_path  "#{timerTablePath}"
  rows_path  ""
  action :nothing
end

template timerTablePath do
  source File.basename("#{timerTablePath}") + ".erb"
  owner node['glassfish']['user']
  mode 0750
  action :create
  notifies :create_timers, 'hopsworks_grants[timers_tables]', :immediately
end

require 'resolv'
hostf = Resolv::Hosts.new
dns = Resolv::DNS.new

hosts = ""

for h in node['kagent']['default']['private_ips']

  # Try and resolve hostname first using /etc/hosts, then use DNS
  begin
    hname = hostf.getname(h)
  rescue
    begin
      hname = dns.getname(h)
    rescue
      raise "Cannot resolve the hostname for IP address: #{h}"
    end
  end

  hosts += "('" + hname.to_s + "','" + h + "')" + ","
end
if h.length > 0
  hosts = hosts.chop!
end

hops_rpc_tls_val = "false"
if node['hops']['tls']['enabled'].eql? "true"
  hops_rpc_tls_val = "true"
end

hdfs_ui_port = node['hops']['nn']['http_port']
if node['hops']['tls']['enabled'].eql? "true"
  hdfs_ui_port = node['hops']['dfs']['https']['port']
end

condaRepo = 'defaults'
if node['conda']['channels']['default_mirrors'].empty? == false
   repos = node['conda']['channels']['default_mirrors'].split(/\s*,\s*/)
   condaRepo = repos[0]
end

nonconda_hosts_list = []
if node['hopsworks']['nonconda_hosts'].empty? == false
  nonconda_hosts_list = node['hopsworks']['nonconda_hosts'].split(/\s*,\s*/)
end

mysql_host = private_recipe_ip("ndb","mysqld")

featurestore_jdbc_url = node['featurestore']['jdbc_url']
featurestore_jdbc_url_escaped = featurestore_jdbc_url.gsub(':', '\\\\:')
# In case of an upgrade, attribute-driven-domain will not run but we still need to configure
# connection pool for the online featurestore
if node['featurestore']['jdbc_url'].eql? "localhost"
  featurestore_jdbc_url="jdbc:mysql://#{mysql_host}:#{node['ndb']['mysql_port']}/"
  featurestore_jdbc_url_escaped="\"jdbc\\:mysql\\://#{mysql_host}\\:#{node['ndb']['mysql_port']}/\""
end

# hops-util-py only works for localhost installations if you disable TLS hostname validations
if node['install']['localhost'].eql? "true"
  node.override['hopsworks']['requests_verify'] = "false"
end  


# Hive metastore should be created before the hopsworks tables are created
# Hopsworks 0.8.0 introduce tables with foreign keys to Hive metastore (feature store service)
include_recipe "hive2::db"

versions = node['hopsworks']['versions'].split(/\s*,\s*/)
target_version = node['hopsworks']['version'].sub("-SNAPSHOT", "")
versions.push(target_version)
current_version = node['hopsworks']['current_version']

# download client archive and set its path to be added to the variables table
if node['install']['enterprise']['install'].casecmp? "true"
  file_name = "clients.tar.gz"
  client_dir = "#{node['install']['dir']}/clients-#{node['hopsworks']['version']}"

  directory client_dir do
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode "775"
    action :create
    recursive true
  end

  node.override['hopsworks']['client_path']="#{client_dir}/#{file_name}"
  source = "#{node['install']['enterprise']['download_url']}/remote_clients/#{node['hopsworks']['version']}/#{file_name}"
  remote_file "#{node['hopsworks']['client_path']}" do
    user node['glassfish']['user']
    group node['glassfish']['group']
    source source
    headers get_ee_basic_auth_header()
    sensitive true
    mode 0555
    action :create_if_missing
  end
end

if current_version.eql?("")

  # Make sure the database is actually empty. Otherwise raise an error
  ruby_block "check_db_empty" do 
    block do
      raise "You are trying to initialize the database, but the database is not empty. Either there is a failed migration, or you forgot to set the current_version attribute"
    end
    only_if "#{node['ndb']['scripts_dir']}/mysql-client.sh hopsworks -e \"SHOW TABLES\" | grep project"
  end

  # New installation -> template the current version schema file
  cookbook_file "#{theDomain}/flyway/sql/V#{target_version}__initial_tables.sql" do
    source "sql/ddl/#{target_version}__initial_tables.sql"
    owner node['glassfish']['user']
    mode 0750
    action :create
  end
else
  current_version_idx = versions.index(current_version).to_i
  versions_length = versions.length.to_i - 1

  for i in (current_version_idx + 1)..versions_length
    # Update, template all the dml files from the current version to the target version
    cookbook_file "#{theDomain}/flyway/sql/V#{versions[i]}__hopsworks.sql" do
      source "sql/ddl/updates/#{versions[i]}.sql"
      owner node['glassfish']['user']
      mode 0750
      action :create
    end

    cookbook_file "#{theDomain}/flyway/undo/U#{versions[i]}__undo.sql" do
      source "sql/ddl/updates/undo/#{versions[i]}__undo.sql"
      owner node['glassfish']['user']
      mode 0750
      action :create
    end
  end
end

unless node['install']['cloud'].strip.empty?
  node.override['hopsworks']['reserved_project_names'] = "#{node['hopsworks']['reserved_project_names']},cloud"
end

for version in versions do
  # Template DML files
  template "#{theDomain}/flyway/dml/V#{version}__hopsworks.sql" do
    source "sql/dml/#{version}.sql.erb"
    owner node['glassfish']['user']
    mode 0750
    variables({
         :user_cert_valid_days => node['hopsworks']['cert']['user_cert_valid_days'],
         :conda_repo => condaRepo,
         :hosts => hosts,
         :epipe_ip => epipe_ip,
         :livy_ip => livy_ip,
         :jhs_ip => jhs_ip,
         :rm_ip => rm_ip,
         :rm_port => rm_port,
         :logstash_ip => logstash_ip,
         :logstash_port => logstash_port,
         :spark_history_server_ip => spark_history_server_ip,
         :hopsworks_ip => hopsworks_ip,
         :elastic_ip => elastic_ips,
         :yarn_ui_ip => public_recipe_ip("hops","rm"),
         :hdfs_ui_ip => public_recipe_ip("hops","nn"),
         :hdfs_ui_port => hdfs_ui_port,
         :hopsworks_dir => theDomain,
         :hops_rpc_tls => hops_rpc_tls_val,
         :yarn_default_quota => node['hopsworks']['yarn_default_quota_mins'].to_i * 60,
         :hdfs_default_quota => node['hopsworks']['hdfs_default_quota_mbs'].to_i,
         :hive_default_quota => node['hopsworks']['hive_default_quota_mbs'].to_i,
         :featurestore_default_quota => node['hopsworks']['featurestore_default_quota_mbs'].to_i,
         :zk_ip => zk_ip,
         :java_home => node['java']['java_home'],
         :drelephant_ip => drelephant_ip,
         :kafka_ip => kafka_ip,
         :kibana_ip => kibana_ip,
         :python_kernel => python_kernel,
         :grafana_ip => grafana_ip,
         :influxdb_ip => influxdb_ip,
         :public_ip => public_ip,
         :dela_ip => dela_ip,
         :hivessl_hostname => hiveserver_ip + ":#{node['hive2']['portssl']}",
         :hiveext_hostname => hiveserver_ip + ":#{node['hive2']['port']}",
         :nonconda_hosts_list => nonconda_hosts_list,
         :krb_ldap_auth => node['ldap']['enabled'].to_s == "true" || node['kerberos']['enabled'].to_s == "true",
         :featurestore_jdbc_url => featurestore_jdbc_url
    })
    action :create
  end

  template "#{theDomain}/flyway/dml/undo/U#{version}__undo.sql" do
    source "sql/dml/undo/#{version}__undo.sql.erb"
    owner node['glassfish']['user']
    mode 0750
    action :create
  end
end

if !current_version.eql?("") && Gem::Version.new(current_version) < Gem::Version.new('0.6.0')
 cookbook_file "#{theDomain}/flyway/sql/flyway_schema_history_0.6.0.sql" do
  source "sql/flyway_schema_history_0.6.0.sql"
  owner node['glassfish']['user']
  mode 0750
  action :create
 end

 # Re-create the table only if it already exists
 bash "mod_flyway_history_0.6.0" do
  user "root"
  code <<-EOH
    #{node['ndb']['scripts_dir']}/mysql-client.sh hopsworks < #{theDomain}/flyway/sql/flyway_schema_history_0.6.0.sql
  EOH
  only_if "#{node['ndb']['scripts_dir']}/mysql-client.sh hopsworks -e \"select version from flyway_schema_history where script like 'V%' order by installed_on desc\" | grep -v \"0.6.0\""
 end
end

bash "flyway_migrate" do
  user "root"
  cwd "#{theDomain}/flyway"
  code <<-EOF
    #{theDomain}/flyway/flyway migrate
  EOF
end

# Run the DML sql script to insert the variables
for version in versions do
  bash "run_inserts_#{version}" do
    user "root"
    code <<-EOH
      #{node['ndb']['scripts_dir']}/mysql-client.sh hopsworks < #{theDomain}/flyway/dml/V#{version}__hopsworks.sql
    EOH
  end
end

# Check if Kafka is to be installed and create user with grants
begin
  valid_recipe("kkafka", "default")
  Chef::Log.info "Found kafka cookbooks, will proceed to create db user for Kafka"

  # Create kafka user and grant privileges. We do this here because we need this command to be executed at a host with
  # a MySQL server
  bash 'create_and_grant_kafka' do
    user "root"
    code <<-EOF
      set -e
      #{exec} -e \"CREATE USER IF NOT EXISTS #{node['hopsworks']['mysql']['user']['kafka']} IDENTIFIED BY \'#{node['hopsworks']['mysql']['password']['kafka']}\';\"
      #{exec} -e \"GRANT SELECT ON #{node['hopsworks']['db']}.topic_acls TO \'#{node['hopsworks']['mysql']['user']['kafka']}\'@\'%\';\"
      #{exec} -e \"GRANT SELECT ON #{node['hopsworks']['db']}.project TO \'#{node['hopsworks']['mysql']['user']['kafka']}\'@\'%\'\"
      #{exec} -e \"GRANT SELECT ON #{node['hopsworks']['db']}.users TO \'#{node['hopsworks']['mysql']['user']['kafka']}\'@\'%\';\"
      #{exec} -e \"GRANT SELECT ON #{node['hopsworks']['db']}.project_team TO \'#{node['hopsworks']['mysql']['user']['kafka']}\'@\'%\';\"
    EOF
  end
rescue
  Chef::Log.info "Kafka will not be installed, skipped creating DB user."
end

###############################################################################
# config glassfish
###############################################################################

username = node['hopsworks']['admin']['user']
password = node['hopsworks']['admin']['password']
admin_port = node['hopsworks']['admin']['port']

jndiDB = "jdbc/hopsworks"

asadmin = "#{node['glassfish']['base_dir']}/versions/current/bin/asadmin"
admin_pwd = "#{domains_dir}/#{domain_name}_admin_passwd"

password_file = "#{domains_dir}/#{domain_name}_admin_passwd"

template "#{domains_dir}/#{domain_name}/config/login.conf" do
  cookbook 'hopsworks'
  source "login.conf.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode "0600"
  action :create
end

template "#{domains_dir}/#{domain_name}/config/log4j.properties" do
  cookbook 'hopsworks'
  source "log4j.properties.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
end

# Add Hadoop glob classpath and HADOOP_CONF_DIR to Glassfish
# systemd unit environment variables file
hadoop_glob_command = "#{node['hops']['bin_dir']}/hadoop classpath --glob"
ruby_block "export_hadoop_classpath" do
  block do
    Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
    exec_stdout = shell_out(hadoop_glob_command).stdout
    variable = "HADOOP_GLOB=#{exec_stdout}"
    file = Chef::Util::FileEdit.new(node['hopsworks']['env_var_file'])
    file.insert_line_if_no_match(/#{variable}/, variable)
    hadoop_conf_dir_var = "HADOOP_CONF_DIR=#{node['hops']['conf_dir']}"
    file.insert_line_if_no_match(/#{variable}/, hadoop_conf_dir_var)
    file.write_file
  end
  action :create
end

hopsworks_grants "restart_glassfish" do
  action :reload_systemd
end

glassfish_secure_admin domain_name do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  action :enable
end

props =  {
  'datasource-jndi' => jndiDB,
  'password-column' => 'password',
  'group-table' => 'hopsworks.users_groups',
  'user-table' => 'hopsworks.users',
  'group-name-column' => 'group_name',
  'user-name-column' => 'email',
  'group-table-user-name-column' => 'email',
  'encoding' => 'Hex',
  'digestrealm-password-enc-algorithm' => 'SHA-256',
  'digest-algorithm' => 'SHA-256'
}

 glassfish_auth_realm "#{realmname}" do
   realm_name "#{realmname}"
   jaas_context "jdbcRealm"
   properties props
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
   classname "com.sun.enterprise.security.auth.realm.jdbc.JDBCRealm"
 end


 cProps = {
     'datasource-jndi' => jndiDB,
     'password-column' => 'password',
     'encoding' => 'Hex',
     'group-table' => 'hopsworks.users_groups',
     'user-table' => 'hopsworks.users',
     'group-name-column' => 'group_name',
     'user-name-column' => 'email',
     'group-table-user-name-column' => 'email',
     'otp-secret-column' => 'secret',
     'two-factor-column' => 'two_factor',
     'user-status-column' => 'status',
     'yubikey-table' => 'hopsworks.yubikey',
     'variables-table' => 'hopsworks.variables'
 }

 glassfish_auth_realm "cauthRealm" do
   realm_name "cauthRealm"
   jaas_context "cauthRealm"
   properties cProps
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
   classname "io.hops.crealm.CustomAuthRealm"
 end

# Enable JMX metrics
glassfish_asadmin "set-monitoring-configuration --dynamic true --enabled true --amx true --logfrequency 15 --logfrequencyunit SECONDS" do 
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

glassfish_conf = {
  'server-config.security-service.default-realm' => 'cauthRealm',
  # Jobs in Hopsworks use the Timer service
  'server-config.ejb-container.ejb-timer-service.timer-datasource' => 'jdbc/hopsworksTimers',
  'server.ejb-container.ejb-timer-service.property.reschedule-failed-timer' => node['glassfish']['reschedule_failed_timer'],
  'server.http-service.virtual-server.server.property.send-error_1' => "\"code=404 path=#{domains_dir}/#{domain_name}/docroot/404.html reason=Resource_not_found\"",
  # Enable/Disable HTTP listener
  'configs.config.server-config.network-config.network-listeners.network-listener.http-listener-1.enabled' => false,
  # Make sure the https listener is listening on the requested port 
  'configs.config.server-config.network-config.network-listeners.network-listener.http-listener-2.port' => node['hopsworks']['https']['port'],
  # Disable SSL3
  'server.network-config.protocols.protocol.http-listener-2.ssl.ssl3-enabled' => false, 
  'server.network-config.protocols.protocol.sec-admin-listener.ssl.ssl3-enabled' => false,
  # Disable TLS 1.0
  'server.network-config.protocols.protocol.http-listener-2.ssl.tls-enabled' => false,
  'server.network-config.protocols.protocol.sec-admin-listener.ssl.tls-enabled' => false,
  # Restrict ciphersuite
  'configs.config.server-config.network-config.protocols.protocol.http-listener-2.ssl.ssl3-tls-ciphers' => node['glassfish']['ciphersuite'],
  'configs.config.server-config.network-config.protocols.protocol.sec-admin-listener.ssl.ssl3-tls-ciphers' => node['glassfish']['ciphersuite'],
  # Set correct thread-priority for the executor services - required during updates
  'resources.managed-executor-service.concurrent\/hopsExecutorService.thread-priority' => 10,
  'resources.managed-thread-factory.concurrent\/hopsThreadFactory.thread-priority' => 10,
  # Enable Single Sign on
  'configs.config.server-config.http-service.virtual-server.server.sso-enabled' => true,
  'configs.config.server-config.http-service.virtual-server.server.sso-cookie-http-only' => true,
  # Allow following symlinks from docroot
  'server-config.http-service.virtual-server.server.property.allowLinking' => true,
  # Configure metrics and JMX
  'configs.config.server-config.monitoring-service.module-monitoring-levels.jvm' => 'HIGH',
  'configs.config.server-config.monitoring-service.module-monitoring-levels.connector-service' => 'HIGH',
  'configs.config.server-config.monitoring-service.module-monitoring-levels.connector-connection-pool' => 'HIGH',
  'configs.config.server-config.monitoring-service.module-monitoring-levels.jdbc-connection-pool' => 'HIGH',
  'configs.config.server-config.monitoring-service.module-monitoring-levels.web-services-container' => 'HIGH',
  'configs.config.server-config.monitoring-service.module-monitoring-levels.thread-pool' => 'HIGH',
  'configs.config.server-config.monitoring-service.module-monitoring-levels.http-service' => 'HIGH',
  'configs.config.server-config.monitoring-service.module-monitoring-levels.security' => 'HIGH',
  'configs.config.server-config.monitoring-service.module-monitoring-levels.jersey' => 'HIGH',
  'configs.config.server-config.monitoring-service.module-monitoring-levels.transaction-service' => 'HIGH',
  'configs.config.server-config.monitoring-service.module-monitoring-levels.jpa' => 'HIGH',
  'configs.config.server-config.monitoring-service.module-monitoring-levels.web-container' => 'HIGH',
  'server.network-config.protocols.protocol.http-listener-2.http.timeout-seconds' => node['glassfish']['http']['keep_alive_timeout'],
  'server.network-config.protocols.protocol.http-listener-1.http.timeout-seconds' => node['glassfish']['http']['keep_alive_timeout']
}

glassfish_conf.each do |property, value|
  glassfish_asadmin "set #{property}=#{value}" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
  end
end

glassfish_asadmin "create-managed-executor-service --enabled=true --longrunningtasks=true --corepoolsize=10 --maximumpoolsize=200 --keepaliveseconds=60 --taskqueuecapacity=10000 concurrent/kagentExecutorService" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-managed-executor-services | grep 'kagent'"
end

airflow_exists = false
if exists_local("hops_airflow", "default")
  airflow_exists = true
  # In case of an upgrade, attribute-driven-domain will not run but we still need to configure
  # connection pool for Airflow
  glassfish_asadmin "create-jdbc-connection-pool --restype javax.sql.DataSource --datasourceclassname com.mysql.jdbc.jdbc2.optional.MysqlDataSource --ping=true --isconnectvalidatereq=true --validationmethod=auto-commit --description=\"Airflow connection pool\" --property user=#{node['airflow']['mysql_user']}:password=#{node['airflow']['mysql_password']}:url=\"jdbc\\:mysql\\://#{mysql_host}\\:3306/\" airflowPool" do
    domain_name domain_name
    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
    username username
    admin_port admin_port
    secure false
    not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-jdbc-connection-pools | grep 'airflowPool'"
  end

  glassfish_asadmin "create-jdbc-resource --connectionpoolid airflowPool --description \"Airflow jdbc resource\" jdbc/airflow" do
    domain_name domain_name
    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
    username username
    admin_port admin_port
    secure false
    not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-jdbc-resources | grep 'jdbc/airflow'"
  end
end

glassfish_asadmin "create-jdbc-connection-pool --restype javax.sql.DataSource --datasourceclassname com.mysql.jdbc.jdbc2.optional.MysqlDataSource --ping=true --isconnectvalidatereq=true --validationmethod=auto-commit --description=\"Featurestore connection pool\" --property user=#{node['featurestore']['user']}:password=#{node['featurestore']['password']}:url=#{featurestore_jdbc_url_escaped} featureStorePool" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-jdbc-connection-pools | grep 'featureStorePool'"
end

glassfish_asadmin "create-jdbc-resource --connectionpoolid featureStorePool --description \"Featurestore jdbc resource\" jdbc/featurestore" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-jdbc-resources | grep 'jdbc/featurestore'"
end


logging_conf = {
  'com.sun.enterprise.server.logging.GFFileHandler.logtoFile' => true,
  'com.sun.enterprise.server.logging.GFFileHandler.rotationLimitInBytes' => node['hopsworks']['logsize'],
  # These are just some random number, we are not enabling this logger. However if they are not set
  # the main logger doesn't work either. 
  'fish.payara.enterprise.server.logging.PayaraNotificationFileHandler.rotationLimitInBytes' => 2000000,  
  'fish.payara.enterprise.server.logging.PayaraNotificationFileHandler.rotationTimelimitInMinutes' => 0,
  'fish.payara.enterprise.server.logging.PayaraNotificationFileHandler.maxHistoryFiles' => 3
}

logging_conf.each do |property, value|
  glassfish_asadmin "set-log-attributes #{property}=#{value}" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
  end
end

loglevels_conf = {
  'fish.payara.nucleus.notification.log.LogNotifierService' => 'SEVERE'
}

loglevels_conf.each do |property, value|
  glassfish_asadmin "set-log-levels #{property}=#{value}" do 
    domain_name domain_name
    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
    username username
    admin_port admin_port
    secure false
  end
end

if node['ldap']['enabled'].to_s == "true" || node['kerberos']['enabled'].to_s == "true"
  ldap_jndilookupname= node['ldap']['jndilookupname']
  ldap_jndilookupname=ldap_jndilookupname.gsub('=', '\\\\=').gsub(',', '\\\\,')
  ldap_provider_url=node['ldap']['provider_url']
  ldap_provider_url=ldap_provider_url.gsub(':', '\\\\\:').gsub('.', '\\\\.')
  ldap_attr_binary=node['ldap']['attr_binary_val']
  ldap_sec_auth=node['ldap']['security_auth']
  ldap_security_auth=ldap_sec_auth.to_s.empty? ? "" : ":SECURITY_AUTHENTICATION=#{ldap_sec_auth}"
  ldap_sec_principal=node['ldap']['security_principal']
  ldap_sec_principal=ldap_sec_principal.gsub('=', '\\\\\=')
  ldap_security_principal=ldap_sec_principal.to_s.empty? ? "" : ":SECURITY_PRINCIPAL=#{ldap_sec_principal}"
  ldap_sec_credentials=node['ldap']['security_credentials']
  ldap_security_credentials=ldap_sec_credentials.to_s.empty? ? "" : ":SECURITY_CREDENTIALS=#{ldap_sec_credentials}"
  ldap_ref=node['ldap']['referral']
  ldap_referral=ldap_ref.to_s.empty? ? "" : ":REFERRAL=#{ldap_ref}"
  ldap_props=node['ldap']['additional_props']
  ldap_properties=ldap_props.to_s.empty? ? "" : ":#{ldap_props}"

  glassfish_asadmin "create-jndi-resource --restype javax.naming.ldap.LdapContext --factoryclass com.sun.jndi.ldap.LdapCtxFactory --jndilookupname #{ldap_jndilookupname} --property java.naming.provider.url=#{ldap_provider_url}:java.naming.ldap.attributes.binary=#{ldap_attr_binary}#{ldap_security_auth}#{ldap_security_principal}#{ldap_security_credentials}#{ldap_referral}#{ldap_properties} ldap/LdapResource" do
     domain_name domain_name
     password_file "#{domains_dir}/#{domain_name}_admin_passwd"
     username username
     admin_port admin_port
     secure false
     not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-jndi-resources | grep 'ldap/LdapResource'"
  end
end

if node['kerberos']['enabled'].to_s == "true" && !node['kerberos']['krb_conf_path'].to_s.empty? 
  krb_conf_path = node['kerberos']['krb_conf_path']
  remote_file "#{theDomain}/config/krb5.conf" do
    source "file:///#{krb_conf_path}"
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode "0600"
    action :create
  end
end

if node['kerberos']['enabled'].to_s == "true" && !node['kerberos']['krb_server_key_tab_path'].to_s.empty? 
  key_tab_path = node['kerberos']['krb_server_key_tab_path']
  ket_tab_name = node['kerberos']['krb_server_key_tab_name']
  remote_file "#{theDomain}/config/#{ket_tab_name}" do
    source "file:///#{key_tab_path}"
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode "0600"
    action :create
  end
end

if node['hopsworks']['http_logs']['enabled'].eql? "true"
  http_logging_conf = {
    # Enable http logging
    'server.http-service.access-logging-enabled' => 'true',
    # If you change the suffix, you should also change dump_web_logs_to_hdfs.sh.erb file
    # ':' is not a legal filename character in HDFS, thus '_'
    'server.http-service.access-log.rotation-suffix' => 'yyyy-MM-dd-kk_mm',
    'server.http-service.access-log.max-history-files' => '10',
    'server.http-service.access-log.buffer-size-bytes' => '32768',
    'server.http-service.access-log.write-interval-seconds' => '120',
    'server.http-service.access-log.rotation-interval-in-minutes' => "1400"
  }

  http_logging_conf.each do |property, value|
    glassfish_asadmin "set #{property}=#{value}" do
      domain_name domain_name
      password_file "#{domains_dir}/#{domain_name}_admin_passwd"
      username username
      admin_port admin_port
      secure false
    end
  end

  # Setup cron job for HDFS dumper
  cron 'dump_http_logs_to_hdfs' do
    if node['hopsworks']['systemd'] == "true"
      command "systemd-cat #{domains_dir}/#{domain_name}/bin/dump_web_logs_to_hdfs.sh"
    else #sysv
      command "#{domains_dir}/#{domain_name}/bin/dump_web_logs_to_hdfs.sh >> #{domains_dir}/#{domain_name}/logs/web_dumper.log 2>&1"
    end
    user node['glassfish']['user']
    minute '0'
    hour '21'
    day '*'
    month '*'
    only_if do File.exist?("#{domains_dir}/#{domain_name}/bin/dump_web_logs_to_hdfs.sh") end
  end
end

if node['hopsworks']['audit_log_dump_enabled'].eql? "true"
  # Setup cron job for HDFS dumper
  cron 'dump_audit_logs_to_hdfs' do
    command "systemd-cat #{domains_dir}/#{domain_name}/bin/dump_audit_logs_to_hdfs.sh"
    user node['glassfish']['user']
    minute '0'
    hour '21'
    day '*'
    month '*'
    only_if do File.exist?("#{domains_dir}/#{domain_name}/bin/dump_audit_logs_to_hdfs.sh") end
  end
end

hopsworks_mail "gmail" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   action :jndi
end

node.override['glassfish']['asadmin']['timeout'] = 400

if node['install']['enterprise']['install'].casecmp? "true"
  node.override['hopsworks']['ear_url'] = "#{node['install']['enterprise']['download_url']}/hopsworks/#{node['hopsworks']['version']}/hopsworks-ear#{node['install']['kubernetes'].casecmp?("true") == 0 ? "-kube" : ""}.ear"
  node.override['hopsworks']['war_url'] = "#{node['install']['enterprise']['download_url']}/hopsworks/#{node['hopsworks']['version']}/hopsworks-web.war"
  node.override['hopsworks']['ca_url'] = "#{node['install']['enterprise']['download_url']}/hopsworks/#{node['hopsworks']['version']}/hopsworks-ca.war"  
end

glassfish_deployable "hopsworks-ear" do
  component_name "hopsworks-ear:#{node['hopsworks']['version']}"
  target "server"
  url node['hopsworks']['ear_url']
  auth_username node['install']['enterprise']['username']
  auth_password node['install']['enterprise']['password']
  version node['hopsworks']['version']
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  action :deploy
  async_replication false
  retries 1
  keep_state true
  enabled true
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-applications --type ejb | grep -w \"hopsworks-ear:#{node['hopsworks']['version']}\""
end

glassfish_deployable "hopsworks" do
  component_name "hopsworks-web:#{node['hopsworks']['version']}"
  target "server"
  url node['hopsworks']['war_url']
  auth_username node['install']['enterprise']['username']
  auth_password node['install']['enterprise']['password']  
  version node['hopsworks']['version']
  context_root "/hopsworks"
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  action :deploy
  async_replication false
  retries 1
  keep_state true
  enabled true
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-applications --type web | grep -w \"hopsworks-web:#{node['hopsworks']['version']}\""
end

glassfish_deployable "hopsworks-ca" do
  component_name "hopsworks-ca:#{node['hopsworks']['version']}"
  target "server"
  url node['hopsworks']['ca_url']
  auth_username node['install']['enterprise']['username']
  auth_password node['install']['enterprise']['password']  
  version node['hopsworks']['version']
  context_root "/hopsworks-ca"
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  action :deploy
  async_replication false
  retries 1
  keep_state true
  enabled true
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-applications --type ejb | grep -w \"hopsworks-ca:#{node['hopsworks']['version']}\""
end


#
# If deployment of the new version succeeds, then undeploy the previous version
#

glassfish_deployable "undeploy_hopsworks-ear" do
  component_name "hopsworks-ear:#{previous_version}"
  target "server"
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure true
  action :undeploy
end

glassfish_deployable "undeploy_hopsworks-war" do
  component_name "hopsworks-web:#{previous_version}"
  target "server"
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure true
  action :undeploy
end

glassfish_deployable "undeploy_hopsworks-ca" do
  component_name "hopsworks-ca:#{previous_version}"
  target "server"
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure true
  action :undeploy
end


template "/bin/hopsworks-2fa" do
    source "hopsworks-2fa.erb"
    owner "root"
    mode 0700
    action :create
 end

hopsworks_certs "generate-certs" do
  action :generate
end

# Since Hopsworks v1.1 we don't need the symlink
link "delete-crl-symlink" do
  target_file "#{domains_dir}/#{domain_name}/docroot/intermediate.crl.pem"
  action :delete
end

template "#{::Dir.home(node['hopsworks']['user'])}/.condarc" do
  source "condarc.erb"
  cookbook "conda"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode 0750
  variables({
    :pkgs_dirs => node['hopsworks']['conda_cache'] 
  })
  action :create
end

case node['platform_family']
 when 'debian'
   package "scala"

 when 'rhel'

  scala_rpm_path="#{Chef::Config['file_cache_path']}/scala-#{node['scala']['version']}.rpm"
  remote_file scala_rpm_path do
    source node['scala']['download_url'] 
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end

  bash 'scala-install-redhat' do
    user "root"
    cwd Chef::Config['file_cache_path']
    code <<-EOF
      set -e  
      yum install -y scala-#{node['scala']['version']}.rpm
    EOF
    not_if "which scala"
  end
end

homedir = "/home/#{node['hopsworks']['user']}"
#
# Disable glassfish service, if node['services']['enabled'] is not set to true
#
if node['services']['enabled'] != "true"
  service "glassfish-domain1" do
    provider Chef::Provider::Service::Systemd
    supports :restart => true, :stop => true, :start => true, :status => true
    action :disable
  end
end

#  Template metrics.xml to expose metrics
template "#{theDomain}/config/metrics.xml"  do
  source 'metrics.xml.erb'
  owner node['hopsworks']['user']
  group node['hopsworks']['group']
  mode "700"
  action :create
  variables({
    :airflow_exists => airflow_exists
  })
end

directory node['hopsworks']['staging_dir']  do
  owner node['hopsworks']['user']
  group node['hopsworks']['group']
  mode "775"
  action :create
  recursive true
end

directory node['hopsworks']['staging_dir'] + "/private_dirs"  do
  owner node['jupyter']['user']
  group node['hopsworks']['group']
  mode "0370"
  action :create
end

directory node['hopsworks']['staging_dir'] + "/serving"  do
  owner node['serving']['user']
  group node['hopsworks']['group']
  mode "0730"
  action :create
end

directory node['hopsworks']['staging_dir'] + "/tensorboard"  do
  owner node['conda']['user']
  group node['hopsworks']['group']
  mode "0770"
  action :create
end

directory node['hopsworks']['conda_cache'] do
  owner node['hopsworks']['user']
  group node['hopsworks']['group']
  mode "0700"
  action :create
end

kagent_keys "#{homedir}" do
  cb_user node['hopsworks']['user']
  cb_group node['hopsworks']['group']
  action :generate
end

kagent_keys "#{homedir}" do
  cb_user node['hopsworks']['user']
  cb_group node['hopsworks']['group']
  cb_name "hopsworks"
  cb_recipe "default"
  action :return_publickey
end

if node['kagent']['enabled'].casecmp? "true"
  kagent_config "glassfish-domain1" do
    service "glassfish_#{node['hopsworks']['domain_name']}"
    log_file "#{node['hopsworks']['domains_dir']}/#{node['hopsworks']['domain_name']}/logs/server.log"
    restart_agent false
  end
end

# Generate a service JWT token and renewal one-time tokens to be used internally in Hopsworks
ruby_block "generate_service_jwt" do
  block do
    master_token, renew_tokens = get_service_jwt()
    sql_command_template = "#{node['ndb']['scripts_dir']}/mysql-client.sh -e \"REPLACE INTO hopsworks.variables(id, value) VALUE ('%s', '%s');\""
    master_token_command = sql_command_template % ['service_master_jwt', master_token]
    execute_shell_command master_token_command

    idx = 0
    variable_key_template = "service_renew_token_%d"
    renew_tokens.each do |token|
      variable_key = variable_key_template % idx
      renew_token_command = sql_command_template % [variable_key, token]
      execute_shell_command renew_token_command
      idx += 1
    end
  end
end

# Force variables reload
hopsworks_grants "restart_glassfish" do
  action :reload_systemd
end

template "#{domains_dir}/#{domain_name}/bin/letsencrypt.sh" do
  source "letsencrypt.sh.erb"
  owner node['glassfish']['user']
  mode 0770
  action :create
end

directory "/usr/local/share/jupyter/nbextensions/witwidget"  do
  owner "root"
  group "root"
  mode "775"
  action :create
  recursive true
end

include_recipe "tensorflow::serving"

link "#{node['kagent']['certs_dir']}/cacerts.jks" do
  owner node['glassfish']['user']
  group node['glassfish']['group']
  to "#{theDomain}/config/cacerts.jks"
end

#
# Need to synchronize conda enviornments for newly joined or rejoining nodes.
#
package "rsync"

homedir = node['hopsworks']['user'].eql?("root") ? "/root" : "/home/#{node['hopsworks']['user']}"
Chef::Log.info "Home dir is #{homedir}. Generating ssh keys..."

kagent_keys "#{homedir}" do
  cb_user node['hopsworks']['user']
  cb_group node['hopsworks']['group']
  action :generate
end

kagent_keys "#{homedir}" do
  cb_user node['hopsworks']['user']
  cb_group node['hopsworks']['group']
  cb_name "hopsworks"
  cb_recipe "default"
  action :return_publickey
end


#
# Rstudio
#

if node['rstudio']['enabled'].eql? "true"

  case node['platform']
  when 'debian', 'ubuntu'
    package "r-base"

    remote_file "#{Chef::Config['file_cache_path']}/#{node['rstudio']['deb']}" do
      user node['glassfish']['user']
      group node['glassfish']['group']
      source node['download_url'] + "/#{node['rstudio']['deb']}"
      mode 0755
      action :create
    end

    bash 'install_rstudio_debian' do
      user "root"
      code <<-EOF
      set -e
      cd #{Chef::Config['file_cache_path']}
      apt-get install gdebi-core -y
      gdebi #{node['rstudio']['deb']}
    EOF
    end

  when 'redhat', 'centos', 'fedora'

    remote_file "#{Chef::Config['file_cache_path']}/#{node['rstudio']['rpm']}" do
      user node['glassfish']['user']
      group node['glassfish']['group']
      source node['download_url'] + "/#{node['rstudio']['rpm']}"
      mode 0755
      action :create
    end

    bash 'install_rstudio_rhel' do
      user "root"
      code <<-EOF
      set -e
      cd #{Chef::Config['file_cache_path']}
      yum install --nogpgcheck #{node['rstudio']['rpm']} -y
    EOF
    end

  end

  bash 'disable_rstudio_systemd_daemons' do
    user "root"
    ignore_failure true
    code <<-EOF
      systemctl stop rstudio-server
      systemctl disable rstudio-server
    EOF
  end
end

