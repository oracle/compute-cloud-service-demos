# coding: utf-8
#
# Cookbook Name:: oracle-database
# Recipe:: oradb_install_binaries_12102
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

# Installing oracle-validated RPM for prerequisites for Oracle Database 12cR1
yum_package 'oracle-rdbms-server-12cR1-preinstall'
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
directory "#{node['oracle']['oracle_home_12c']}/../.."  do
   owner "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    mode '0755'
    recursive true
    action :create
end


# Directory to hold ORACLE_HOME
directory "#{node['oracle']['oracle_home_12c']}/.."  do
   owner "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    mode '0755'
    recursive true
    action :create
end

# ORACLE_HOME
directory "#{node['oracle']['oracle_home_12c']}"  do
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

# Download Installer 12.1.0.1
  node['oracle']['db_installer_zip_12c'].each do |zip|
  remote_file "#{node['oracle']['installers']}/#{zip}" do
  source "#{software_repo}/#{zip}"
  owner "#{node['oracle']['user']}"
  group "#{node['oracle']['group']}"
  action :create_if_missing
  end
 end
  
# Extract Installer 12.1.0.1
 node['oracle']['db_installer_zip_12c'].each do |zip| 
 execute "unzip_oracle" do
    command "unzip -q -o #{node['oracle']['installers']}/#{zip}"
    user "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    cwd node['oracle']['stage']
  end
end
  
#Download PSU
node['oracle']['psu_installer_zip_12c'].each do |zip|
  remote_file "#{node['oracle']['installers']}/#{zip}" do
    source "#{software_repo}/#{zip}"
    owner "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    mode '0644'
    action :create_if_missing
  end
end

# Extract PSU
node['oracle']['psu_installer_zip_12c'].each do |zip|
execute "unzip_oracle_#{zip}" do
    command "unzip -q -o #{node['oracle']['installers']}/#{zip}"
    user "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    cwd node['oracle']['stage']
  end  
end
  
#Download OPatch
  remote_file "#{node['oracle']['installers']}/#{node['oracle']['opatch_installer_zip_12c']}" do
    source "#{software_repo}/#{node['oracle']['opatch_installer_zip_12c']}"
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
  
  
  # Install Oracle Home 12.1.0.2
execute "Install Oracle Home" do
  command "sudo -Eu oracle ./runInstaller -ignoreSysPrereqs -silent -showprogress -waitforcompletion FROM_LOCATION=#{node['oracle']['stage']}/database/stage/products.xml ORACLE_HOME=#{node['oracle']['oracle_home_12c']} oracle.install.option=INSTALL_DB_SWONLY oracle.install.db.InstallEdition=#{node['oracle']['oracle_home_edition']} oracle.install.db.DBA_GROUP=#{node['oracle']['dba_group']} oracle.install.db.OPER_GROUP=#{node['oracle']['oper_group']}  oracle.install.db.BACKUPDBA_GROUP=#{node['oracle']['backupdba_group']}  oracle.install.db.DGDBA_GROUP=#{node['oracle']['dgdba_group']} oracle.install.db.KMDBA_GROUP=#{node['oracle']['kmdba_group']} DECLINE_SECURITY_UPDATES=true"
  cwd "#{node['oracle']['stage']}/database"
  returns [0, 6]
end

# root.sh for Install Oracle Home 12.1.0.2 
 execute 'install_root.sh' do
    command "sudo #{node['oracle']['oracle_home_12c']}/root.sh"
  end

# Extract OPatch into Oracle Home 12.1.0.2 
execute "unzip_oracle_#{node['oracle']['opatch_installer_zip']}" do
    command "unzip -o -q #{node['oracle']['installers']}/#{node['oracle']['opatch_installer_zip_12c']}"
    user "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    cwd node['oracle']['oracle_home_12c']
  end  


ENV['ORACLE_BASE'] = node['oracle']['oracle_base']
ENV['ORACLE_HOME'] = node['oracle']['oracle_home_12c']

# Creating OCM response file for silent OPatch
template "#{node['oracle']['oracle_home_12c']}/ocm_rsp_gen.sh" do
  source 'ocm_rsp_gen.sh.erb'
  owner "#{node['oracle']['user']}"
  group "#{node['oracle']['group']}"
  mode '0700'
end

execute 'create_opatch_ocm_rsp' do
  command "#{node['oracle']['oracle_home_12c']}/ocm_rsp_gen.sh"
  user "#{node['oracle']['user']}"
  group "#{node['oracle']['group']}"
  cwd node['oracle']['oracle_home_12c']
end

  
# OPatch Apply PSU
node['oracle']['psu_patch_number_12c'].each do |patch|
execute "Apply Patch #{patch} to Oracle Home" do
  command "#{node['oracle']['oracle_home_12c']}/OPatch/opatch apply -silent -ocmrf #{node['oracle']['oracle_home_12c']}/ocm.rsp"
  user node['oracle']['user']
  group node['oracle']['group']
  cwd "#{node['oracle']['stage']}/#{node['oracle']['psu_base_patch_number_12c']}/#{patch}"
  action :run
end
end

