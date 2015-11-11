
template "#{node['oracle']['domain_home']}/create_#{node['oracle']['domain_name']}_machine.py" do
  source "create_machine.py.erb"
  owner node['oracle']['user']
  group node['oracle']['group']
  mode "0755"
end

execute "wlst.sh create_#{node['oracle']['domain_name']}_machine.py" do
  command "#{node['oracle']['wls_install_dir']}/common/bin/wlst.sh #{node['oracle']['domain_home']}/create_#{node['oracle']['domain_name']}_machine.py"
  user node['oracle']['user']
  group node['oracle']['group']
  action :run
end
