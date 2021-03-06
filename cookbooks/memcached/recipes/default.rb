#
# Cookbook Name:: memcached
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
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

package "memcached" do
    action :upgrade
end

case node["platform_family"]
when "rhel"
    package "libmemcached-devel" do
        action :upgrade
        not_if { platform?("redhat") }
    end
when "debian"
    libmemcached = (platform?("debian") && node["platform_version"].to_i >= 8) ?
        "libmemcached-dev" :
        "libmemcache-dev"
    package libmemcached do
        action :upgrade
    end
end

service "memcached" do
    action :nothing
    supports :status => true, :start => true, :stop => true, :restart => true
end

case node["platform_family"]
when "rhel"
    memcached_conf = '/etc/sysconfig/memcached'
    memcached_conf_source = "memcached.sysconfig.erb"
when "debian"
    memcached_conf = "/etc/memcached.conf"
    memcached_conf_source = "memcached.conf.erb"
end

template memcached_conf do
    source memcached_conf_source
    owner 'root'
    group 'root'
    mode '0644'
    variables(
        :listen => node['memcached']['listen'],
        :user => node['memcached']['user'],
        :port => node['memcached']['port'],
        :memory => node['memcached']['memory'],
        :maxconn => node["memcached"]["maxconn"]
    )
    notifies :restart, 'service[memcached]'
end
