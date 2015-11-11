#Start NodeManager and WLS Servers.
def getParms():
    print('Loading properties...')
    loadProperties('domain.properties')    

#def start_NM():
#    nodemanagerhomelocation=wlsHome +'/common/nodemanager'
#    print('Starting Node Manager')
#    print(nodemanagerhomelocation)
#    print(hostName)
#    try:
#       startNodeManager(verbose='true', NodeManagerHome=nodemanagerhomelocation)
#       print('Starting Node Manager done')
#    except:
#       dumpstack()


def start_AdminServer():
    print('Connect to NM')
    counter = 1
    try:
       nmConnect(adminUser, adminPassword, hostName, 5556, domainName, domainHome+domainName, 'ssl')
       print('Starting Admin Server')
       nmStart(adminServerName)
       nmServerStatus(adminServerName)
    except:
       counter = counter + 1
       if counter > 4:
         print('waited for 2 minutes. Check the node manager logs')
       else:
        print('Node Manager is not ready yet. Sleeping for 30 seconds')
        java.lang.Thread.sleep(30000)
        start_AdminServer()


def start_ManagedServer():
    print('Connect to Admin')
    TURL='t3://'+hostName+':'+adminListenPort
    print(TURL)
    connect(adminUser, adminPassword, 't3://'+hostName+':'+adminListenPort)
    start(managedServerName ,'Server')

def main():
    try:
       getParms()
#       start_NM()
       start_AdminServer()
       start_ManagedServer()
    except:
       dumpstack()
main()