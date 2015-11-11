# My Oracle Support Specific Parameters - mandatory
default['oracle']['csi'] = 'Customer_CSI' # Update with your CSI 
default['oracle']['email']  = 'Customer_Email' # Update with your email address

# Default Environment Parameters
default['oracle']['user']                                   			= 'oracle'
default['oracle']['group']                                  			= 'oinstall'
default['oracle']['ora_inventory']						= '/u01/app/oraInventory'
default['oracle']['oraInst']							= '/etc/oraInst.loc'
default['oracle']['oracle_base']						= '/u01/app/oracle'
default['oracle']['oracle_home_edition']					= 'EE'
default['oracle']['dba_group']                                                      = 'dba'
default['oracle']['oper_group']                                                     = 'dba'
default['oracle']['backupdba_group']                                                = 'dba'
default['oracle']['dgdba_group']                                                    = 'dba'
default['oracle']['kmdba_group']                                                    = 'dba'


# Source Binaries Parameters
default['oracle']['installers']                        				= '/u01/installers'
default['oracle']['stage']                            				= '/u01/stage'
default['oracle']['db_installer_zip']						= 'B24792-01_1of5.zip'
default['oracle']['patch_installer_zip']					= 'V21262-01.zip'
default['oracle']['patch_installer_inner_zip']					= 'p8202632_10205_Linux-x86-64.zip'
default['oracle']['opatch_installer_zip']					= 'p6880880_102000_Linux-x86-64.zip'
default['oracle']['psu_installer_zip']						= 'p16619894_10205_Linux-x86-64.zip'
default['oracle']['psu_patch_number']						= '16619894'


#10gR2 specific 
default['oracle']['oracle_home']                                                = "#{default['oracle']['oracle_base']}/product/10.2.0/dbhome_1"
default['oracle']['oracle_home_name']                                           = 'OraDb10g_home1'


#11gR2 specifc
default['oracle']['db_installer_zip_11g']                                        = ['p13390677_112040_Linux-x86-64_1of7.zip','p13390677_112040_Linux-x86-64_2of7.zip']
default['oracle']['opatch_installer_zip_11g']                                       = 'p6880880_112000_Linux-x86-64.zip'
default['oracle']['psu_installer_zip_11g']                                     = ['p20299013_112040_Linux-x86-64.zip','p20406239_112040_Linux-x86-64.zip']
default['oracle']['psu_base_patch_number_11g']                                      = '20834538'
default['oracle']['psu_patch_number_11g']                                           = ['20299013','20406239']
default['oracle']['oracle_home_11g']                                                = "#{default['oracle']['oracle_base']}/product/11.2.0/dbhome_1"



#12cR1 specific
default['oracle']['db_installer_zip_12c']                                        = ['p17694377_121020_Linux-x86-64_1of8.zip','p17694377_121020_Linux-x86-64_2of8.zip']
default['oracle']['opatch_installer_zip_12c']                                       = 'p6880880_121010_Linux-x86-64.zip'
default['oracle']['psu_installer_zip_12c']                                     = ['p20834538_121020_Linux-x86-64.zip']
default['oracle']['psu_base_patch_number_12c']                                      = '20834538'
default['oracle']['psu_patch_number_12c']                                           = ['20299023','20299022','20415564']
default['oracle']['oracle_home_12c']                                                = "#{default['oracle']['oracle_base']}/product/12.1.0/dbhome_1"


# Database Parameters
default['oracle']['templateName']						= 'General_Purpose.dbc'
default['oracle']['gdbname']							= 'orcl'
default['oracle']['sid']							= 'orcl'
default['oracle']['characterSet']						= 'AL32UTF8'
default['oracle']['memoryPercentage']						= '50'
default['oracle']['emConfiguration']						= 'NONE'
default['oracle']['datafileDestination']					= '/u02/app/oracle/oradata'
default['oracle']['recoveryAreaDestination']					= '/u03/app/oracle/fast_recovery_area'
default['oracle']['redoLogDestination']						= '/u04/app/oracle/redo'
default['oracle']['port']							= '1521'
default['oracle']['sys_passwd']                                         	= 'Welcome1'
default['oracle']['system_passwd']                                              = 'Welcome1'
