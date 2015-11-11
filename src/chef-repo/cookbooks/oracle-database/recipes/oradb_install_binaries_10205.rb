# coding: utf-8
#
# Cookbook Name:: oracle-database
# Recipe:: oradb_install_binaries_10205
#
# Copyright 2015 Oracle and/or its affiliates. 
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Installing oracle-validated RPM for prerequisites for Oracle Database 10gR2
yum_package 'oracle-validated' 
yum_package 'expect'


# Creating directory structure
# Directory to hold ORACLE_BASE 
directory "#{node['oracle']['oracle_base']}/.."  do
   owner "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    mode '0755'
    recursive true
    action :create
end

# Creating ORACLE_BASE
directory "#{node['oracle']['oracle_base']}"  do
   owner "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    mode '0755'
    recursive true
    action :create
end

# Directory to hold ORACLE_HOME
directory "#{node['oracle']['oracle_home']}/../.."  do
   owner "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    mode '0755'
    recursive true
    action :create
end

# Directory to hold ORACLE_HOME
directory "#{node['oracle']['oracle_home']}/.."  do
   owner "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    mode '0755'
    recursive true
    action :create
end

# ORACLE_HOME
directory "#{node['oracle']['oracle_home']}"  do
    owner "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    mode '0755'
end


# Create oraInventory Location
directory "#{node['oracle']['ora_inventory']}"  do
   owner "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    mode '0755'
    recursive true
    action :create
end



# Create Stage Location
directory "#{node['oracle']['stage']}"  do
   owner "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    mode '0755'
    recursive true
    action :create
end

# Create Installer Location
directory "#{node['oracle']['installers']}"  do
   owner "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    mode '0755'
    recursive true
    action :create
end

# Define Source
software_repo = "https://#{URI(Chef::Config[:chef_server_url]).host}:#{URI(Chef::Config[:chef_server_url]).port}/files"

# Download Installer 10.2.0.1
  remote_file "#{node['oracle']['installers']}/#{node['oracle']['db_installer_zip']}" do
  source "#{software_repo}/#{node['oracle']['db_installer_zip']}"
  owner "#{node['oracle']['user']}"
  group "#{node['oracle']['group']}"
  action :create_if_missing
  end

  
# Extract Installer 10.2.0.1
  execute "unzip_oracle" do
    command "unzip -q -o #{node['oracle']['installers']}/#{node['oracle']['db_installer_zip']}"
    user "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    cwd node['oracle']['stage']
	not_if { ::File.exists?("#{node['oracle']['stage']}/database/runInstaller)")}
  end


  #Download Patch 10.2.0.5
  remote_file "#{node['oracle']['installers']}/#{node['oracle']['patch_installer_zip']}" do
    source "#{software_repo}/#{node['oracle']['patch_installer_zip']}"
	owner "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
	mode '0644'
    action :create_if_missing
  end



# Extract Patch 10.2.0.5
  execute "unzip_oracle_#{node['oracle']['patch_installer_zip']}" do
    command "unzip -q -o #{node['oracle']['installers']}/#{node['oracle']['patch_installer_zip']}"
    user "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    cwd node['oracle']['stage']
	not_if { ::File.exists?("#{node['oracle']['stage']}/#{node['oracle']['patch_installer_inner_zip']}")}
  end

 # Extract Patch 10.2.0.5 
  execute "unzip_oracle_#{node['oracle']['patch_installer_inner_zip']}" do
    command "unzip -q -o #{node['oracle']['stage']}/#{node['oracle']['patch_installer_inner_zip']}"
    user "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    cwd node['oracle']['stage']
	not_if { ::File.exists?("#{node['oracle']['stage']}/Disk1)")}
  end
  
  
  
#Download PSU
  remote_file "#{node['oracle']['installers']}/#{node['oracle']['psu_installer_zip']}" do
    source "#{software_repo}/#{node['oracle']['psu_installer_zip']}"
	owner "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
	mode '0644'
    action :create_if_missing
  end


# Extract PSU
execute "unzip_oracle_#{node['oracle']['psu_installer_zip']}" do
    command "unzip -q -o #{node['oracle']['installers']}/#{node['oracle']['psu_installer_zip']}"
    user "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    cwd node['oracle']['stage']
	not_if { ::File.exists?("#{node['oracle']['stage']}/#{node['oracle']['psu_patch_number']}")}
  end  
  
#Download OPatch
  remote_file "#{node['oracle']['installers']}/#{node['oracle']['opatch_installer_zip']}" do
    source "#{software_repo}/#{node['oracle']['opatch_installer_zip']}"
	owner "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
	mode '0644'
    action :create_if_missing
  end
  

#Create oraInst.loc
file "#{node['oracle']['oraInst']}" do
 owner "#{node['oracle']['user']}"
  group "#{node['oracle']['group']}"
  content "inst_group=#{node['oracle']['group']}\ninventory_loc=#{node['oracle']['ora_inventory']}"
  mode '0644'
end
  
  
  # Install Oracle Home 10.2.0.1
execute "Install Oracle Home" do
  command "sudo -Eu oracle ./runInstaller -ignoreSysPrereqs -silent  -waitforcompletion FROM_LOCATION=#{node['oracle']['stage']}/database/stage/products.xml ORACLE_HOME=#{node['oracle']['oracle_home']} ORACLE_HOME_NAME=#{node['oracle']['oracle_home_name']} TOPLEVEL_COMPONENT='{'oracle.server','10.2.0.1.0'}' INSTALL_TYPE=#{node['oracle']['oracle_home_edition']} n_configurationOption=3"
  cwd "#{node['oracle']['stage']}/database"
  returns [0, 6]
end

# root.sh for Install Oracle Home 10.2.0.1
 execute 'install_root.sh' do
    command "sudo #{node['oracle']['oracle_home']}/root.sh"
  end

# Patch Oracle Home 10.2.0.5
execute "Install Oracle Home" do
  command "sudo -Eu oracle ./runInstaller -ignoreSysPrereqs -waitforcompletion -silent FROM_LOCATION=#{node['oracle']['stage']}/Disk1/stage/products.xml ORACLE_HOME=#{node['oracle']['oracle_home']} ORACLE_HOME_NAME=#{node['oracle']['oracle_home_name']} TOPLEVEL_COMPONENT='{'oracle.patchset.db','10.2.0.5.0'}' DECLINE_SECURITY_UPDATES=TRUE"
  cwd "#{node['oracle']['stage']}/Disk1"
  action :run
end

# root.sh for Patch Oracle Home 10.2.0.5
 execute 'patch_root.sh' do
    command "sudo #{node['oracle']['oracle_home']}/root.sh"
  end



# Extract OPatch into Oracle Home 10.2.0.5
execute "unzip_oracle_#{node['oracle']['opatch_installer_zip']}" do
    command "unzip -o -q #{node['oracle']['installers']}/#{node['oracle']['opatch_installer_zip']}"
    user "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    cwd node['oracle']['oracle_home']
  end  


ENV['ORACLE_BASE'] = node['oracle']['oracle_base']
ENV['ORACLE_HOME'] = node['oracle']['oracle_home']

# Creating OCM response file for silent OPatch
template "#{node['oracle']['oracle_home']}/ocm_rsp_gen.sh" do
  source 'ocm_rsp_gen.sh.erb'
  owner "#{node['oracle']['user']}"
  group "#{node['oracle']['group']}"
  mode '0700'
end

execute 'create_opatch_ocm_rsp' do
  command "#{node['oracle']['oracle_home']}/ocm_rsp_gen.sh"
  user "#{node['oracle']['user']}"
  group "#{node['oracle']['group']}"
  cwd node['oracle']['oracle_home']
end

# OPatch Apply PSU
execute "Apply Patch #{node['oracle']['psu_patch_number']} to Oracle Home" do
  command "#{node['oracle']['oracle_home']}/OPatch/opatch apply -silent -ocmrf #{node['oracle']['oracle_home']}/ocm.rsp"
  user node['oracle']['user']
  group node['oracle']['group']
  cwd "#{node['oracle']['stage']}/#{node['oracle']['psu_patch_number']}"
  action :run
end
