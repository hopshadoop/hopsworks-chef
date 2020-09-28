case node['platform_family']
 when 'debian'

bash 'dev-setup' do
    user "root"
    code <<-EOF
       apt-get install git -y 
       apt-get install nodejs -y
       apt-get install npm -y
       npm install -g bower
       ln -s /usr/bin/nodejs /usr/bin/node

       # Turn-on debug mode for both sysv and systemd init scripts
       perl -pi -e "s/--debug false/--debug true/g" /etc/init.d/glassfish-domain1
       perl -pi -e "s/--debug false/--debug true/g" /etc/systemd/system/glassfish-domain1.service
       perl -pi -e "s/--debug false/--debug true/g" /lib/systemd/system/glassfish-domain1.service
       chown -R #{node['hopsworks']['user']} /home/#{node['hopsworks']['user']}/.config
       systemctl stop glassfish-domain1
       systemctl daemon-reload
       sleep 1
       systemctl start glassfish-domain1
    EOF
  end

 when 'redhat', 'amazon' 

   # Needs: yum install npm -y --skip-broken
#   package "npm"
   
bash 'dev-setup-centos' do
    user "root"
    code <<-EOF
#       npm install -g bower
# Turn-on debug mode for both sysv and systemd init scripts
       perl -pi -e "s/--debug false/--debug true/g" /etc/init.d/glassfish-domain1
       perl -pi -e "s/--debug false/--debug true/g" /etc/systemd/system/glassfish-domain1.service
       perl -pi -e "s/--debug false/--debug true/g" /lib/systemd/system/glassfish-domain1.service
       chown -R #{node['hopsworks']['user']} /home/#{node['hopsworks']['user']}/.config
       systemctl stop glassfish-domain1
       systemctl daemon-reload
       sleep 1
       systemctl start glassfish-domain1

    EOF
end
end   
