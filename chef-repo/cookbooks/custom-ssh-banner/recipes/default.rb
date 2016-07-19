# coding: utf-8
#
# Cookbook Name:: custom-ssh-banner
# Recipe:: default
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
log "Starting custom-ssh-banner recipe..."

software_repo = "https://#{URI(Chef::Config[:chef_server_url]).host}:#{URI(Chef::Config[:chef_server_url]).port}/files"

remote_file '/etc/custom-ssh-banner' do
  source "#{software_repo}/custom-ssh-banner.txt"
end

remote_file '/etc/profile.d/custom-ssh-banner.sh' do
  mode '0755'
  source "#{software_repo}/custom-ssh-banner.sh"
end
