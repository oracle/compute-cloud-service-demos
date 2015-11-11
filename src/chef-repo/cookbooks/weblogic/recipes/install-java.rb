# Create oracle User
user node['oracle']['user'] do
  action :create
end

# Create the oracle  group
group node['oracle']['group'] do
  members [node['oracle']['user']]
end

#create stage folder
directory node['oracle']['stg'] do
  owner node['oracle']['user']
  group node['oracle']['group']
  action :create
end

#create mwhome folder
directory node['oracle']['beahome'] do
  owner node['oracle']['user']
  group node['oracle']['group']
  action :create
end

#create Installers folder
directory node['oracle']['installers'] do
  owner node['oracle']['user']
  group node['oracle']['group']
  action :create
end


# Download bea Java 6 installer
remote_file "jdk-6u45-linux-x64" do
  path "#{node['oracle']['installers']}/#{node['oracle']['java_installer']}"
  source "#{node['oracle']['download_loc']}#{node['oracle']['java_installer']}"
  owner node['oracle']['user']
  group node['oracle']['group']
  mode '0744'  
end

# Install Java 6
execute "Install Java" do
  command "yes | #{node['oracle']['installers']}/#{node['oracle']['java_installer']} "
  cwd "#{node['oracle']['beahome']}"
  user node['oracle']['user']
  group node['oracle']['group']
  creates node['oracle']['java_install_dir']
  action :run
end
