custom-ssh-banner Cookbook
==========================
This cookbook creates a /etc/custom-ssh-banner file with the following message:
```
	This banner was brought to you by Chef using custom-ssh-banner.
```
It also creates a /etc/profile.d/custom-ssh-banner.sh to print the above message on login.

Testing
-------
After applying your role to your node, ssh to it and verify the login message.

Before applying this cookbook:
```bash
ssh opc@your.ccs.node
Authorized uses only. All activity may be monitored and reported.
-bash-4.1$
```

After applying this cookbook:
```bash
ssh opc@your.ccs.node
Authorized uses only. All activity may be monitored and reported.
This banner was brought to you by Chef using custom-ssh-banner.
-bash-4.1$
```

License and Authors
-------------------
Copyright 2015 Oracle and/or its affiliates. 
 
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
 
    http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

