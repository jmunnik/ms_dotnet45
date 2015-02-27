#
# Cookbook Name:: ms_dotnet45
# Recipe:: default
#
# Copyright 2012, Webtrends, Inc.
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

require 'chef/win32/version'
windows_version = Chef::ReservedNames::Win32::Version.new

if platform?('windows')
  if win_version.windows_server_2008? || win_version.windows_server_2008_r2? || win_version.windows_7? || win_version.windows_vista? || windows_version.windows_server_2012? || windows_version.windows_server_2012_r2?
     # Determine which release of .NET Framework has been installed (4.5, 4.5.1 or 4.5.2). Normally this can already been done via windows package but 
     # because 4.5 is embedded in windows 2012 R2 it's not in the Installed Programs.
     registry_path = registry_get_values('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full')
    
     dotnet_release = nil
     registry_path.each do | registry_key |
	if registry_key[:name] == 'Release'  
          dotnet_release = registry_key[:data]
        end
     end

	
    if "#{dotnet_release}" == "#{node['ms_dotnet45']['release']}"
       Chef::Log.info("Microsoft .NET Framework #{node['ms_dotnet45']['version']} is already installed")
     else 
      # Call windows_package and version as displayed in Installed Programs 
      windows_package "Microsoft .NET Framework #{node['ms_dotnet45']['version']}" do 
        source node['ms_dotnet45']['http_url']
        installer_type :custom
        options '/quiet /norestart'
        timeout node['ms_dotnet45']['timeout']
        # If a previous version of .NET Framework is installed (for example 4.0) an removal will take place. After installation of 4.5.x you will receive
        # ==> Mixlib::ShellOut::ShellCommandFailed. Expected process to exit with [0, 42, 127], but received '3010' which means; 
        # A reboot is required but not really necesarry, but it's maybe better to reboot
        success_codes [0, 3010]
      end
    end
  elsif win_version.windows_server_2003_r2? || win_version.windows_server_2003? || win_version.windows_xp?
    Chef::Log.warn("The .NET #{node['ms_dotnet45']['version']} Chef recipe only supports Windows Vista SP2, Windows 7 SP1, Windows 8, Windows 8.1, Windows Server 2008 SP2, Windows Server 2008 R2 SP1, Windows Server 2012 and Windows Server 2012 R2")
  end
else
   Chef::Log.warn("Microsoft .NET Framework #{node['ms_dotnet45']['version']} can only be installed on the Windows platform.")
end
