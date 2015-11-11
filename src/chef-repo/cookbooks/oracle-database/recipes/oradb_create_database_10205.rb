# coding: utf-8
#
# Cookbook Name:: oracle-database
# Recipe:: oradb_create_database_10205
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

# Create Datafile Location
directory "#{node['oracle']['datafileDestination']}"  do
   owner "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    mode '0755'
    recursive true
    action :create
end

# Create FRA Location
directory "#{node['oracle']['recoveryAreaDestination']}"  do
   owner "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    mode '0755'
    recursive true
    action :create
end

# Create Redo Location
directory "#{node['oracle']['redoLogDestination']}"  do
   owner "#{node['oracle']['user']}"
    group "#{node['oracle']['group']}"
    mode '0755'
    recursive true
    action :create
end


# Run DBCA to create the default Database

ENV['ORACLE_BASE'] = node['oracle']['oracle_base']
ENV['ORACLE_HOME'] = node['oracle']['oracle_home']
ENV['ORACLE_SID'] = node['oracle']['oracle_sid']

execute "Execute DBCA" do
  command "./dbca -silent -createDatabase -templateName #{node['oracle']['templateName']} -gdbname #{node['oracle']['gdbname']} -sid #{node['oracle']['sid']} -responseFile NO_VALUE -characterSet #{node['oracle']['characterSet']} -memoryPercentage #{node['oracle']['memoryPercentage']} -emConfiguration #{node['oracle']['emConfiguration']} -datafileDestination #{node['oracle']['datafileDestination']} -recoveryAreaDestination #{node['oracle']['recoveryAreaDestination']}"
  user node['oracle']['user']
  group node['oracle']['group']
  cwd "#{node['oracle']['oracle_home']}/bin"
  action :run
end

  bash "add_redo_logs" do
    user node['oracle']['user']
    group node['oracle']['group']
	cwd "#{node['oracle']['oracle_home']}/bin"
    environment ({ 'ORACLE_HOME' => "#{node['oracle']['oracle_home']}"})
	code <<-EOH2
       export ORACLE_SID=#{node['oracle']['sid']}
       ./sqlplus / as sysdba <<-EOL1
       SET SERVEROUTPUT ON;
       ALTER DATABASE ADD LOGFILE MEMBER  '#{node['oracle']['redoLogDestination']}/redo_g01a.log' TO GROUP 1;\n
       ALTER DATABASE ADD LOGFILE MEMBER  '#{node['oracle']['redoLogDestination']}/redo_g02a.log' TO GROUP 2;\n
       ALTER DATABASE ADD LOGFILE MEMBER  '#{node['oracle']['redoLogDestination']}/redo_g03a.log' TO GROUP 3;\n
        DECLARE
        CURSOR rlc
        IS
        SELECT MEMBER FROM V\\$LOGFILE LF INNER JOIN V\\$LOG L ON LF.GROUP# = L.GROUP#;
        stmt VARCHAR2(2048);
        BEGIN
  FOR rlcRec IN rlc
  LOOP
    IF (rlcRec.member like '/u02/app/oracle/oradata/orcl/redo0%.log') THEN
      stmt           := 'ALTER DATABASE DROP LOGFILE MEMBER '''||rlcRec.member||'''';
      BEGIN
      EXECUTE IMMEDIATE stmt;
      EXCEPTION
            WHEN OTHERS THEN
              EXECUTE IMMEDIATE 'ALTER SYSTEM SWITCH LOGFILE';
              EXECUTE IMMEDIATE 'ALTER SYSTEM CHECKPOINT';
              EXECUTE IMMEDIATE stmt;
              END;
           END IF;
        END LOOP;
        END;
        /
	exit
       EOL1
    EOH2
  end



# create Listener.ora
file "#{node['oracle']['oracle_home']}/network/admin/listener.ora" do
  owner 'oracle'
  group 'oinstall'
  content "LISTENER = (DESCRIPTION_LIST = (DESCRIPTION =(ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC#{node['oracle']['port']})) (ADDRESS = (PROTOCOL = TCP)(HOST = #{Chef::Config[:node_name]})(PORT = #{node['oracle']['port']}))))   \nADR_BASE_LISTENER = #{node['oracle']['oracle_base']}"
  mode '0644'
  not_if { ::File.exists?("#{node['oracle']['oracle_home']}/network/admin/listener.ora")}
end

# Start Listener
execute "Start Listener" do
  command "./lsnrctl start LISTENER"
  user node['oracle']['user']
  group node['oracle']['group']
  cwd "#{node['oracle']['oracle_home']}/bin"
  action :run
end




