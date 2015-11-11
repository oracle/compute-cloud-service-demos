#include_recipe 'java'

# bsu silent install file
template "/tmp/bsusilent.xml" do
  source 'bsusilent.xml.erb'
  owner node['oracle']['user']
  group node['oracle']['group']
  mode '0744'
end

# Download bea 10.3 installer
remote_file "p12426828_1035_Generic" do
  path "#{node['oracle']['installers']}/#{node['oracle']['bsu_patch']}"
  source "#{node['oracle']['download_loc']}#{node['oracle']['bsu_patch']}"
  owner node['oracle']['user']
  group node['oracle']['group']
  mode '0744'
end

# Extract zip
execute "Extract zip" do
  command "unzip -o -q #{node[:oracle][:installers]}/#{node[:oracle][:bsu_patch]} -d #{node[:oracle][:installers]}"
  user node['oracle']['user']
  group node['oracle']['group']
  action :run
end


# Install bsu update
execute "Install patch" do
  command "#{node[:oracle][:local_jvms]}/bin/java -jar #{node[:oracle][:installers]}/patch-client-installer330_generic32.jar -mode=silent -silent_xml=/tmp/bsusilent.xml"
  user node['oracle']['user']
  group node['oracle']['group']
  action :run
end

