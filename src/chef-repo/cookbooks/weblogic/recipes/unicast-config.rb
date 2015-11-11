bash "Make changes to config.xml" do
  user node['oracle']['user']
  code <<-EOH
cp '#{node[:oracle][:domain_home]}/#{node[:oracle][:domain_name]}/config/config.xml' '#{node[:oracle][:domain_home]}/#{node[:oracle][:domain_name]}/config/config.xml.orig' 
sed '/unicast/a  <message-ordering-enabled>true</message-ordering-enabled>' '#{node[:oracle][:domain_home]}/#{node[:oracle][:domain_name]}/config/config.xml.orig' > '#{node[:oracle][:domain_home]}/#{node[:oracle][:domain_name]}/config/config.xml'
  EOH
end
