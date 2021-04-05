name             "hopsworks"
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "Apache v2.0"
description      "Installs/Configures HopsWorks, the UI for Hops Hadoop."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "2.2.0"
source_url       "https://github.com/logicalclocks/hopsworks-chef"


%w{ ubuntu debian centos rhel }.each do |os|
  supports os
end

depends 'java', '~> 7.0.0'
depends 'simple-logstash', '~> 0.2.4'
depends 'compat_resource', '~> 12.19.0'
depends 'authbind', '~> 0.1.10'
depends 'ntp', '~> 2.0.0'
depends 'sysctl', '~> 1.0.3'
depends 'ulimit2', '~> 0.2.0'
depends 'conda'
depends 'kagent'
depends 'hops'
depends 'ndb'
depends 'hadoop_spark'
depends 'flink'
depends 'livy'
depends 'epipe'
depends 'tensorflow'
depends 'dela'
depends 'kzookeeper'
depends 'kkafka'
depends 'elastic'
depends 'hopslog'
depends 'hopsmonitor'
depends 'hops_airflow'
depends 'hive2'
depends 'consul'
depends 'ulimit'
depends 'glassfish'
depends 'kube-hops'
depends 'onlinefs'


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

attribute "glassfish/user-home",
          :description => "Home directory of glassfish user",
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

attribute "hopsworks/internal/port",
          :description => "Port that the webserver will listen on for internal calls",
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

attribute "hopsworks/download_url",
          :description => "Base URL to download Hopsworks artifacts e.g. DOWNLOAD_URL/hopsworks.war",
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

attribute "hopsworks/mysql/user",
          :description => "Hopsworks MySQL username",
          :type => 'string'

attribute "hopsworks/mysql/password",
          :description => "Hopsworks MySQL password",
          :type => 'string'

attribute "hopsworks/check_nodemanager_status",
          :description => "Boolean value to check nodemanagers status before starting a job",
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



##
##
## Serving
##
##

attribute "serving/base_dir",
          :description => "base directory for temporary directories for serving servers",
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
          :description => "LDAP used to redirect a client's request to another server . 'ignore' (default) possible values ('ignore', 'follow', 'throw')",
          :type => 'string'

attribute "ldap/additional_props",
          :description => "LDAP additional properties. '' (default)",
          :type => 'string'

attribute "ldap/group_mapping_sync_interval",
          :description => "LDAP group mapping sync interval in hours. 0 (default)",
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
attribute "oauth/logout_redirect_uri",
          :description => "OAuth logout redirect uri. 'hopsworks/' (default)",
          :type => 'string'
attribute "oauth/account_status",
          :description => "Hopsworks account status given for new OAuth user. '1' verified account (default)",
          :type => 'string'
attribute "oauth/group_mapping",
          :description => "OAuth group to hopsworks group mappings. Format: (groupA-> HOPS_USER,HOPS_ADMIN;groupB->HOPS_USER)",
          :type => 'string'

attribute "remote_auth/need_consent",
          :description => "Remote user need to consent on first login. 'true' (default)",
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
          :description => "Default lifetime in ms for jwt expiration. (default 2.2.000)",
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

attribute "featurestore/job_activity_timer",
          :description => "How often to run the timer to backfill jobs for feature groups and training datasets - default 5 minutes",
          :type => 'string'

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

# Hopsworks HDFS storage policies
# accepted hopsworks storage policy files: CLOUD, DB, HOT
attribute "hopsworks/hdfs/storage_policy/base",
          :description => "Set the DIR_ROOT (/Projects) storage policy. Default is DB. Accepted values: CLOUD/DB/HOT",
          :type => 'string'
attribute "hopsworks/hdfs/storage_policy/log",
          :description => "Set the project LOG_DIR storage policy. Default is HOT. Accepted values: CLOUD/DB/HOT",
          :type => 'string'

# Expat
attribute "hopsworks/expat_url",
          :description => "Url to download expat from",
          :type => 'string'

#TensorBoard'
attribute "tensorboard/max/reload/threads",
          :description => "The max number of threads that TensorBoard can use to reload runs. Not relevant for db read-only mode. Each thread reloads one run at a time.",
          :type => "string"

#Azure CA cert download url
attribute "hopsworks/azure-ca-cert/download-url",
          :description => "Azure CA cert download url. 'https://cacerts.digicert.com/DigiCertGlobalRootG2.crt' (default)",
          :type => "string"
