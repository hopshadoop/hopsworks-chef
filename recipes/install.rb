require 'json'
require 'base64'
require 'digest'

domain_name="domain1"
domains_dir = node['hopsworks']['domains_dir']
theDomain="#{domains_dir}/#{domain_name}"
password_file = "#{theDomain}_admin_passwd"

bash "systemd_reload_for_glassfish_failures" do
  user "root"
  ignore_failure true
  code <<-EOF
    systemctl stop glassfish-#{domain_name}
    systemctl daemon-reload
  EOF
end

if node['hopsworks']['systemd'] == "true"
  systemd = true
else
  systemd = false
end

group node['hopsworks']['group'] do
  action :create
  not_if "getent group #{node['hopsworks']['group']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

#
# hdfs superuser group is 'hdfs'
#
group node['hops']['hdfs']['user'] do
  action :create
  not_if "getent group #{node['hops']['hdfs']['user']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

user node['hopsworks']['user'] do
  home node['glassfish']['user-home']
  gid node['hopsworks']['group']
  action :create
  shell "/bin/bash"
  manage_home true
  not_if "getent passwd #{node['hopsworks']['user']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

group node["kagent"]["certs_group"] do
  action :manage
  append true
  excluded_members node['hopsworks']['user']
  not_if { node['install']['external_users'].casecmp("true") == 0 }
  only_if { conda_helpers.is_upgrade }
end

group node['conda']['group'] do
  action :modify
  members ["#{node['hopsworks']['user']}"]
  append true
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

# Add to the hdfs superuser group
group node['hops']['hdfs']['user'] do
  action :modify
  members ["#{node['hopsworks']['user']}"]
  append true
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

group node['kagent']['userscerts_group'] do
  action :create
  not_if "getent group #{node['kagent']['userscerts_group']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

group node['kagent']['userscerts_group'] do
  action :modify
  members node['hopsworks']['user']
  append true
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

group node['hops']['group'] do
  gid node['hops']['group_id']
  action :create
  not_if "getent group #{node['hops']['group']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

group node['hops']['group'] do
  action :modify
  members ["#{node['hopsworks']['user']}"]
  append true
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

group node['hopsmonitor']['group'] do
  action :modify
  members ["#{node['hopsworks']['user']}"]
  append true
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

#update permissions of base_dir to 770
directory node['jupyter']['base_dir']  do
  owner node['hops']['yarnapp']['user']
  group node['hops']['group']
  mode "770"
  action :create
end

directory node['hopsworks']['dir']  do
  owner node['hopsworks']['user']
  group node['hopsworks']['group']
  mode "755"
  action :create
  not_if "test -d #{node['hopsworks']['dir']}"
end

directory domains_dir  do
  owner node['hopsworks']['user']
  group node['hopsworks']['group']
  mode "750"
  action :create
  not_if "test -d #{domains_dir}"
end


# For unzipping files
dtrx=""
case node['platform_family']
when "debian"

  if node['platform_version'].to_f <= 14.04
    node.override['hopsworks']['systemd'] = "false"
  end
  package ["dtrx", "libkrb5-dev"]

  dtrx="dtrx"
when "rhel"
  package ["krb5-libs", "p7zip"]

  remote_file "#{Chef::Config['file_cache_path']}/dtrx.tar.gz" do
    user node['glassfish']['user']
    group node['glassfish']['group']
    source node['dtrx']['download_url']
    mode 0755
    action :create
  end

  bash "unpack_dtrx" do
    user "root"
    code <<-EOF
      set -e
      cd #{Chef::Config['file_cache_path']}
      tar -xzf dtrx.tar.gz
      cd dtrx-7.1
      python setup.py install --prefix=/usr/local
      # dtrx expects 7z to on its path. create a symbolic link from /bin/7z to /bin/7za
      rm -f /bin/7z
      ln -s /bin/7za /bin/7z
    EOF
    not_if "which dtrx"
  end
  dtrx="/usr/local/bin/dtrx"
end

# Install authbind to allow glassfish to bind on ports < 1024
case node['platform_family']
when "debian"
  package "authbind"
when "rhel"
  authbind_rpm = ::File.basename(node['authbind']['download_url'])

  remote_file "#{Chef::Config['file_cache_path']}/#{authbind_rpm}" do
    user node['glassfish']['user']
    group node['glassfish']['group']
    source node['authbind']['download_url']
    mode 0755
    action :create
  end

  package 'authbind' do
    source "#{Chef::Config['file_cache_path']}/#{authbind_rpm}"
  end
end

# Configure authbind ports
authbind_port "Authbind Glassfish Admin port" do
  port node['hopsworks']['admin']['port'].to_i
  user node['glassfish']['user']
  only_if {node['hopsworks']['admin']['port'].to_i < 1024}
end

authbind_port "Authbind Glassfish https port" do
  port node['hopsworks']['https']['port'].to_i
  user node['glassfish']['user']
  only_if {node['hopsworks']['https']['port'].to_i < 1024}
end

file "#{node['hopsworks']['env_var_file']}" do
  content '# Generated by Chef. Environment variable exported for glassfish-domain1'
  mode 0700
  owner node['glassfish']['user']
  group node['glassfish']['group']
end


node.override = {
  'java' => {
    'install_flavor' => node['java']['install_flavor'],
    'jdk_version' => node['java']['jdk_version']
  },
  'glassfish' => {
    'version' => node['glassfish']['version'],
    'domains_dir' => node['hopsworks']['domains_dir'],
    'domains' => {
      domain_name => {
        'config' => {
          'systemd_enabled' => systemd,
          'systemd_start_timeout' => 900,
          'min_memory' => node['glassfish']['min_mem'],
          'max_memory' => node['glassfish']['max_mem'],
          'max_perm_size' => node['glassfish']['max_perm_size'],
          'max_stack_size' => node['glassfish']['max_stack_size'],
          'port' => 8080, #This is hardcoded as it's not used. Http listener is disabled in hopsworks::default.
          'https_port' => node['hopsworks']['https']['port'].to_i,
          'admin_port' => node['hopsworks']['admin']['port'].to_i,
          'username' => node['hopsworks']['admin']['user'],
          'password' => node['hopsworks']['admin']['password'],
          'master_password' => node['hopsworks']['master']['password'],
          'remote_access' => false,
          'secure' => false,
          'environment_file' => node['hopsworks']['env_var_file'],
          'jvm_options' => ["-DHADOOP_HOME=#{node['hops']['dir']}/hadoop", "-DHADOOP_CONF_DIR=#{node['hops']['dir']}/hadoop/etc/hadoop", '-Dcom.sun.enterprise.tools.admingui.NO_NETWORK=true', '-Dlog4j.configuration=file:///${com.sun.aas.instanceRoot}/config/log4j.properties']
        },
        'extra_libraries' => {
          'jdbcdriver' => {
            'type' => 'common',
            'url' => node['hopsworks']['mysql_connector_url']
          }
        },
        'threadpools' => {
          'thread-pool-1' => {
            'maxthreadpoolsize' => 200,
            'minthreadpoolsize' => 5,
            'idletimeout' => 900,
            'maxqueuesize' => 4096
          },
          'http-thread-pool' => {
            'maxthreadpoolsize' => 200,
            'minthreadpoolsize' => 5,
            'idletimeout' => 900,
            'maxqueuesize' => 4096
          },
          'admin-pool' => {
            'maxthreadpoolsize' => 40,
            'minthreadpoolsize' => 5,
            'maxqueuesize' => 256
          }
        },
        'managed_thread_factories' => {
          'concurrent/hopsThreadFactory' => {
            'threadpriority' => 10,
            'description' => 'Hopsworks Thread Factory'
          }
        },
        'managed_executor_services' => {
          'concurrent/hopsExecutorService' => {
            'threadpriority' => 10,
            'corepoolsize' => 50,
            'maximumpoolsize' => 400,
            'taskqueuecapacity' => 20000,
            'description' => 'Hopsworks Executor Service'
          },
          'concurrent/condaExecutorService' => {
              'threadpriority' => 9,
              'corepoolsize' => 30,
              'maximumpoolsize' => 400,
              'taskqueuecapacity' => 20000,
              'description' => 'Hopsworks Conda Executor Service'
          }
        },
        'managed_scheduled_executor_services' => {
          'concurrent/hopsScheduledExecutorService' => {
            'corepoolsize' => 10,
            'description' => 'Hopsworks Executor Service'
          },
          'concurrent/condaScheduledExecutorService' => {
              'corepoolsize' => 10,
              'description' => 'Hopsworks Conda Executor Service'
          }
        },
        'jdbc_connection_pools' => {
          'hopsworksPool' => {
            'config' => {
              'datasourceclassname' => 'com.mysql.cj.jdbc.MysqlDataSource',
              'restype' => 'javax.sql.DataSource',
              'isconnectvalidatereq' => 'true',
              'validationmethod' => 'auto-commit',
              'ping' => 'true',
              'description' => 'Hopsworks Connection Pool',
              'properties' => {
                'Url' => "jdbc:mysql://127.0.0.1:3306/",
                'User' => node['hopsworks']['mysql']['user'],
                'Password' => node['hopsworks']['mysql']['password'],
                'useSSL' => 'false',
                'allowPublicKeyRetrieval' => 'true'
              }
            },
            'resources' => {
              'jdbc/hopsworks' => {
                'description' => 'Resource for Hopsworks Pool',
              }
            }
          },
          'featureStorePool' => {
            'config' => {
              'datasourceclassname' => 'com.mysql.cj.jdbc.MysqlDataSource',
              'restype' => 'javax.sql.DataSource',
              'isconnectvalidatereq' => 'true',
              'validationmethod' => 'auto-commit',
              'ping' => 'true',
              'description' => 'FeatureStore Connection Pool',
              'properties' => {
                'Url' => node['featurestore']['hopsworks_url'],
                'User' => node['featurestore']['user'],
                'Password' => node['featurestore']['password'],
                'useSSL' => 'false',
                'allowPublicKeyRetrieval' => 'true'
              }
            },
            'resources' => {
              'jdbc/featurestore' => {
                'description' => 'Resource for Hopsworks Pool',
              }
            }
          },
          'airflowPool' => {
            'config' => {
              'datasourceclassname' => 'com.mysql.cj.jdbc.MysqlDataSource',
              'restype' => 'javax.sql.DataSource',
              'isconnectvalidatereq' => 'true',
              'validationmethod' => 'auto-commit',
              'ping' => 'true',
              'description' => 'Airflow Connection Pool',
              'properties' => {
                'Url' => "jdbc:mysql://127.0.0.1:3306/",
                'User' => node['airflow']['mysql_user'],
                'Password' => node['airflow']['mysql_password'],
                'useSSL' => 'false',
                'allowPublicKeyRetrieval' => 'true'
              }
            },
            'resources' => {
              'jdbc/airflow' => {
                'description' => 'Resource for Airflow Pool',
              }
            }
          },
          'ejbTimerPool' => {
            'config' => {
              'datasourceclassname' => 'com.mysql.cj.jdbc.MysqlDataSource',
              'restype' => 'javax.sql.DataSource',
              'isconnectvalidatereq' => 'true',
              'validationmethod' => 'auto-commit',
              'ping' => 'true',
              'description' => 'Hopsworks EJB Connection Pool',
              'properties' => {
                'Url' => "jdbc:mysql://127.0.0.1:3306/glassfish_timers",
                'User' => node['hopsworks']['mysql']['user'],
                'Password' => node['hopsworks']['mysql']['password'],
                'useSSL' => 'false',
                'allowPublicKeyRetrieval' => 'true'
              }
            },
            'resources' => {
              'jdbc/hopsworksTimers' => {
                'description' => 'Resource for Hopsworks EJB Timers Pool',
              }
            }
          }
        }
      }
    }
  }
}

unless exists_local("hops_airflow", "default")
  node.override["glassfish"]["domains"][domain_name]["jdbc_connection_pools"].delete("airflowPool")
end

include_recipe 'glassfish::default'

directory node['data']['dir'] do
  owner 'root'
  group 'root'
  mode '0775'
  action :create
  not_if { ::File.directory?(node['data']['dir']) }
end

directory node['hopsworks']['data_volume']['root_dir'] do
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode '0750'
  not_if { ::File.directory?(node['hopsworks']['data_volume']['root_dir'])}
end

directory node['hopsworks']['data_volume']['domain1'] do
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode '0750'
end

directory node['hopsworks']['data_volume']['domain1_logs'] do
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode '0750'
end

package 'openssl'

if !::File.directory?("#{theDomain}/lib")
  include_recipe 'glassfish::attribute_driven_domain'
else
  # For older installations (Hopsworks <= 1.0.0) the paths referring to glassfish contain the glassfish version 
  # this is problematic during upgrades. We replace them here with sed. 
  ["glassfish-4.1.2.174", "glassfish-4.1.2.181"].each do |version|
    bash "remove_glassfish_versions" do 
      user "root"
      group "root"
      code <<-EOL
        sed -i 's/#{version}/current/g' /lib/systemd/system/glassfish-#{domain_name}.service
        sed -i 's/#{version}/current/g' #{theDomain}/config/domain.xml
        sed -i 's/#{version}/current/g' #{theDomain}/bin/domain1_asadmin
      EOL
    end
  end
end 

# Domain and logs directory is created by glassfish cookbook.
# Small hack to symlink logs directory
directory node['hopsworks']['domain1']['logs'] do
  recursive true
  action :delete
  not_if { conda_helpers.is_upgrade }
end

bash 'Move glassfish logs to data volume' do
  user 'root'
  code <<-EOH
    set -e
    mv -f #{node['hopsworks']['domain1']['logs']}/* #{node['hopsworks']['data_volume']['domain1_logs']}
    mv -f #{node['hopsworks']['domain1']['logs']} #{node['hopsworks']['data_volume']['domain1_logs']}_deprecated
  EOH
  only_if { conda_helpers.is_upgrade }
  only_if { File.directory?(node['hopsworks']['domain1']['logs'])}
  not_if { File.symlink?(node['hopsworks']['domain1']['logs'])}
end

link node['hopsworks']['domain1']['logs'] do
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode '0750'
  to node['hopsworks']['data_volume']['domain1_logs']
end

directory node['hopsworks']['audit_log_dir'] do
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode '0700'
  action :create
end


mysql_connector = File.basename(node['hopsworks']['mysql_connector_url'])

remote_file "#{theDomain}/lib/#{mysql_connector}"  do
  user node['glassfish']['user']
  group node['glassfish']['group']
  source node['hopsworks']['mysql_connector_url']
  mode 0755
  action :create_if_missing
end

cauth = File.basename(node['hopsworks']['cauth_url'])

remote_file "#{theDomain}/lib/#{cauth}"  do
  user node['glassfish']['user']
  group node['glassfish']['group']
  source node['hopsworks']['cauth_url']
  mode 0755
  action :create_if_missing
end

remote_directory "#{theDomain}/templates" do
  source 'hopsworks_templates'
  owner node["glassfish"]["user"]
  group node["glassfish"]["group"]
  mode 0750
  files_owner node["glassfish"]["user"]
  files_group node["glassfish"]["group"]
  files_mode 0550
end

if systemd == true
  directory "/etc/systemd/system/glassfish-#{domain_name}.service.d" do
    owner "root"
    group "root"
    mode "755"
    action :create
  end


   template "/etc/systemd/system/glassfish-#{domain_name}.service.d/limits.conf" do
     source "limits.conf.erb"
     owner "root"
     mode 0774
     action :create
   end

ulimit_domain node['hopsworks']['user'] do
  rule do
    item :memlock
    type :soft
    value "unlimited"
  end
  rule do
    item :memlock
    type :hard
    value "unlimited"
  end
end

  kagent_config "glassfish-domain1" do 
    action :systemd_reload
  end
end

directory node['certs']['data_volume']['dir'] do
  owner node['glassfish']['user']
  group node['kagent']['certs_group']
  mode "755"
  action :create
end

ca_dir = node['certs']['dir']

link ca_dir do
  owner node['glassfish']['user']
  group node['kagent']['certs_group']
  to node['certs']['data_volume']['dir']
end

master_password_digest = Digest::SHA256.hexdigest node['hopsworks']['encryption_password']

file "#{ca_dir}/encryption_master_password" do
  content "#{master_password_digest}"
  mode "0700"
  owner node['glassfish']['user']
  group node['glassfish']['group']
end

directory "#{ca_dir}/transient" do
  owner node['glassfish']['user']
  group node['kagent']['userscerts_group']
  mode "750"
  action :create
end

dirs = %w{certs crl newcerts private intermediate}

for d in dirs
  directory "#{ca_dir}/#{d}" do
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode "700"
    action :create
  end
end

int_dirs = %w{certs crl csr newcerts private}

for d in int_dirs
  directory "#{ca_dir}/intermediate/#{d}" do
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode "700"
    action :create
  end
end

template "#{ca_dir}/openssl-ca.cnf" do
  source "caopenssl.cnf.erb"
  owner node['glassfish']['user']
  mode "600"
  variables({
              :ca_dir =>  "#{ca_dir}"
            })
  action :create
end

template "#{ca_dir}/intermediate/openssl-intermediate.cnf" do
  source "intermediateopenssl.cnf.erb"
  owner node['glassfish']['user']
  mode "600"
  variables({
              :int_ca_dir =>  "#{ca_dir}/intermediate"
            })
  action :create
end

kagent_sudoers "ndb_backup" do 
  user          node['glassfish']['user']
  group         node['ndb']['group']
  script_name   "ndb_backup.sh"
  template      "ndb_backup.sh.erb"
  run_as        node['ndb']['user']
end

kagent_sudoers "jupyter" do 
  user          node['glassfish']['user']
  group         "root"
  script_name   "jupyter.sh"
  template      "jupyter.sh.erb"
  run_as        "ALL" # run this as root - inside we change to different users 
  not_if       { node['install']['kubernetes'].casecmp("true") == 0 }
end

kagent_sudoers "convert-ipython-notebook" do 
  user          node['glassfish']['user']
  group         "root"
  script_name   "convert-ipython-notebook.sh"
  template      "convert-ipython-notebook.sh.erb"
  run_as        "ALL" # run this as root - inside we change to different users 
end

kagent_sudoers "tensorboard" do 
  user          node['glassfish']['user']
  group         "root"
  script_name   "tensorboard.sh"
  template      "tensorboard.sh.erb"
  run_as        "ALL" # run this as root - inside we change to different users 
end

kagent_sudoers "tfserving" do 
  user          node['glassfish']['user']
  group         "root"
  script_name   "tfserving.sh"
  template      "tfserving.sh.erb"
  run_as        "ALL" # run this as root - inside we change to different users 
  not_if       { node['install']['kubernetes'].casecmp("true") == 0 }
end

kagent_sudoers "sklearn_serving" do 
  user          node['glassfish']['user']
  group         "root"
  script_name   "sklearn_serving.sh"
  template      "sklearn_serving.sh.erb"
  run_as        "ALL" # run this as root - inside we change to different users 
  not_if       { node['install']['kubernetes'].casecmp("true") == 0 }
end

kagent_sudoers "jupyter-project-cleanup" do 
  user          node['glassfish']['user']
  group         "root"
  script_name   "jupyter-project-cleanup.sh"
  template      "jupyter-project-cleanup.sh.erb"
  run_as        "ALL"
  not_if       { node['install']['kubernetes'].casecmp("true") == 0 }
end

kagent_sudoers "global-ca-sign-csr" do 
  user          node['glassfish']['user']
  group         "root"
  script_name   "global-ca-sign-csr.sh"
  template      "global-ca-sign-csr.sh.erb"
  run_as        "ALL"
end

kagent_sudoers "ca-keystore" do 
  user          node['glassfish']['user']
  group         "root"
  script_name   "ca-keystore.sh"
  template      "ca-keystore.sh.erb"
  run_as        "ALL"
  only_if       { node['hopsworks']['dela']['enabled'].casecmp("true") == 0 }
end

command=""
case node['platform']
 when 'debian', 'ubuntu'
   command='tensorflow_model_server'
 when 'redhat', 'centos', 'fedora'
   command='/opt/serving/bazel-bin/tensorflow_serving/model_servers/tensorflow_model_server'
end

template "#{theDomain}/bin/tfserving-launch.sh" do
  source "tfserving-launch.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode "550"
  variables({
     :command => command
  })
  action :create
end

template "#{theDomain}/bin/unzip-hdfs-files.sh" do
  source "unzip-hdfs-files.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode "550"
  variables(lazy {
    h = {}
    h['dtrx'] = dtrx
    h
  })
  action :create
end

["zip-hdfs-files.sh", "zip-background.sh", "unzip-background.sh",  "tensorboard-launch.sh",
 "tensorboard-cleanup.sh", "condasearch.sh", "list_environment.sh", "jupyter-kill.sh",
 "jupyter-launch.sh", "tfserving-kill.sh", "sklearn_serving-launch.sh", "sklearn_serving-kill.sh"].each do |script|
  template "#{theDomain}/bin/#{script}" do
    source "#{script}.erb"
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode "500"
    action :create
  end
end


["sklearn_flask_server.py"].each do |script|
  template "#{theDomain}/bin/#{script}" do
    source "#{script}.erb"
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode "750"
    action :create
  end
end

template "#{theDomain}/bin/dump_web_logs_to_hdfs.sh" do
  source "dump_web_logs_to_hdfs.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode 0700
  action :create
  variables({
              :weblogs_dir => "#{theDomain}/logs/access",
              :hadoop_home => node['hops']['base_dir'],
              :remote_weblogs_dir => "#{node['hops']['hdfs']['user_home']}/#{node['glassfish']['user']}/webserver_logs"
            })
end

template "#{theDomain}/bin/dump_audit_logs_to_hdfs.sh" do
  source "dump_audit_logs_to_hdfs.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode 0700
  action :create
  variables({
              :weblogs_dir => "#{theDomain}/logs/audit",
              :hadoop_home => node['hops']['base_dir'],
              :remote_weblogs_dir => "#{node['hops']['hdfs']['user_home']}/#{node['glassfish']['user']}/webserver_audit_logs"
            })
end


# Hopsworks user should own the directory so that hopsworks code
# can create the template files needed for Jupyter.
# Hopsworks will use a sudoer script to launch jupyter as the 'jupyter' user.
# The jupyter user will be able to read the files and write to the directories due to group permissions

user node['hops']['yarnapp']['user'] do
  uid node['hops']['yarnapp']['uid']
  gid node['hops']['group']
  system true
  manage_home true
  shell "/bin/bash"
  action :create
  not_if "getent passwd #{node['hops']['yarnapp']['user']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

#update permissions of base_dir to 770
directory node["jupyter"]["base_dir"]  do
  owner node["jupyter"]["user"]
  group node["jupyter"]["group"]
  mode "770"
  action :create
end

directory node["hopssite"]["certs_dir"] do
  owner node["glassfish"]["user"]
  group node['kagent']['certs_group']
  mode "750"
  action :create
end

directory node["hopssite"]["keystore_dir"] do
  owner node["glassfish"]["user"]
  mode "750"
  action :create
end

template "#{theDomain}/config/ca.ini" do
  source "ca.ini.erb"
  owner node['glassfish']['user']
  mode 0750
  action :create
end

template "#{theDomain}/bin/csr-ca.py" do
  source "csr-ca.py.erb"
  owner node['glassfish']['user']
  mode 0750
  action :create
end

flyway_tgz = File.basename(node['hopsworks']['flyway_url'])
flyway =  "flyway-" + node['hopsworks']['flyway']['version']

remote_file "#{Chef::Config['file_cache_path']}/#{flyway_tgz}" do
  user node['glassfish']['user']
  group node['glassfish']['group']
  source node['hopsworks']['flyway_url']
  mode 0755
  action :create
end

bash "unpack_flyway" do
  user "root"
  code <<-EOF
    set -e
    cd #{Chef::Config['file_cache_path']}
    tar -xzf #{flyway_tgz}
    mv #{flyway} #{theDomain}
    cd #{theDomain}
    chown -R #{node['glassfish']['user']} flyway*
    if [ -L flyway ]; then
      cp -r flyway/sql #{flyway}/ 
      rm -rf flyway
    fi
    ln -s #{flyway} flyway
  EOF
end

template "#{theDomain}/flyway/conf/flyway.conf" do
  source "flyway.conf.erb"
  owner node['glassfish']['user']
  mode 0750
  action :create
end

template "#{theDomain}/flyway/flyway-undo.sh" do
  source "flyway-undo.sh.erb"
  owner node['glassfish']['user']
  mode 0750
  action :create
end

directory "#{theDomain}/flyway/undo" do
  owner node['glassfish']['user']
  mode "770"
  action :create
end

directory "#{theDomain}/flyway/dml" do
  owner node['glassfish']['user']
  mode "770"
  action :create
end

directory "#{theDomain}/flyway/dml/undo" do
  owner node['glassfish']['user']
  mode "770"
  action :create
end

directory "#{theDomain}/flyway/all" do
  owner node['glassfish']['user']
  mode "770"
  action :create
end

directory "#{theDomain}/flyway/all/sql" do
  owner node['glassfish']['user']
  mode "770"
  action :create
end

directory "#{theDomain}/flyway/all/undo" do
  owner node['glassfish']['user']
  mode "770"
  action :create
end
