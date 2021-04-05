action :generate do

ca_dir=node['certs']['dir']

bash 'certificateauthority' do
    user "root"
    code <<-EOF
      ####
      # Done on CA server
      ###

      set -eo pipefail

	    KEYSTOREPW=#{node['hopsworks']['master']['password']}

      rm -f $HOME/.rnd
	    cd "#{ca_dir}"
      BASEDIR="#{ca_dir}"
	    chmod 700 private
      touch index.txt
      chmod 700 index.txt
      echo 1000 > serial
      chmod 700 serial

      touch serial.old
      chmod 700 serial.old

      touch index.txt.old
      chmod 700 index.txt.old

	    #2 Create the root key
	    [ -f private/ca.key.pem ] || openssl genrsa -aes256 -out private/ca.key.pem -passout pass:${KEYSTOREPW} 4096

	    chmod 400 private/ca.key.pem

	    #3 Create the root certificate
	    [ -f certs/ca.cert.pem ] || openssl req -subj "/C=SE/ST=Sweden/L=Stockholm/O=SICS/CN=HopsRootCA" -passin pass:${KEYSTOREPW} -passout pass:${KEYSTOREPW} -key private/ca.key.pem -new -x509 -days 7300 -sha256 -extensions v3_ca -out certs/ca.cert.pem

	    chmod 444 certs/ca.cert.pem

      ####
      # Done on Intermediate server
      ###

	    #4 Prepare the intermediate directories
	    chmod 700 intermediate/private/
	    touch intermediate/index.txt
	    echo 1000 > intermediate/serial
	    echo 1000 > intermediate/crlnumber

	    #5 Create the intermediate key
	    [ -f intermediate/private/intermediate.key.pem ] || openssl genrsa -aes256 -out intermediate/private/intermediate.key.pem -passout pass:${KEYSTOREPW} 4096

	    chown #{node['glassfish']['user']}:#{node['glassfish']['group']} intermediate/private/intermediate.key.pem
	    chmod 440 intermediate/private/intermediate.key.pem

	    #6 Create the intermediate certificate
      # Done on client
	    [ -f intermediate/csr/intermediate.csr.pem ] || openssl req -new -sha256 -subj "/C=SE/ST=Sweden/L=Stockholm/O=SICS/CN=HopsIntermediateCA" \
        -key intermediate/private/intermediate.key.pem -passin pass:${KEYSTOREPW} -passout pass:${KEYSTOREPW} -out intermediate/csr/intermediate.csr.pem


      # Done on server when signing intermediate certs on behalf of hopsworks instances (REST Call)

	    KEYSTOREPW=#{node['hopsworks']['master']['password']}

	    [ -f intermediate/certs/intermediate.cert.pem ] || openssl ca -batch -config openssl-ca.cnf -extensions v3_intermediate_ca \
        -days 3650 -notext -md sha256 -passin pass:${KEYSTOREPW} -in intermediate/csr/intermediate.csr.pem -out intermediate/certs/intermediate.cert.pem

	    chmod 444 intermediate/certs/intermediate.cert.pem
	    #7 Verify the intermediate certificate
	    openssl verify -CAfile certs/ca.cert.pem intermediate/certs/intermediate.cert.pem
	    #8 Create the certificate chain file
	    cat intermediate/certs/intermediate.cert.pem certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
	    chmod 444 intermediate/certs/ca-chain.cert.pem
      # http://www.mad-hacking.net/documentation/linux/security/ssl-tls/signing-csr.xml
      echo "unique_subject = yes\n" > intermediate/index.txt.attr

      # 10 Generate CRL for intermediate CA
      openssl ca -config intermediate/openssl-intermediate.cnf -gencrl -passin pass:${KEYSTOREPW} -out intermediate/crl/intermediate.crl.pem
      chown #{node['glassfish']['user']}:#{node['glassfish']['group']} intermediate/crl/intermediate.crl.pem
    EOF
 not_if { ::File.exists?("#{ca_dir}/intermediate/certs/ca-chain.cert.pem" ) }
end

end


action :sign_hopssite do

  signed = "#{node['hopsworks']['domains_dir']}/.hops_site_keystore_signed"

  bash "sign-global-csr-key" do
    user node['hopsworks']['user']
    group node['hopsworks']['group']
    code <<-EOF
      set -eo pipefail
      export PYTHON_EGG_CACHE=/tmp
      #{node['conda']['base_dir']}/envs/hops-system/bin/python #{node['hopsworks']['domains_dir']}/domain1/bin/csr-ca.py
      touch #{signed}
  EOF
    not_if { ::File.exists?( "#{signed}" ) }
  end
end


action :generate_int_certs do 

  bash 'generate-key' do
    user node['hopsworks']['user']
    group node['hopsworks']['group']
    cwd node['hopsworks']['config_dir']
    code <<-EOH
      openssl genrsa -out internal.key 2048 
      openssl req -new -key internal.key -subj #{new_resource.subject} -out internal.csr
    EOH
  end

  # Sign the certificate
  ruby_block 'sign-csr' do
    block do
      require 'net/https'
      require 'http-cookie'
      require 'json'

      url = URI.parse("https://127.0.0.1:#{node['hopsworks']['https']['port']}/hopsworks-api/api/auth/service")
      ca_url = URI.parse("https://127.0.0.1:#{node['hopsworks']['https']['port']}/hopsworks-ca/v2/certificate/host")


      params =  {
        :email => node["kagent"]["dashboard"]["user"],
        :password => node["kagent"]["dashboard"]["password"]
      }

      http = Net::HTTP.new(url.host, url.port)
      http.read_timeout = 120
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      jar = ::HTTP::CookieJar.new

      http.start do |connection|

        request = Net::HTTP::Post.new(url)
        request.set_form_data(params, '&')
        response = connection.request(request)

        if( response.is_a?( Net::HTTPSuccess ) )
            # your request was successful
            puts "The Response -> #{response.body}"

            response.get_fields('Set-Cookie').each do |value|
              jar.parse(value, url)
            end

            csr = ::File.read("#{node['hopsworks']['config_dir']}/internal.csr")
            request = Net::HTTP::Post.new(ca_url)
            request.body = {'csr' => csr}.to_json
            request['Content-Type'] = "application/json"
            request['Cookie'] = ::HTTP::Cookie.cookie_value(jar.cookies(ca_url))
		        request['Authorization'] = response['Authorization']
            response = connection.request(request)

            if ( response.is_a? (Net::HTTPSuccess))
              json_response = ::JSON.parse(response.body)
              ::File.write("#{node['hopsworks']['config_dir']}/internal.crt", json_response['signedCert'])
            else
              raise "Error signing certificate"
            end
        else
            puts response.body
            raise "Error logging in"
        end
      end
    end
  end

  # Add the certificate to the keystore.jks
  bash "add_to_keystore" do 
    user node['hopsworks']['user']
    group node['hopsworks']['group']
    cwd node['hopsworks']['config_dir']
    code <<-EOH
        set -e
        # Create the bundle 
        cat internal.crt #{node['certs']['dir']}/intermediate/certs/intermediate.cert.pem > internal_bundle.crt

        openssl pkcs12 -export -in internal_bundle.crt -inkey internal.key -out cert_and_key.p12 -name internal -CAfile #{node['certs']['dir']}/certs/ca.cert.pem -caname internal -password pass:#{node['hopsworks']['master']['password']}

        # Import into the keystore
        keytool -importkeystore -destkeystore keystore.jks -srckeystore cert_and_key.p12 -srcstoretype PKCS12 -alias internal -srcstorepass #{node['hopsworks']['master']['password']} -deststorepass #{node['hopsworks']['master']['password']} -destkeypass #{node['hopsworks']['master']['password']}

         keytool -import -noprompt -alias internal -file #{node['certs']['dir']}/certs/ca.cert.pem -keystore cacerts.jks -storepass #{node['hopsworks']['master']['password']}
        
    EOH
  end

end

action :download_azure_ca_cert do
  # Download azure root CA cert
  remote_file '/tmp/DigiCertGlobalRootG2.crt' do
    source "#{node['hopsworks']['azure-ca-cert']['download-url']}"
    mode '0755'
    action :create
  end

  # Add the certificate to the keystore.jks
  bash "add_to_keystore" do 
    user "root"
    cwd "/tmp"
    code <<-EOH
      set -e
      GFDOMAIN=#{node['glassfish']['domains_dir']}/domain1
      # Import into the keystore
      keytool -import -noprompt -alias digicertglobalrootg2 -file DigiCertGlobalRootG2.crt -keystore $GFDOMAIN/config/cacerts.jks -storepass #{node['hopsworks']['master']['password']}
    EOH
  end
end