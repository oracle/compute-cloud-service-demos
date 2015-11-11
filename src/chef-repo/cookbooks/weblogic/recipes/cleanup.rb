# Cleanup temp files during install
bash "Cleanup temp files" do
  user node['oracle']['user']
  group node['oracle']['group']
  code <<-EOH
  cd /tmp
  rm *.xml 
  cd "#{node['oracle']['installers']}"
  rm *
  cd "#{node['oracle']['domain_home']}"
  rm *.py 
  EOH
end

