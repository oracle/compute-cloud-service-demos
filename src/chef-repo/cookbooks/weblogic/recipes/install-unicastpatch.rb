#include_recipe 'java'

# Download patch
remote_file "UnicastPatch_Generic" do
  path "#{node['oracle']['installers']}/#{node['oracle']['unicast_patch']}"
  source "#{node['oracle']['download_loc']}#{node['oracle']['unicast_patch']}"
  owner node['oracle']['user']
  group node['oracle']['group']
  mode '0744'
end

#create Installers folder
directory "#{node['oracle']['beahome']}/utils/bsu/cache_dir" do
  owner node['oracle']['user']
  group node['oracle']['group']
  action :create
end

# Extract zip
execute "Extract zip" do
  command "unzip -o -q #{node['oracle']['installers']}/#{node['oracle']['unicast_patch']} -d #{node['oracle']['beahome']}/utils/bsu/cache_dir"
  user node['oracle']['user']
  group node['oracle']['group']
  action :run
end

# Install bsu update
bash "Install patch" do
  user node['oracle']['user']
  group node['oracle']['group']
  code <<-EOH
  cd "#{node['oracle']['beahome']}/utils/bsu"
  ./bsu.sh -install -patchlist=#{node[:oracle][:patchlist]} -prod_dir="#{node[:oracle][:beahome]}/wlserver_10.3"
  EOH
end

