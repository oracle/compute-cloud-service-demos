domain_home_dirs = [ 
  "#{node['oracle']['beahome']}",
  "#{node['oracle']['beahome']}/user_projects",
  "#{node['oracle']['domain_home']}" ,
  "#{node['oracle']['domain_home']}/#{node['oracle']['domain_name']}",
  "#{node['oracle']['user_home']}/wlst_scripts"
]

domain_home_dirs.each do |dirname|
  directory dirname do
    owner node['oracle']['user'] 
    group node['oracle']['group'] 
    mode 00755
    action :create
  end
end

template "#{node['oracle']['domain_home']}/create_#{node['oracle']['domain_name']}_domain.py" do
  source "create_domain.py.erb"
  owner node['oracle']['user'] 
  group node['oracle']['group'] 
  mode "0755"
end

execute "wlst.sh create_#{node['oracle']['domain_name']}_domain.py" do
  command "#{node['oracle']['wls_install_dir']}/common/bin/wlst.sh #{node['oracle']['domain_home']}/create_#{node['oracle']['domain_name']}_domain.py"
  creates "#{node['oracle']['domain_home']}/#{node['oracle']['domain_name']}/bin"
  user node['oracle']['user'] 
  group node['oracle']['group'] 
  action :run
end
