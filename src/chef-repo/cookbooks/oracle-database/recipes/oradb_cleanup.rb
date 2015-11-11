#
# Cookbook Name:: oracle-database
# Recipe:: oradb_cleanup
#
# Copyright 2015 Oracle
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

# Cleanup temp files during install
bash "Cleanup temp files" do
  user node['oracle']['user']
  group node['oracle']['group']
  code <<-EOH
  cd "#{node['oracle']['stage']}"
  rm -rf *
  EOH
end
