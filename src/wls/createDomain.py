import sys
import traceback
import os
import java

def printIndent(txt):
  print '-'*10+txt

def getParms():
    print('Loading properties...')
    loadProperties('domain.properties')    
    
def setSystemUser():
    cd('/')
    sysUser = cd('/Security/%s/User/weblogic' % domainName)
    sysUser.setName(adminUser)
    sysUser.setPassword(adminPassword)
    #print('Set system user complete')

def configureAdminServer():
    cd('Servers/AdminServer')
    set('ListenAddress', '')
    set('ListenPort', int(adminListenPort))
    create(adminServerName, 'SSL')
    cd('SSL/'+adminServerName)
    set('Enabled', 'false')
    #print('Admin Server complete')

def createManagedServer():
    cd('/')
    create(managedServerName, 'Server')
    cd('Server/' + managedServerName)
    set('ListenPort', int(managedListenPort))
    set('ListenAddress', '')
    set('Machine', hostName)
    #print('Managed Server complete')
	

def createCluster():
    cd('/')
    create(clusterName, 'Cluster')
    assign('Server', managedServerName,'Cluster',clusterName)
    cd('/')
    cd('Cluster/' + clusterName)
    set('ClusterMessagingMode','unicast')   
    #print('Cluster complete')

def createMachine():
    cd('/')
    create(hostName,'Machine')
    cd('Machine/'+hostName)
    create(hostName,'NodeManager')
    cd('NodeManager/'+hostName)
    set('ListenPort',5556)
    #print('Nodemanager complete')
	
	
def configureJDBC():
    cd('/')
    create(dbdatasource, 'JDBCSystemResource')
    cd('JDBCSystemResource/'+dbdatasource+'/JdbcResource/'+dbdatasource+'')
    create('myJdbcDriverParams','JDBCDriverParams')
    cd('JDBCDriverParams/NO_NAME_0')
    set('DriverName',dbdriver)
    set('URL',URL)
    set('PasswordEncrypted', dbpassword)
    create('myProps','Properties')
    cd('Properties/NO_NAME_0')
    create('user', 'Property')
    cd('Property/user')
    cmo.setValue(dbusername)
    cd('/JDBCSystemResource/'+dbdatasource+'/JdbcResource/'+dbdatasource+'')
    create('myJdbcDataSourceParams','JDBCDataSourceParams')
    cd('JDBCDataSourceParams/NO_NAME_0')
    set('JNDIName', dbdatasource+'_jndi')
    cd('/JDBCSystemResource/'+dbdatasource+'/JdbcResource/'+dbdatasource+'')
    create('myJdbcConnectionPoolParams','JDBCConnectionPoolParams')
    cd('JDBCConnectionPoolParams/NO_NAME_0')
    set('TestTableName','SQL SELECT 1 FROM DUAL')
    set('TestConnectionsOnReserve', true)
    # Remove assigning the target as the server will fail to start if the db data is incorrect
    #assign('JDBCSystemResource', dbdatasource, 'Target', clusterName+','+adminServerName) 
    #print('JDBC complete')

def main():
    try:
       printIndent('Begin domain creation...')
       getParms()
       printIndent('Reading template...') 
       readTemplate(wlsTemplate)
       domain = create(domainName, 'Domain')
       setOption('OverwriteDomain', 'true')
    
       printIndent('Setting values...')
       setSystemUser()
       configureAdminServer()	    
 
       printIndent('Creating NodeManager...')
       createMachine()
	   
       printIndent('creating Managed Server')
       createManagedServer()

       printIndent('creating cluster')
       createCluster()

       printIndent('creating JDBC')
       configureJDBC()

       printIndent('Writing domain '+domainName+'...')
       writeDomain(domainHome+domainName)

       printIndent('Closing template...')
       closeTemplate()
       printIndent('Complete...')
    except:
       dumpstack()


main()