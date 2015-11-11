#!/usr/bin/env python
################################################################################
## Copyright 2015 Oracle and/or its affiliates. 
## 
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
## 
##     http://www.apache.org/licenses/LICENSE-2.0
## 
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
################################################################################
import sys
import logging
import os
import shlex
import subprocess
import hashlib
import getopt
import getpass

SCRIPT_NAME   = 'oracle-ccs-deploy-chef.py'
VERSION       = '1.0.0.1                                '
RELEASE_DATE  = '04-Jun-2015                            '
# Configure logger
log = logging.getLogger('')
log.setLevel(logging.DEBUG)
logFormatter = logging.Formatter('[%(asctime)s] %(levelname)s: %(message)s')

flog = logging.FileHandler("." + SCRIPT_NAME[:-3] + ".log")
flog.setLevel(logging.DEBUG)
flog.setFormatter(logFormatter)
log.addHandler(flog)

clog = logging.StreamHandler()
clog.setLevel(logging.INFO)
clog.setFormatter(logFormatter)
log.addHandler(clog)

#
# Package list
PACKAGE_LIST = ["chef-server-core-12.0.8-1.el6.x86_64.rpm,https://web-dl.packagecloud.io/chef/stable/packages/el/6/chef-server-core-12.0.8-1.el6.x86_64.rpm,828b4f87763b93063028c41f88c72d20f22bb2c1",
                "chef-12.3.0-1.el6.x86_64.rpm,https://opscode-omnibus-packages.s3.amazonaws.com/el/6/x86_64/chef-12.3.0-1.el6.x86_64.rpm,b92e7b8a61ad17909b554cc120680f73d186e96f",
                ]
#
# Chef Server defaults
USERNAME="admin"
EMAIL="no-replies@oracle.com"
ORG="ccs-demo"
ORGNAME="Oracle Compute Cloud Services Demo"

#
# Usage
def usage():
    print ('Usage: ')
    print ('./' + SCRIPT_NAME)
    print ('')
    print ('Optional Parameters')
    print ('        --username            : Defines the Chef Server administrator user. Defaults to '+ USERNAME +'.')
    print ('        --email               : Defines the Chef Server administrator user e-mail. Defaults to '+ EMAIL +'.')
    print ('        --org                 : Defines the Chef Server default organization. Defaults to '+ ORG +'.')
    print ('        --orgname             : Defines the Chef Server default organization description. Defaults to '+ ORGNAME +'.')
    print ('        --debug               : Prints debug output during execution.')
    print ('        --version             : Prints script version information.')

#
# Run command
def runCommand(command):
#    log.debug('runCommand() called with arguments: cmd: '+  command)
    cmd = shlex.split(command)
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True)
    stdout, stderr = p.communicate()
    out = stdout.splitlines()
    err = stderr.splitlines()
    log.debug('STDOUT: '+ '\n'.join(out))
    log.debug('STDERR: '+ '\n'.join(err))
    return p.returncode, out, err

#
# Download files
def downloadFile(filename, url, sha1):
    log.debug('downloadFile() called with arguments: filename: ' + filename +', url: ' + url)
    rc, out, err = runCommand('curl -L --silent --connect-timeout 2 --output /tmp/'+ filename +' --write-out "%{http_code}" '+ url)
    if rc != 0 or out[0] != '200':
        log.error('Failed to download '+ url)
        log.error('HTTP code: '+ out[0] +', Return code: '+ str(rc))
        sys.exit(0)
#
# Install RPM
def installRPM(rpm_string):
    rpm, url, sha1 = rpm_string.split(',')
    log.debug('Checking if '+ rpm[:-4] +' is installed.')
    rc, out, err = runCommand('yum list --disablerepo=* '+ rpm[:-4])
    if rc == 0:
        log.error('   '+ rpm[:-3] +' already installed. Aborting...')
        sys.exit(1)
    else:
        log.info('   Installing '+ rpm +'...')
        if not os.path.isfile('/tmp/'+ rpm +''):
            log.info('     local RPM not found on /tmp. Downloading it (be patient)...')
            downloadFile(rpm, url, sha1)
        hasher = hashlib.sha1()
        bin_file = open('/tmp/'+ rpm, 'r')
        while True:
            data = bin_file.read(4096)
            if not data:
                break
            hasher.update(data)
        filesha1 = hasher.hexdigest()
        if sha1 != filesha1:
            log.debug('Expected '+ sha1 +', calculated '+ filesha1)
            log.error('Failed to check SHA1. Please remove the /tmp/'+ rpm +' and try again')
            sys.exit(0)
        rc, out, err = runCommand('sudo yum localinstall -y --disablerepo=* /tmp/'+ rpm)
        if rc != 0:
            log.error('Chef Server installation FAILED!')
            log.error("\n".join(out))
            sys.exit(1)
        log.info('    '+ rpm +' done.')

#
# Main
def main(argv):
    log.info('Running '+ SCRIPT_NAME +' version '+ VERSION)
    global USERNAME
    global PASSWORD
    global EMAIL
    global ORG
    global ORGNAME
    # Handle arguments from command line
    options = 'u:p:e:o:n:dv'
    longOptions = ['username=','password=','email=','org=','orgname=','debug', 'version']
    try:
        opts, args = getopt.getopt(argv, options, longOptions)
    except getopt.GetoptError:
        usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt == '--username' or opt == '-u':
            USERNAME = arg
        elif opt == '--email' or opt == '-e':
            EMAIL = arg            
        elif opt == '--org' or opt == '-o':
            ORG = arg            
        elif opt == '--orgname' or opt == '-n':
            ORGNAME = arg            
        elif opt == '--version' or opt == '-v':
            print(VERSION)
            sys.exit()
        elif opt == '--debug' or opt == '-d':
            clog.setLevel(logging.DEBUG)
    if sys.stdin.isatty():
        PASSWORD   = getpass.getpass("Chef administrator user (" + USERNAME + ") password: ")
        if len(PASSWORD) < 6 :
            log.error('Password must have at least 6 characters! Aborting...')
            sys.exit(1)
        REPASSWORD = getpass.getpass("Re-enter password: ")
        if PASSWORD != REPASSWORD:
            log.error("Password does not match! Aborting...")
            sys.exit(1)        
    else:
        PASSWORD = sys.stdin.readline().rstrip()
    log.debug('Options: '+ USERNAME +', '+ EMAIL +', '+ ORG +', '+ ORGNAME)
    # Installs RPMs from PACKAGE_LIST
    for rpm_string in PACKAGE_LIST:
        installRPM(rpm_string)
    # Configures Chef Server
    # TODO: allow changes to these values via args
    hostname = os.popen('hostname -f').read()[:-1]
    linux_user = os.popen('whoami').read()[:-1]
    log.info('   Configuring Chef Server. This will take a few minutes, please be patient...')
    rc, out, err = runCommand("sudo chef-server-ctl reconfigure")
    if rc != 0:
        log.error('chef-server reconfigure failed: '+ '\n'.join(err))
        log.error('Aborting...')
        sys.exit(1)
    rc, out, err = runCommand("mkdir -p /home/"+ linux_user +"/.chef/trusted_certs")
    if rc != 0:
        log.error('Unable to create /home/'+ linux_user +'/.chef/trusted_certs: '+ '\n'.join(err))
        log.error('Aborting...')
        sys.exit(1)
    log.info('    Chef Server configured!')
    log.info('   Setup Chef Server...')
    rc, out, err = runCommand("sudo chef-server-ctl user-create "+ USERNAME +" Organization Administrator "+ EMAIL +" "+ PASSWORD +" --filename /home/"+ linux_user +"/.chef/"+ USERNAME +".pem")
    if rc != 0:
        log.error('chef user-create failed: '+ '\n'.join(err))
        log.error('Aborting...')
        sys.exit(1)        
    rc, out, err = runCommand("sudo chef-server-ctl org-create "+ ORG +" "+ ORGNAME +" --association_user "+ USERNAME +" --filename /home/"+ linux_user +"/.chef/"+ ORG +"-validator.pem")
    if rc != 0:
        log.error('chef org-create failed: '+ '\n'.join(err))
        log.error('Aborting...')
        sys.exit(1)            
    rc, out, err = runCommand("sudo cp /var/opt/opscode/nginx/ca/"+ hostname +".crt /home/"+ linux_user +"/.chef/trusted_certs")
    if rc != 0:
        log.error('Unable to copy '+ hostname +'.crt: '+ '\n'.join(err))
        log.error('Aborting...')
        sys.exit(1)
    rc, out, err = runCommand("sudo chown -R "+ linux_user +" /home/"+ linux_user + "/.chef")
    if rc != 0:
        log.error('Unable to chown -R '+ linux_user +' /home/'+ linux_user + '/.chef: '+ '\n'.join(err))
        log.error('Aborting...')
        sys.exit(1)        
    # Configure knife
    config_file = "/home/"+ linux_user +"/.chef/knife.rb"
    config = open(config_file, 'w')
    config.write('current_dir = File.dirname(__FILE__)\n')
    config.write('log_level                :info\n')
    config.write('log_location             STDOUT\n')
    config.write('node_name                "'+ USERNAME +'"\n')
    config.write('client_key               "/home/'+ linux_user +'/.chef/'+ USERNAME +'.pem"\n')
    config.write('validation_client_name   "'+ ORG +'-validator"\n')
    config.write('validation_key           "/home/'+ linux_user +'/.chef/'+ ORG +'-validator.pem"\n')
    config.write('chef_server_url          "https://'+ hostname +'/organizations/' + ORG +'"\n')
    config.write('cookbook_path            "/home/'+ linux_user +'/chef-repo/cookbooks"\n')
    config.close()
    # Configure sofware repository
    config_file = "/tmp/nginx.conf"
    config = open(config_file, 'w')
    config.write('#\n')
    config.write('# Oracle Compute Cloud Demo Software Repository\n')
    config.write('#\n')
    config.write('')
    config.write('location /files {\n')
    config.write('        root /var/www;\n')
    config.write('        autoindex on;\n')
    config.write('}\n')
    config.close()
    rc, out, err = runCommand("sudo mv /tmp/nginx.conf /var/opt/opscode/nginx/etc/addon.d/50-software-repo_external.conf")
    rc, out, err = runCommand("sudo mkdir -p /var/www/files")
    rc, out, err = runCommand("sudo chmod 755 /var/www")
    rc, out, err = runCommand("sudo chmod 755 /var/www/files")
    # Create assets for sample cookbook
    config_file = "/tmp/custom-ssh-banner.txt"
    config = open(config_file, 'w')
    config.write('This banner was brought to you by Chef using custom-ssh-banner.\n')
    config.close()
    config_file = "/tmp/custom-ssh-banner.sh"
    config = open(config_file, 'w')
    config.write('cat /etc/custom-ssh-banner\n')
    config.close()
    runCommand("sudo mv /tmp/custom-ssh-banner.txt /var/www/files/custom-ssh-banner.txt")
    runCommand("sudo mv /tmp/custom-ssh-banner.sh  /var/www/files/custom-ssh-banner.sh")
    rc, out, err = runCommand("sudo chown -R "+ linux_user +" /var/www/files")
    rc, out, err = runCommand("sudo chmod 644 /var/www/files/custom-ssh-banner.txt /var/www/files/custom-ssh-banner.sh")
    rc, out, err = runCommand("sudo chef-server-ctl restart nginx")
    if rc != 0:
        log.error('Unable to restart nginx after setting up our software repository.')
        log.error('Aborting...')
        sys.exit(1)        
    log.info('    Chef Server setup done!')        
    log.info('Chef Server configuration finshed successfully!')
#
# Main function to kick off processing
if __name__ == '__main__':
        main(sys.argv[1:])
