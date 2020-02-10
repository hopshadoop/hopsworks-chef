name             "hopsworks"
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "Apache v2.0"
description      "Installs/Configures HopsWorks, the UI for Hops Hadoop."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.3.0"
source_url       "https://github.com/logicalclocks/hopsworks-chef"


%w{ ubuntu debian centos rhel }.each do |os|
  supports os
end

depends 'glassfish'
depends 'ndb'
depends 'kagent'
depends 'hops'
depends 'elastic'
depends 'hadoop_spark'
depends 'flink'
depends 'compat_resource'
depends 'ulimit2'
depends 'authbind'
depends 'epipe'
depends 'livy'
depends 'kkafka'
depends 'kzookeeper'
depends 'drelephant'
depends 'dela'
depends 'java'
depends 'tensorflow'
depends 'hopslog'
depends 'hopsmonitor'
depends 'hive2'
depends 'hops_airflow'

recipe  "hopsworks::install", "Installs Glassfish"

recipe  "hopsworks", "Installs HopsWorks war file, starts glassfish+application."
recipe  "hopsworks::dev", "Installs development libraries needed for HopsWorks development."
recipe  "hopsworks::letsencypt", "Given a glassfish installation and a letscrypt installation, update glassfish's key."
recipe  "hopsworks::image", "Prepare for use as a virtualbox image."
recipe  "hopsworks::rollback", "Rollback an upgrade to Hopsworks."

recipe  "hopsworks::migrate", "Call expat to migrate between Hopsworks versions"

recipe  "hopsworks::purge", "Deletes glassfish installation."
recipe  "hopsworks::hopssite", "Install hopssite on current vm"
recipe  "hopsworks::delaregister", "Register dela on current vm - mainly for demos"
#######################################################################################
# Required Attributes
#######################################################################################

attribute "hopsworks/default/private_ips",
          :description => "ip addrs",
          :type => 'array'

attribute "hopsworks/admin/email",
          :description => "Email address of the default admin user",
          :type => 'string'

attribute "hopsworks/email",
          :description => "Email account to send notifications from. ",
          :required => "required",
          :type => 'string'

attribute "hopsworks/email_password",
          :description => "Password for email account. ",
          :required => "required",
          :type => 'string'

attribute "hopsworks/twofactor_auth",
          :description => "Ip Address/hostname of SMTP server (default is smtp.gmail.com)",
          :type => 'string'

attribute "hopsworks/cert_mater_delay",
          :description => "Delay for the Certificate Materialization service of Hopsworks to delete the certificates from the local fs",
          :type => 'string'

attribute "hopsworks/service_key_rotation_enabled",
          :description => "Configuration option to enable/disable automatic service key rotation",
          :type => 'string'

attribute "hopsworks/service_key_rotation_interval",
          :description => "Interval for Hops service certificates rotation",
          :type => 'string'

attribute "hopsworks/application_certificate_validity_period",
          :description => "Application certificate validity period. Certificates will be rotated well before the expiration",
          :type => 'string'

attribute "hopsworks/smtp",
          :description => "Ip Address/hostname of SMTP server (default is smtp.gmail.com)",
          :type => 'string'

attribute "hopsworks/smtp_port",
          :description => "Port of SMTP server (default is 587)",
          :type => 'string'

attribute "hopsworks/smtp_ssl_port",
          :description => "SSL port of SMTP server (default is 465)",
          :type => 'string'

attribute "hopsworks/alert_email_addrs",
          :description => "Comma-separated list of email addresses that will receive emails for alerts in Hopsworks",
          :type => 'string'

attribute "hopsworks/admin/user",
          :description => "Username for the Administration account on the Web Application Server",
          :type => 'string',
          :required => "required"

attribute "hopsworks/admin/password",
          :description => "Password for the Administration account on the Web Application Server",
          :type => 'string',
          :required => "required"

attribute "hopsworks/dir",
          :description => "Installation directory for the glassfish binaries",
          :type => 'string'

attribute "hopsworks/user",
          :description => "Hopsworks/glassfish username to run service as",
          :type => 'string'

attribute "hopsworks/group",
          :description => "Hopsworks/glassfish group to run service as",
          :type => 'string'

attribute "hopsworks/domains_dir",
          :description => "Installation directory for the glassfish domains",
          :type => 'string'

attribute "hopsworks/domain_truststore",
          :description => "Name of the glassfish truststore for this domain.",
          :type => 'string'

attribute "hopsworks/domain_truststore_path",
          :description => "Path where domain_truststore is stored",
          :type => 'string'

attribute "hopsworks/master/password",
          :description => "Web Application Server master password",
          :type => 'string'

attribute "download_url",
          :description => "URL for downloading binaries",
          :type => 'string'


attribute "hopsworks/cert/user_cert_valid_days",
           :description => "How long in days will the user certs be valid. Default 12 days.",
           :type => 'string'


attribute "hopsworks/cert/password",
           :description => "password to glassfish certs",
           :type => 'string'

attribute "hopsworks/cert/cn",
          :description => "Certificate Name",
          :type => 'string'

attribute "hopsworks/cert/o",
          :description => "organization name",
          :type => 'string'

attribute "hopsworks/cert/ou",
          :description => "Organization unit",
          :type => 'string'

attribute "hopsworks/cert/l",
          :description => "Location",
          :type => 'string'

attribute "hopsworks/cert/s",
          :description => "City",
          :type => 'string'

attribute "hopsworks/cert/c",
          :description => "Country (2 letters)",
          :type => 'string'

attribute "glassfish/version",
          :description => "glassfish/version",
          :type => 'string'

attribute "glassfish/user",
          :description => "Install and run the glassfish server as this username",
          :type => 'string'

attribute "glassfish/group",
          :description => "glassfish/group",
          :type => 'string'

attribute "hopsworks/https/port",
          :description => "Port that webserver will listen on",
          :type => 'string'

attribute "hopsworks/max_mem",
          :description => "glassfish/max_mem",
          :type => 'string'

attribute "hopsworks/min_mem",
          :description => "glassfish/min_mem",
          :type => 'string'

attribute "hopsworks/max_stack_size",
          :description => "glassfish/max_stack_size",
          :type => 'string'

attribute "hopsworks/http_logs/enabled",
          :description => "Enable logging of HTTP requests and dump to HDFS",
          :type => 'string'

attribute "hopsworks/max_perm_size",
          :description => "glassfish/max_perm_size",
          :type => 'string'

attribute "hopsworks/reinstall",
          :description => "Enter 'true' if this is a reinstallation",
          :type => 'string'

attribute "hopsworks/war_url",
          :description => "Url for the hopsworks war file",
          :type => 'string'

attribute "hopsworks/ear_url",
          :description => "Url for the hopsworks ear file",
          :type => 'string'

attribute "hopsworks/logsize",
          :description => "Size of Glassfish log file for Hopsworks",
          :type => 'string'

attribute "hopsworks/ca_url",
          :description => "Url for the hopsworks certificate authority war file",
          :type => 'string'

attribute "hopsworks/yarn_default_quota_mins",
          :description => "Default number of CPU mins availble per project",
          :type => 'string'

attribute "hopsworks/hdfs_default_quota_mbs",
          :description => "Default amount in MB of available storage per project",
          :type => 'string'

attribute "hopsworks/hive_default_quota_mbs",
          :description => "Default amount in MB of available storage per project",
          :type => 'string'

attribute "hopsworks/featurestore_default_quota_mbs",
          :description => "Default amount in MB of available storage for the featurestore service per project",
          :type => 'string'

attribute "hopsworks/featurestore_online",
          :description => "Enable the creation of NDB databases for the online featurestore. Default 'false'",
          :type => 'string'

attribute "hopsworks/max_num_proj_per_user",
          :description => "Maximum number of projects that can be created by each user",
          :type => 'string'

attribute "hopsworks/reserved_project_names",
          :description => "Comma-separated list of Project names a user user is not allowed to use",
          :type => 'string'

attribute "hopsworks/encryption_password",
          :description => "Default master encryption password for storing secrets.",
          :type => 'string'

attribute "hopsworks/file_preview_image_size",
          :description => "Maximum size in bytes of an image that can be previewed in DataSets",
          :type => 'string'

attribute "hopsworks/file_preview_txt_size",
          :description => "Maximum size in lines of file that can be previewed in DataSets",
          :type => 'string'

attribute "hopsworks/download_allowed",
          :description => "Whether users should be allowed to download files from datasets. Default value is true.",
          :type => 'string'

attribute "hopsworks/anaconda_enabled",
          :description => "Default is 'true'. Set to 'false' to disable anaconda.",
          :type => 'string'

attribute "hopsworks/nonconda_hosts",
          :description => "Comma separated list of IPs on which you should not enable conda.",
          :type => 'string'

attribute "hopsworks/staging_dir",
          :description => "Default is a 'domains/domain1/scratch'. Override to use a path on a disk volume with plenty of available space.",
          :type => 'string'

attribute "hopsworks/version",
          :description => "The version of ear/web/ca to download",
          :type => 'string'

attribute "vagrant",
          :description => "'true' to rewrite /etc/hosts, 'false' to disable vagrant /etc/hosts",
          :type => 'string'

attribute "services/enabled",
          :description => "Default 'false'. Set to 'true' to enable daemon services, so that they are started on a host restart.",
          :type => "string"

attribute "install/dir",
          :description => "Default ''. Set to a base directory under which all hops services will be installed.",
          :type => "string"

attribute "install/user",
          :description => "User to install the services as",
          :type => "string"

attribute "install/ssl",
          :description => "Is SSL turned on for all services?",
          :type => "string"

attribute "install/addhost",
          :description => "Indicates that this host will be added to an existing Hops cluster.",
          :type => "string"

attribute "hopsworks/monitor_max_status_poll_try",
          :description => "Default number of time the job monitor fail at polling the job status before to consider the job as failed",
          :type => 'string'

attribute "hopsworks/db",
          :description => "Default hopsworks database",
          :type => 'string'

attribute "mysql/user/kafka",
          :description => "DB user for the Kafka service",
          :type => 'string'

attribute "mysql/password/kafka",
          :description => "Password of the DB user for the Kafka service",
          :type => 'string'

##
##
## Spark
##
##

attribute "hadoop_spark/historyserver/private_ips",
          :description => "historyserver ip addr",
          :type => 'array'

attribute "hadoop_spark/user",
          :description => "Username to run spark master/worker as",
          :type => 'string'

attribute "hadoop_spark/group",
          :description => "Groupname to run spark master/worker as",
          :type => 'string'

attribute "hadoop_spark/dir",
          :description => "Directory for installation",
          :type => 'string'

attribute "hadoop_spark/executor_memory",
          :description => "Executor memory (e.g., 512m)",
          :type => 'string'

attribute "hadoop_spark/driver_memory",
          :description => "Driver memory (e.g., 1g)",
          :type => 'string'

attribute "hadoop_spark/eventlog_enabled",
          :description => "Eventlog enabled (true|false)",
          :type => 'string'

attribute "hadoop_spark/streaming/stopGracefullyOnShutdown",
          :description => "Shut down the StreamingContext gracefully on JVM shutdown rather than immediately (true|false)",
          :type => 'string'

attribute "hadoop_spark/worker/cleanup/enabled",
          :description => "Spark standalone worker cleanup enabled (true|false)",
          :type => 'string'

attribute "hadoop_spark/version",
          :description => "Spark version (e.g., 1.6.1 or 2.0.1 or 2.1.0)",
          :type => 'string'

attribute "hadoop_spark/hadoop/distribution",
          :description => "'hops' or 'hops'",
          :type => 'string'

attribute "hadoop_spark/history/fs/cleaner/enabled",
          :description => "'true' to enable cleanup of the historyservers logs",
          :type => 'string'

attribute "hadoop_spark/history/fs/cleaner/interval",
          :description => "How often to run the cleanup of the historyservers logs (e.g., '1d' for once per day)",
          :type => 'string'

attribute "hadoop_spark/history/fs/cleaner/maxAge",
          :description => "Age in days of the historyservers logs before they are removed (e.g., '7d' for 7 days)",
          :type => 'string'

attribute "hadoop_spark/yarn/am/attemptFailuresValidityInterval",
          :description => "Defines the validity interval for AM failure tracking. If the AM has been running for at least the defined interval, the AM failure count will be reset.",
          :type => 'string'

attribute "hadoop_spark/driver/maxResultSize",
          :description => "Default '5g'. Change to '1g', '500m', etc",
          :type => 'string'

attribute "hadoop_spark/local/dir",
          :description => "Default /tmp'. Change to: '/srv/disk1/tmp,/srv/disk2/tmp,/srv/disk3/tmp'",
          :type => 'string'

##
##
## Flink
##
##

attribute "flink/user",
          :description => "Username to run flink jobmgr/task as",
          :type => 'string'

attribute "flink/group",
          :description => "Groupname to run flink jobmgr/task as",
          :type => 'string'

attribute "flink/mode",
          :description => "Run Flink JobManager in one of the following modes: BATCH, STREAMING",
          :type => 'string'

attribute "flink/jobmanager/heap_mbs",
          :description => "Flink JobManager Heap Size in MB",
          :type => 'string'

attribute "flink/taskmanager/heap_mbs",
          :description => "Flink TaskManager Heap Size in MB",
          :type => 'string'

attribute "flink/dir",
          :description => "Root directory for flink installation",
          :type => 'string'

attribute "flink/taskmanager/num_taskslots",
          :description => "Override the default number of task slots (default = NoOfCPUs)",
          :type => 'string'

attribute "flink/hadoop/distribution",
          :description => "hops (default) or hops",
          :type => 'string'


##
##
## Livy
##
##

attribute "livy/default/private_ips",
          :description => "ip addrs",
          :type => 'array'

attribute "livy/user",
          :description => "User to install/run as",
          :type => 'string'

attribute "livy/group",
          :description => "Group to install/run as",
          :type => 'string'

attribute "livy/dir",
          :description => "base dir for installation",
          :type => 'string'

attribute "livy/version",
          :dscription => "livy.version",
          :type => "string"

attribute "livy/url",
          :dscription => "livy.url",
          :type => "string"

attribute "livy/port",
          :dscription => "livy.port",
          :type => "string"

attribute "livy/home",
          :dscription => "livy.home",
          :type => "string"

attribute "livy/keystore",
          :dscription => "ivy.keystore",
          :type => "string"

attribute "livy/keystore_password",
          :dscription => "ivy.keystore_password",
          :type => "string"

##
##
## Epipe
##
##

attribute "epipe/default/private_ips",
          :description => "historyserver ip addr",
          :type => 'array'

attribute "epipe/user",
          :description => "User to run Epipe server as",
          :type => "string"

attribute "epipe/group",
          :description => "Group to run Epipe server as",
          :type => "string"

attribute "epipe/version",
          :description => "Version of epipe to use",
          :type => "string"

attribute "epipe/url",
          :description => "Url to epipe binaries",
          :type => "string"

attribute "epipe/dir",
          :description => "Parent directory to install epipe in (/srv is default)",
          :type => "string"

attribute "epipe/pid_file",
          :description => "Change the location for the pid_file.",
          :type => "string"


##
##
## drelephant
##
##

attribute "drelephant/default/private_ips",
          :description => "ip addrs",
          :type => 'array'


attribute "drelephant/dir",
          :description => "Default base installation directory for the Dr Elephant server (default: /srv)",
          :type => 'string'

attribute "drelephant/user",
          :description => "Username that runs the Dr Elephant server",
          :type => 'string'

attribute "drelephant/group",
          :description => "Groupname that runs the Dr Elephant server",
          :type => 'string'


attribute "drelephant/port",
          :description => "Port for running the Dr Elephant server",
          :type => 'string'


##
##
## hopsmonitor
##
##

attribute "hopsmonitor/default/private_ips",
          :description => "ip addrs",
          :type => 'array'

attribute "hopsmonitor/user",
          :description => "User to run Influxdb/Grafana server as",
          :type => "string"

attribute "hopsmonitor/group",
          :description => "Group to run Influxdb/Grafana server as",
          :type => "string"

attribute "hopsmonitor/dir",
          :description => "Base install directory for Influxdb/Grafana ",
          :type => "string"


#
# InfluxDB
#

attribute "influxdb/db_user",
          :description => "username for influxdb account used by hopsworks ",
          :type => "string"

attribute "influxdb/db_password",
          :description => "Password for influxdb account used by hopsworks",
          :type => "string"

attribute "influxdb/admin_user",
          :description => "username for influxdb admin ",
          :type => "string"

attribute "influxdb/admin_password",
          :description => "Password for influxdb admin user",
          :type => "string"


attribute "influxdb/http/port",
          :description => "Http port for influxdb",
          :type => "string"

attribute "influxdb/port",
          :description => "Main port for influxdb",
          :type => "string"

attribute "influxdb/admin/port",
          :description => "Admin port for influxdb",
          :type => "string"

attribute "graphite/port",
          :description => "Port for influxdb graphite connector",
          :type => "string"



#
# Grafana
#


attribute "grafana/admin_user",
          :description => "username for grafana admin ",
          :type => "string"

attribute "grafana/admin_password",
          :description => "Password for grafana admin user",
          :type => "string"


attribute "grafana/mysql_user",
          :description => "username for grafana mysql user ",
          :type => "string"

attribute "grafana/mysql_password",
          :description => "Password for grafana mysql user",
          :type => "string"

attribute "grafana/port",
          :description => "Port for grafana",
          :type => "string"


##
##
## hopslog
##
##

attribute "hopslog/default/private_ips",
          :description => "ip addrs",
          :type => 'array'

attribute "hopslog/user",
          :description => "User to run Kibana server as",
          :type => "string"

attribute "hopslog/group",
          :description => "Group to run Kibana server as",
          :type => "string"

attribute "logstash/url",
          :description => "Url to hopslog binaries",
          :type => "string"

attribute "logstash/version",
          :description => "Version of logstash to use",
          :type => "string"

attribute "kibana/url",
          :description => "Url to hopslog binaries",
          :type => "string"

attribute "hopslog/dir",
          :description => "Parent directory to install logstash and kibana in (/srv is default)",
          :type => "string"

attribute "logstash/pid_file",
          :description => "Change the location for the pid_file.",
          :type => "string"

attribute "filebeat/url",
          :description => "Url to filebeat binaries",
          :type => "string"

attribute "filebeat/version",
          :description => "Filebeat version",
          :type => "string"

attribute "filebeat/read_logs",
          :description => "Path to log files read by filebeat (e.g., /srv/hops/domain1/logs/*.log)",
          :type => "string"



##
##
## tensorflow
##
##

attribute "tensorflow/user",
:description => "user parameter value",
:type => "string"

attribute "tensorflow/group",
:description => "group parameter value",
:type => "string"

attribute "tensorflow/dir",
:description => "Base installation directory",
:type => "string"

attribute "download_url",
:description => "url for binaries",
:type => "string"

attribute "tensorflow/git_url",
:description => "url for git sourcecode for tensorflow",
:type => "string"

attribute "cuda/accept_nvidia_download_terms",
:description => "Accept cuda licensing terms and conditions. Default: 'false'. Change to 'true' to enable cuda.",
:type => "string"

attribute "cuda/skip_test",
          :description => "Dont check if there is a local nvidia card on this machine",
          :type => "string"

attribute "cuda/skip_stop_xserver",
          :description => "Dont restart the xserver (probably a localhost installation)",
          :type => "string"

##
##
## hops
##
##

attribute "hops/dir",
          :description => "Base installation directory for HopsFS",
          :type => 'string'

attribute "hops/use_hopsworks",
          :description => "'true' or 'false' - true to enable HopsWorks support",
          :type => 'string'

attribute "hops/erasure_coding",
          :description => "'true' or 'false' - true to enable erasure-coding replication",
          :type => 'string'

attribute "hops/nn/cache",
          :description => "'true' or 'false' - true to enable the path cache in the NameNode",
          :type => 'string'

attribute "hops/nn/partition_key",
          :description => "'true' or 'false' - true to enable the partition key when starting transactions. Distribution-aware transactions.",
          :type => 'string'

attribute "hops/yarn/resource_tracker",
          :description => "Hadoop Resource Tracker enabled on this nodegroup",
          :type => 'string'

attribute "hops/install_db",
          :description => "Install hops database and tables in MySQL Cluster ('true' (default) or 'false')",
          :type => 'string'

attribute "hops/use_systemd",
          :description => "Use systemd startup scripts, default 'false'",
          :type => "string"

attribute "hops/format",
          :description => "'true' to format HDFS, 'false' to skip formatting",
          :type => 'string'

attribute "hops/reformat",
          :description => "'true' to re-format HDFS, 'false' to skip re-formatting",
          :type => 'string'

attribute "hops/yarn/nodemanager_log_dir",
          :description => "The directory in which yarn node manager store containers logs",
          :type => 'string'

attribute "hops/yarn/nodemanager_recovery_dir",
          :description => "The directory in which yarn node manager stores recovery state",
          :type => 'string'

attribute "hops/yarn/memory_mbs",
          :description => "Apache_Hadoop NodeManager Memory in MB",
          :type => 'string'

attribute "hops/yarn/nodemanager_ha_enabled",
          :description => "",
          :type => "string"

attribute "hops/yarn/nodemanager_auto_failover_enabled",
          :description => "",
          :type => "string"

attribute "hops/yarn/nodemanager_recovery_enabled",
          :description => "",
          :type => "string"

attribute "hops/yarn/rm_heartbeat",
          :description => "",
          :type => "string"

attribute "hops/yarn/nodemanager_rpc_batch_max_size",
          :description => "",
          :type => "string"

attribute "hops/yarn/nodemanager_rpc_batch_max_duration",
          :description => "",
          :type => "string"

attribute "hops/yarn/rm_distributed",
          :description => "Set to 'true' to enable distributed RMs",
          :type => "string"

attribute "hops/yarn/nodemanager_rm_streaming_enabled",
          :description => "",
          :type => "string"

attribute "hops/yarn/client_failover_sleep_base_ms",
          :description => "",
          :type => "string"

attribute "hops/yarn/client_failover_sleep_max_ms",
          :description => "",
          :type => "string"

attribute "hops/yarn/quota_enabled",
          :description => "",
          :type => "string"

attribute "hops/yarn/quota_monitor_interval",
          :description => "",
          :type => "string"

attribute "hops/yarn/quota_ticks_per_credit",
          :description => "",
          :type => "string"

attribute "hops/yarn/quota_min_ticks_charge",
          :description => "",
          :type => "string"

attribute "hops/yarn/quota_checkpoint_nbticks",
          :description => "",
          :type => "string"

attribute "hops/trash/interval",
          :description => "How long in minutes trash survives in /user/<glassfish>/.Trash/<interval-bucket>/...",
          :type => "string"

attribute "hops/trash/checkpoint/interval",
          :description => "How long in minutes until a new directory bucket is created in /user/<glassfish>/.Trash with a timestamp. ",
          :type => "string"

attribute "hops/nn/private_ips",
          :description => "Set ip addresses",
          :type => "array"

attribute "hops/rm/private_ips",
          :description => "Set ip addresses",
          :type => "array"

# Needed to find the jar file for yan-spark-shuffle
attribute "hadoop_spark/version",
          :description => "Spark version",
          :type => 'string'

attribute "hops/yarn/vcores",
          :description => "Hops NodeManager Number of Virtual Cores",
          :type => 'string'

attribute "hops/yarn/max_vcores",
          :description => "Hadoop NodeManager Maximum Virtual Cores per container",
          :type => 'string'

attribute "hops/version",
          :description => "Version of hops",
          :type => 'string'

attribute "hops/num_replicas",
          :description => "Number of replicates for each file stored in HDFS",
          :type => 'string'

attribute "hops/container_cleanup_delay_sec",
          :description => "The number of seconds container data is retained after termination",
          :type => 'string'

attribute "hops/group",
          :description => "Group to run hdfs/yarn/mr as",
          :type => 'string'

attribute "hops/yarn/user",
          :description => "Username to run yarn as",
          :type => 'string'

attribute "hops/mr/user",
          :description => "Username to run mapReduce as",
          :type => 'string'

attribute "hops/hdfs/user",
          :description => "Username to run hdfs as",
          :type => 'string'

attribute "hops/hdfs/superuser_group",
          :description => "Group for users with hdfs superuser privileges",
          :type => 'string'

attribute "hops/hdfs/blocksize",
          :description => "HDFS Blocksize (128k, 512m, 1g, etc). Default 128m.",
          :type => 'string'

attribute "hops/hdfs/umask",
          :description => "Set the default HDFS umask (default: 0022).",
          :type => 'string'

attribute "hops/format",
          :description => "Format HDFS, Run 'hdfs namenode -format",
          :type => 'string'

attribute "hops/tmp_dir",
          :description => "The directory in which Hadoop stores temporary data, including container data",
          :type => 'string'

attribute "hops/nn/name_dir",
          :description => "Directory for NameNode's state",
          :type => 'string'

attribute "hops/dn/data_dir",
          :description => "The directory in which Hadoop's DataNodes store their data",
          :type => 'string'

attribute "hops/dn/data_dir_permissions",
          :description => "The permissions for the directory in which Hadoop's DataNodes store their data (default: 700)",
          :type => 'string'

attribute "hops/yarn/nodemanager_hb_ms",
          :description => "Heartbeat Interval for NodeManager->ResourceManager in ms",
          :type => 'string'

attribute "hops/rm/scheduler_class",
          :description => "Java Classname for the Yarn scheduler (fifo, capacity, fair)",
          :type => 'string'

attribute "hops/logging_level",
          :description => "Log levels are: TRACE, DEBUG, INFO, WARN",
          :type => 'string'

attribute "hops/nn/heap_size",
          :description => "Size of the NameNode heap in MBs",
          :type => 'string'

attribute "hops/nn/direct_memory_size",
          :description => "Size of the direct memory size for the NameNode in MBs",
          :type => 'string'

attribute "hops/yarn/aux_services",
          :description => "mapreduce_shuffle, spark_shuffle",
          :type => "string"

attribute "hops/capacity/max_ap",
          :description => "Maximum number of applications that can be pending and running.",
          :type => "string"
attribute "hops/capacity/max_am_percent",
          :description => "Maximum percent of resources in the cluster which can be used to run application masters i.e. controls number of concurrent running applications.",
          :type => "string"
attribute "hops/capacity/resource_calculator_class",
          :description => "The ResourceCalculator implementation to be used to compare Resources in the scheduler. The default i.e. DefaultResourceCalculator only uses Memory while DominantResourceCalculator uses dominant-resource to compare multi-dimensional resources such as Memory, CPU etc.",
          :type => "string"
attribute "hops/capacity/root_queues",
          :description => "The queues at the root level (root is the root queue).",
          :type => "string"
attribute "hops/capacity/default_capacity",
          :description => "Default queue target capacity.",
          :type => "string"
attribute "hops/capacity/user_limit_factor",
          :description => " Default queue user limit a percentage from 0.0 to 1.0.",
          :type => "string"
attribute "hops/capacity/default_max_capacity",
          :description => "The maximum capacity of the default queue.",
          :type => "string"
attribute "hops/capacity/default_state",
          :description => "The state of the default queue. State can be one of RUNNING or STOPPED.",
          :type => "string"
attribute "hops/capacity/default_acl_submit_applications",
          :description => "The ACL of who can submit jobs to the default queue.",
          :type => "string"
attribute "hops/capacity/default_acl_administer_queue",
          :description => "The ACL of who can administer jobs on the default queue.",
          :type => "string"
attribute "hops/capacity/queue_mapping",
          :description => "A list of mappings that will be used to assign jobs to queues The syntax for this list is [u|g]:[name]:[queue_name][,next mapping]* Typically this list will be used to map users to queues, for example, u:%user:%user maps all users to queues with the same name as the user.",
          :type => "string"
attribute "hops/capacity/queue_mapping_override.enable",
          :description => "If a queue mapping is present, will it override the value specified by the user? This can be used by administrators to place jobs in queues that are different than the one specified by the user. The default is false.",
          :type => "string"
attribute "hops/cgroups",
          :description => "'true' to enable cgroups, else (default) 'false'",
          :type => "string"

attribute "hops/tls/enabled",
          :description => "'true' to enable ssl, 'false' to disable 'ssl'",
          :type => "string"



##
##
## Kafka
##
##
attribute "kkafka/default/private_ips",
          :description => "Set ip addresses",
          :type => "array"

attribute "kkafka/user",
          :description => "User to install kafka as",
          :type => 'string'

attribute "kkafka/group",
          :description => "Group to install kafka as",
          :type => 'string'

attribute "kkafka/dir",
          :description => "Base directory to install kafka (default: /opt)",
          :type => 'string'

attribute "kafka/ulimit",
          :description => "ULimit for the max number of open files allowed",
          :type => 'string'

attribute "kkafka/offset_monitor/port",
          :description => "Port for Kafka monitor service",
          :type => 'string'

attribute "kkafka/memory_mb",
          :description => "Kafka server memory in mbs",
          :type => 'string'

attribute "kkafka/broker/zookeeper_connection_timeout_ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/retention/hours",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/retention/size",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/message/max/bytes",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/num/network/threads",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/num/io/threads",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/num/recovery/threads/per/data/dir",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/num/replica/fetchers",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/queued/max/requests",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/socket/send/buffer/bytes",
          :description => "",
          :type => 'string'

attribute "kkafka/brattribute oker/socket/receive/buffer/bytes",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/sockeattribute t/request/max/bytes",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/num/partitionsattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/segment/bytesattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/roll/hoursattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/retention/hoursattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/retention/bytesattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/retention/check/interval/attribute ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/index/size/max/bytesattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/index/interval/bytesattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/flush/interval/messagesattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/flush/scheduler/interval/msattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/flush/interval/msattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/leader/imbalance/check/intervalattribute /seconds",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/leader/imbalance/per/broker/percentageattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/dir",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/flush/offset/checkpoint/interval/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/message/format/version",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/port",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/queued/max/requests",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/quota/consumer/default",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/quota/producer/default",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/replica/fetch/max/bytes",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/replica/fetch/min/bytes",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/replica/fetch/wait/max/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/replica/high/watermark/checkpoint/interval/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/replica/lag/time/max/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/replica/socket/receive/buffer/bytes",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/replica/socket/timeout/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/request/timeout/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/zookeeper/session/timeout/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/zookeeper/set/acl",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/replication/factor",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/cleaner/enable",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/cleaner/io/buffer/load/factor",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/security/inter/broker/protocol",
          :description => "",
          :type => 'string'

attribute "kkafka/inter/broker/protocol/version",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/rack",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/ssl/client/auth",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/ssl/key/password",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/ssl/keystore/location",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/ssl/keystore/password",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/ssl/truststore/location",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/ssl/truststore/password",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/authorizer/class/name",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/ssl/endpoint/identification/algorithm",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/principal/builder/class",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/zookeeper/synctime/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/zookeeper/connectiontimeout/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/zookeeper/sessiontimeout/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/zookeeper/synctime/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/super/users",
          :description => "For example: User:dn0;User:glassfish",
          :type => 'string'


##
##
## Elastic
##
##

attribute "elastic/default/private_ips",
          :description => "Set ip addresses",
          :type => "array"

attribute "elastic/user",
          :description =>  "Elastic user",
          :type => 'string'

attribute "elastic/group",
          :description =>  "Elastic user",
          :type => 'string'

attribute "elastic/port",
          :description =>  "Port for elasticsearch service (default: 9200)",
          :type => 'string'

attribute "elastic/ulimit_files",
          :description =>  "Number of files to set ulimit to.",
          :type => 'string'

attribute "elastic/ulimit_memlock",
          :description =>  "Memlock size for ulimit",
          :type => 'string'

attribute "elastic/dir",
          :description =>  "Base directory to install elastic search into.",
          :type => 'string'

attribute "elastic/memory",
          :description =>  "Amount of memory for Elasticsearch.",
          :type => 'string'

attribute "elastic/version",
          :description =>  "Elasticsearch version, .e.g, '2.4.1'",
          :type => 'string'

attribute "elastic/checksum",
          :description =>  "Sha-1 checksum for the elasticsearch .tar.gz file",
          :type => 'string'


##
##
## Zookeeper
##
##

attribute "kzookeeper/default/private_ips",
          :description => "Set ip addresses",
          :type => "array"

attribute "kzookeeper/version",
          :description => "Version of kzookeeper",
          :type => 'string'

attribute "kzookeeper/url",
          :description => "Url to download binaries for kzookeeper",
          :type => 'string'

attribute "kzookeeper/user",
          :description => "Run kzookeeper as this user",
          :type => 'string'

attribute "kzookeeper/group",
          :description => "Run kzookeeper user as this group",
          :type => 'string'

attribute "kzookeeper/dir",
          :description => "Base directory to install zookeeper (default: /opt)",
          :type => 'string'



##
##
## Hive
##
##

attribute "hopsworks/hive2/scratch_dir_delay",
          :description => "How much to wait before deleting the directory",
          :type => "string"

attribute "hopsworks/hive2/scratch_dir_cleaner_interval",
          :description => "Interval between scratch dir cleaner runs",
          :type => "string"



attribute "hive2/metastore/private_ips",
          :description => "Set ip addresses",
          :type => "array"

attribute "hive2/server2/private_ips",
          :description => "Set ip addresses",
          :type => "array"


##
##
## Serving
##
##

attribute "serving/base_dir",
          :description => "base directory for temporary directories for serving servers",
          :type => 'string'

attribute "serving/user",
          :description => "user to launch serving servers as",
          :type => 'string'

attribute "serving/group",
          :description => "group to launch serving servers as",
          :type => 'string'

attribute "serving/pool_size",
          :description => "size of the connection pool for serving inference requests to model serving servers",
          :type => 'string'

attribute "serving/max_route_connections",
          :description => "max number of connections to serve requests to a unique route for model serving servers",
          :type => 'string'

##
##
## Jupyter
##
##

attribute "jupyter/user",
          :description => "Jupyter username to run notebook servers as",
          :type => 'string'

attribute "jupyter/group",
          :description => "Jupyter group to run notebook servers as",
          :type => 'string'

attribute "jupyter/python",
          :description => "'true' (default) to enable the python interpreter, 'false' to disable it (more secure). ",
          :type => 'string'

attribute "jupyter/shutdown_timer_interval",
          :description => "notebook cleaner interval for shutting down expired notebooks",
          :type => 'string'

attribute "jupyter/ws_ping_interval",
          :description => "Ping frequency for the jupyter websocket",
          :type => 'string'


#
# Dela
#

attribute "dela/default/private_ips",
          :description => "ip addrs",
          :type => 'array'

attribute "dela/user",
          :description => "Username for the dela services",
          :type => 'string'

attribute "dela/group",
          :description => "Groupname for the dela services",
          :type => 'string'

attribute "dela/dir",
          :description => "dela Installation directory.",
          :type => 'string'

# Hopsworks Dela
attribute "hopsworks/public_https_port",
          :description => "Hopsworks public https port",
          :type => 'string'

attribute "hopsworks/hopssite/version",
          :description => "Enable hopssite default versions: hops, hops-demo or bbc5",
          :type => 'string'

attribute "hopsworks/dela/enabled",
          :description => "'true' to enable dela services, otherwise 'false' (default)",
          :type => 'string'

attribute "hopsworks/dela/client",
          :description => "'BASE_CLIENT' to disable upload services, otherwise 'FULL_CLIENT' (default)",
          :type => 'string'

attribute "hopsworks/dela/cluster_http_port",
          :description => "Dela cluster accessible http port",
          :type => 'string'

attribute "hopsworks/dela/public_hopsworks_port",
          :description => "Hopsworks public http port",
          :type => 'string'

attribute "hopsworks/org_name",
          :description => "Organization name for this hopsworks cluster",
          :type => 'string'

attribute "hopsworks/org_domain",
          :description => "Domain name for this organization",
          :type => 'string'

attribute "hopsworks/org_city",
          :description => "City  for this organization",
          :type => 'string'

attribute "hopsworks/org_country_code",
          :description => "2-Letter Country code for this organization ('us', 'se', 'uk', etc)",
          :type => 'string'
# Hops site

attribute "hopsworks/hopssite/domain",
          :description => "Dela hops site public domain",
          :type => 'string'

attribute "hopsworks/hopssite/port",
          :description => "Dela hops site port",
          :type => 'string'

attribute "hopsworks/hopssite/register_port",
          :description => "Dela hops site port used for cert registration",
          :type => 'string'

attribute "hopsworks/support_email_addr",
          :description => "Email address to contact for email registration problems",
          :type => 'string'

attribute "hopsworks/hopssite/heartbeat",
          :description => "Dela hops site heartbeat",
          :type => 'string'

attribute "hopssite/dela/version",
       :description => "The hopssite tracker imposed version of dela",
       :type => 'string'

attribute "hopssite/cert/cn",
	  :description => "hopssite Organization Common Name (default: hopsworks/cert)",
	  :type => 'string'

attribute "hopssite/cert/o",
	  :description => "hopssite Organization Name (default: hopsworks/cert)",
	  :type => 'string'

attribute "hopssite/cert/ou",
	  :description => "hopssite Organizational Unit Name (default: hopsworks/cert)",
	  :type => 'string'

attribute "hopssite/cert/l",
	  :description => "hopssite Locality Name (eg, city) (default: hopsworks/cert)",
	  :type => 'string'

attribute "hopssite/cert/s",
	  :description => "hopssite State or Province Name (default: hopsworks/cert)",
	  :type => 'string'

attribute "hopssite/cert/c",
	  :description => "hopssite Country Name (default: hopsworks/cert)",
	  :type => 'string'

#
# hops.site settings
#
attribute "hopssite/manual_register",
          :description => "Manually register with www.hops.site if set true. 'false' (default)",
          :type => 'string'

attribute "hopssite/url",
          :description => "Url to the global Hops Certificate Authority.",
          :type => 'string'

attribute "hopssite/user",
          :description => "To register your Hopsworks Cluster, you need to register a username at www.hops.site. This is the username for hops.site.",
          :type => 'string'

attribute "hopssite/password",
          :description => "Password for the registered username at www.hops.site.",
          :type => 'string'

attribute "hopssite/retry_interval",
          :description => "Certificate signing request retry interval for hops.site.",
          :type => 'string'

attribute "hopssite/max_retries",
          :description => "Certificate signing request maximum number of retries for hops.site.",
          :type => 'string'
#
# hops.site admin
#
attribute "hopssite/admin/password",
          :description => "Password for domain2 - running the hopssite tracker",
          :type => 'string'

# Dela Transfer specific


attribute "dela/log_level",
          :description => "Default: WARN. Can be INFO or DEBUG or TRACE or ERROR.",
          :type => "string"

attribute "dela/id",
          :description => "id for the dela instance. Randomly generated, but can be ovverriden here.",
          :type => "string"

attribute "dela/seed",
          :description => "seed for the dela instance. Randomly generated, but can be ovverriden here.",
          :type => "string"

attribute "dela/stun_port1",
          :description => "1st Client port used by stun client in Dela.",
          :type => "string"

attribute "dela/stun_port2",
          :description => "2nd Client port used by stun client in Dela.",
          :type => "string"

attribute "dela/port",
	    :description => "Dela Client application port.",
	    :type => "string"

attribute "dela/stun_client_port2",
          :description => "2nd Client port used by stun client in Dela.",
          :type => "string"

attribute "dela/port",
          :description => "Dela Client application port.",
          :type => "string"

attribute "dela/http_port",
          :description => "Dela Client http port.",
	     :type => "string"

attribute "dela/stun_servers_ip",
          :description => "Dela Client stun connections(ips).",
          :type => "array"

attribute "dela/stun_servers_id",
          :description => "Dela Client stun connections(ids).",
          :type => "array"

attribute "dela/hops/storage/type",
          :description => "Dela Client storage type(HDFS/DISK).",
          :type => "string"

attribute "dela/hops/library/type",
          :description => "Dela Client library type(MYSQL/DISK).",
          :type => "string"

##### Dela
attribute "dela/mysql/ip",
          :description => "Mysql server ip",
          :type => 'string',
          :required => "required"

attribute "dela/mysql/port",
          :description => "MySql server port",
          :type => 'string',
          :required => "required"

attribute "mysql/user",
          :description => "Mysql server username",
          :type => 'string',
          :required => "required"

attribute "mysql/password",
          :description => "MySql server password",
          :type => 'string',
          :required => "required"

#
# LDAP
#

attribute "ldap/enabled",
          :description => "Enable ldap auth. 'false' (default)",
          :type => 'string'

attribute "ldap/group_mapping",
          :description => "LDAP group to hopsworks group mappings. Format: (groupA-> HOPS_USER,HOPS_ADMIN;groupB->HOPS_USER)",
          :type => 'string'

attribute "ldap/user_id",
          :description => "The login field used by ldap. 'uid' (default)",
          :type => 'string'

attribute "ldap/user_givenName",
          :description => "Given name field of ldap 'givenName' (default)",
          :type => 'string'

attribute "ldap/user_surname",
          :description => "Surname field of ldap. 'sn' (default)",
          :type => 'string'

attribute "ldap/user_email",
          :description => "Email field of ldap. 'mail' (default)",
          :type => 'string'

attribute "ldap/user_search_filter",
          :description => "LDAP user search filter. 'uid=%s' (default)",
          :type => 'string'

attribute "ldap/group_search_filter",
          :description => "LDAP group search filter. 'member=%d' (default)",
          :type => 'string'

attribute "ldap/krb_search_filter",
          :description => "LDAP user krb search filter. 'krbPrincipalName=%s' (default)",
          :type => 'string'

attribute "ldap/attr_binary",
          :description => "LDAP global Unique Identity Code of the object attribute. 'java.naming.ldap.attributes.binary' (default)",
          :type => 'string'

attribute "ldap/group_target",
          :description => "LDAP search result group target 'cn' (default)",
          :type => 'string'

attribute "ldap/dyn_group_target",
          :description => "LDAP search result dynamic group target 'memberOf' (default)",
          :type => 'string'

attribute "ldap/user_dn",
          :description => "LDAP baseDN. '' (default)",
          :type => 'string'

attribute "ldap/group_dn",
          :description => "LDAP groupDN. '' (default)",
          :type => 'string'

attribute "ldap/account_status",
          :description => "Hopsworks account status given for new LDAP user. '1' verified account (default)",
          :type => 'string'
#LDAP External JNDI Resource
attribute "ldap/provider_url",
          :description => "LDAP provider url. ",
          :type => 'string'

attribute "ldap/jndilookupname",
          :description => "LDAP jndi lookup name. ",
          :type => 'string'

attribute "ldap/attr_binary_val",
          :description => "LDAP global Unique Identity Code of the user object. 'entryUUID' (default)",
          :type => 'string'

attribute "ldap/security_auth",
          :description => "LDAP security auth type. 'none' (default) possible values ('none', 'simple', 'sasl_mech')",
          :type => 'string'

attribute "ldap/security_principal",
          :description => "LDAP security principal. '' (default)",
          :type => 'string'

attribute "ldap/security_credentials",
          :description => "LDAP security credentials. '' (default)",
          :type => 'string'

attribute "ldap/referral",
          :description => "LDAP used to redirect a client's request to another server . 'follow' (default) possible values ('ignore', 'follow', 'throw')",
          :type => 'string'

attribute "ldap/additional_props",
          :description => "LDAP additional properties. '' (default)",
          :type => 'string'

#
# Kerberos
#

attribute "kerberos/enabled",
          :description => "Enable Kerberos auth. 'false' (default)",
          :type => 'string'

attribute "kerberos/kerberos_fqdn",
          :description => "Kerberos fully qualified domain name. '' (default)",
          :type => 'string'

attribute "kerberos/spnego_principal",
          :description => "Spnego principal . 'HTTP/server.example.com' (default)",
          :type => 'string'

attribute "kerberos/spnego_keytab_file",
          :description => "Spnego principal keytab file path. '/etc/security/keytabs/service.keytab' (default)",
          :type => 'string'

attribute "kerberos/krb_conf_path",
          :description => "Kerberos conf path. '/etc/krb5.conf' (default)",
          :type => 'string'

attribute "kerberos/spnego_server_conf",
          :description => "Spnego server extra conf. 'storeKey=true\nisInitiator=false' (default)",
          :type => 'string'

attribute "kerberos/krb_server_key_tab_path",
          :description => "Spnego server keyTab file location. '/etc/security/keytabs/service.keytab' (default)",
          :type => 'string'

attribute "kerberos/krb_server_key_tab_name",
          :description => "Spnego server keyTab file name. 'service.keytab' (default)",
          :type => 'string'

# OAuth2
attribute "oauth/enabled",
          :description => "Enable OAuth. 'false' (default)",
          :type => 'string'
attribute "oauth/redirect_uri",
          :description => "OAuth redirect uri. 'hopsworks/callback' (default)",
          :type => 'string'
attribute "oauth/account_status",
          :description => "Hopsworks account status given for new OAuth user. '1' verified account (default)",
          :type => 'string'
attribute "oauth/group_mapping",
          :description => "OAuth group to hopsworks group mappings. Format: (groupA-> HOPS_USER,HOPS_ADMIN;groupB->HOPS_USER)",
          :type => 'string'

attribute "hopsworks/disable_password_login",
          :description => "Disable password login. 'false' (default)",
          :type => 'string'
attribute "hopsworks/disable_registration",
          :description => "Disable registration. 'false' (default)",
          :type => 'string'

### Kapacitor

attribute "kapacitor/notify/email",
          :description => "Email address. Recommended to use a gmail account",
          :type => 'string'

attribute "kapacitor/slack_enabled",
          :description => "Send notifications to slack",
          :type => 'string'

attribute "kapacitor/slack_url",
          :description => "Slack url hook.",
          :type => 'string'

attribute "kapacitor/slack_channel",
          :description => "Slack channel name",
          :type => 'string'


### Kafka

attribute "hopsworks/kafka_max_num_topics",
          :description => "Default max number of kafka topics per project",
          :type => 'string'

attribute "hopsworks/kafka_num_replicas",
          :description => "Default number of replicas for Kafka Topics.",
          :type => 'string'

attribute "hopsworks/kafka_num_partitions",
          :description => "Default number of partitions for Kafka Topics.",
          :type => 'string'


### RStudio

attribute "rstudio/enabled",
          :description => "Set to 'true' to enable RStudio in Hopsworks. Default 'false'.",
          :type => 'string'

### PyPi

attribute "hopsworks/pypi_rest_endpoint",
          :description => "Url to PyPi REST API to query package information",
          :type => 'string'

### TensorBoard

attribute "hopsworks/tensorboard_max_last_accessed",
          :description => "Time in milliseconds to wait after a TensorBoard is requested before considering it old (and should be killed)",
          :type => 'string'

### JWT

attribute "hopsworks/jwt/signature_algorithm",
          :description => "Default signature algorithm for jwt. (default HS512)",
          :type => 'string'

attribute "hopsworks/jwt/lifetime_ms",
          :description => "Default lifetime in ms for jwt expiration. (default 1.3.000)",
          :type => 'string'

attribute "hopsworks/jwt/exp_leeway_sec",
          :description => "Default expiration leeway in sec. (default 900)",
          :type => 'string'

attribute "hopsworks/jwt/signing_key_name",
          :description => "Default signing key name. (default apiKey)",
          :type => 'string'

attribute "hopsworks/jwt/issuer",
          :description => "JWT issuer identifier. (default hopsworks@logicalclocks.com)",
          :type => 'string'

attribute "hopsworks/jwt/service_lifetime_ms",
          :description => "Default lifetime in ms for service jwt expiration. (default 604800000)",
          :type => 'string'

attribute "hopsworks/jwt/service_exp_leeway_sec",
          :description => "Default expiration leeway in sec for service jwt",
          :type => 'string'

### Feature Store
attribute "hopsworks/featurestore_default_storage_format",
          :description => "Default storage format for the hive database of the feature stores (ORC/PARQUET)",
          :type => 'string'

# Glassfish Http Configuration
attribute "glassfish/http/keep_alive_timeout",
          :description => "Glassfish http listeners Keep alive timeout seconds",
          :type => 'string'

# Glassfish Timer Configuration
attribute "glassfish/reschedule_failed_timer",
        :description => "Whether failed timers should be rescheduled to prevent them being expunged (default true)",
        :type => 'string'

# kagent liveness monitor configuration
attribute "hopsworks/kagent_liveness/enabled",
          :description => "Enables kagent service monitoring and restart",
          :type => 'string'

attribute "hopsworks/kagent_liveness/threshold",
          :description => "Period of time after which kagent will be declared dead and restarted. If suffix is omitted, it defaults to Minutes",
          :type => 'string'

# Online featurestore jdbc connection details
attribute "featurestore/jdbc_url",
          :description => "Url for JDBC Connection to the the Online FeatureStore",
          :type => 'string'

attribute "featurestore/user",
          :description => "User for the JDBC Connection to the the Online FeatureStore",
          :type => 'string'

attribute "featurestore/password",
          :description => "Password for the JDBC Connection to the the Online FeatureStore"

# hops-util-py
attribute "hopsworks/requests_verify",
          :description => "Whether to verify http(s) requests in hops-util-py",
          :type => 'string'

attribute "hopsworks/provenance/type",
          :description => "MIN provenance - community edition. FULL provenance - enterprise",
          :type => 'string'

attribute "hopsworks/provenance/archive/batch_size",
          :description => "Provenance cleaning size per round. Number of cleaned indices(per project)",
          :type => 'string'

attribute "hopsworks/provenance/archive/delay",
          :description => "Provenance archive delay. How long to delay cleanup of document after delete (currently only fo FULL provenance)",
          :type => 'string'

attribute "hopsworks/provenance/cleaner/period",
          :description => "Provenance cleaning delay. Define in seconds the period between two provenance cleaner timeouts - default 1h",
          :type => 'string'

# Audit log
attribute "hopsworks/audit_log_dump_enabled",
          :description => "Audit log dump to hdfs enabled. 'false' (default)",
          :type => 'string'
attribute "hopsworks/audit_log_dir",
          :description => "Audit log dir. '/srv/hops/domains/domain1/logs/audit' (default)",
          :type => 'string'
attribute "hopsworks/audit_log_file_format",
          :description => "Audit log file format. 'server_audit_log%g.log' (default)",
          :type => 'string'
attribute "hopsworks/audit_log_size_limit",
          :description => "Audit log size per file. '256000000' (default)",
          :type => 'string'
attribute "hopsworks/audit_log_count",
          :description => "Audit file count. '10' (default)",
          :type => 'string'
attribute "hopsworks/audit_log_file_type",
          :description => "Audit log file type. 'Text' (default)",
          :type => 'string'

attribute "hopsworks/zfs_key_rotation_enabled",
          :description => "Enable/disable automatic zfs key rotation",
          :type => 'string'

attribute "hopsworks/zfs_key_rotation_interval",
          :description => "Interval for Hops zfs key rotation",
          :type => 'string'
