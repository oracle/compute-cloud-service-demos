#!/bin/bash

PS3='Please enter your choice for WebLogic version installation : '
options=("wls1030" "wls1032" "wls1033" "wls1034" "wls1035" "wls1036")
select opt in "${options[@]}"
do
    case $opt in
        "wls1030")
            echo "you chose choice wls10.3.0"
            install_version="wls1030"
            break
            ;;        
        "wls1032")
            echo "you chose choice wls10.3.2"
            install_version="wls1032"
            break
            ;;
        "wls1033")
            echo "you chose choice wls10.3.3"
            install_version="wls1033"
            break
            ;;
        "wls1034")
            echo "you chose choice wls10.3.4"
            install_version="wls1034"
            break
            ;;
        "wls1035")
            echo "you chose choice wls10.3.5"
            install_version="wls1035"
            break
            ;;
        "wls1036")
            echo "you chose choice wls10.3.6"
            install_version="wls1036"
            break
            ;;
        *) echo invalid option;;
    esac
done
echo $install_version

scripts=`pwd`
echo "scripts directories = $scripts"
# create directories
installers='/u01/installers'
#mkdir -p $installers
mw_home='/u01/mwhome'
mkdir -p $mw_home


cp silent.xml $installers
cp bsusilent.xml $installers

java_installer=jdk-6u45-linux-x64.bin
bsu_patch=p12426828_1035_Generic.zip

if [ $install_version = "wls1030" ]
	then
	wls_installer=server103_linux32.bin
	bsu_patch=p12426828_1035_Generic.zip
	unicast_patch=p13909516_103_Generic.zip
	patch_id=36AT
elif [ $install_version = "wls1032" ]
	then
	wls_installer=wls1032_generic.jar
	unicast_patch=p13262201_10320_Generic.zip
	patch_id=M2B1
elif [ $install_version = "wls1033" ]
	then
	wls_installer=wls1033_generic.jar
	unicast_patch=p13639449_1033_Generic.zip
	patch_id=PCTX	
elif [ $install_version = "wls1034" ]
	then
	wls_installer=wls1034_generic.jar
	unicast_patch=p12822180_1034_Generic.zip
	patch_id=FBWE
elif [ $install_version = "wls1035" ]
	then
	wls_installer=wls1035_generic.jar
	unicast_patch=p12822180_1035_Generic.zip
	patch_id=BG1A
elif [ $install_version = "wls1036" ]
	then
	wls_installer=wls1036_generic.jar
	unicast_patch=p12822180_1036_Generic.zip
	patch_id=YJI2
fi



# Install WLS
if [ $install_version = "wls1030" ]
	then
		cd $installers
		if [ -f $wls_installer ];
		then
			chmod +x $wls_installer
			./$wls_installer -mode=silent -silent_xml=silent.xml
			JAVA_HOME=$mw_home/jdk160_05
		else
			echo "$wls_installer not found"
		exit
	fi		
else
	# Install java
	cd $installers
	# check for java installer and install if present
	if [ -f $java_installer ];
	then
	   echo "Installer File $java_installer exists."
           chmod +x $java_installer
	   sh $java_installer
          # mkdir -p $mw_home
	   mv jdk1.6.0_45 $mw_home
	else
	   echo "Installer File $java_installer does not exist please copy $java_installer to $installers and re-run the script."
	   exit
	fi

	# Install WLS
	if [ -f $wls_installer ];
		then
			JAVA_HOME=$mw_home/jdk1.6.0_45
			$JAVA_HOME/bin/java -jar $wls_installer -mode=silent -silent_xml=silent.xml
		else
			echo "$wls_installer not found"
		exit

	fi
fi	


# Install bsu patch
if [ -f $installers/$bsu_patch ];
	then
		cd $installers
		unzip p12426828_1035_Generic.zip
		$JAVA_HOME/bin/java -jar patch-client-installer330_generic32.jar -mode=silent -silent_xml=bsusilent.xml
		rm README.txt
		rm patch-client-installer330_generic32.jar
		# Install Unicast ordering patch
		
		if [ -f $installers/$unicast_patch ];
			then
				cd $mw_home/utils/bsu
				mkdir cache_dir
				unzip $installers/$unicast_patch -d $mw_home/utils/bsu/cache_dir
				./bsu.sh -install -patchlist=$patch_id -prod_dir=$mw_home/wlserver_10.3
		fi	
	else
		echo "bsu patch is not present. Will not upgrade bsu or install unicast patch. Please install these patches manually"
fi

# set urandom so that the server start fast
cp $mw_home/wlserver_10.3/common/bin/commEnv.sh $mw_home/wlserver_10.3/common/bin/commEnv.sh.orig
sed '/export\sJAVA_VM\sMEM_ARGS\sJAVA_OPTIONS/a export JAVA_OPTIONS=\"${JAVA_OPTIONS} -Djava.security.egd=file:/dev/./urandom\"' $mw_home/wlserver_10.3/common/bin/commEnv.sh.orig >$mw_home/wlserver_10.3/common/bin/commEnv.sh 

cd $scripts

# create domain
$mw_home/wlserver_10.3/common/bin/wlst.sh createDomain.py


# change config to include unicast fix
if [ -f $installers/$bsu_patch ] && [ -f $installers/$unicast_patch ];
	then
		cp $mw_home/user_projects/domains/clouddemodomain/config/config.xml $mw_home/user_projects/domains/clouddemodomain/config/config.xml.orig
		sed '/unicast/a  <message-ordering-enabled>true</message-ordering-enabled>' $mw_home/user_projects/domains/clouddemodomain/config/config.xml.orig > $mw_home/user_projects/domains/clouddemodomain/config/config.xml
fi		

#create nodemanager.properties
echo "DomainsFile=$mw_home/wlserver_10.3/common/nodemanager/nodemanager.domains" > $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties 
echo "LogLimit=0" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties 
echo "PropertiesVersion=10.3" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties 
echo "javaHome=$mw_home/jrockit_160_05" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties 
echo "AuthenticationEnabled=true" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties 
echo "NodeManagerHome=$mw_home/wlserver_10.3/common/nodemanager" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties 
echo "JavaHome=$JAVA_HOME" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties
echo "LogLevel=INFO" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties
echo "DomainsFileEnabled=true" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties
echo "StartScriptName=startWebLogic.sh" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties
echo "ListenAddress=" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties
echo "NativeVersionEnabled=true" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties
echo "ListenPort=5556" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties
echo "LogToStderr=true" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties
echo "SecureListener=true" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties
echo "LogCount=1" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties
echo "StopScriptEnabled=true" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties
echo "QuitEnabled=false" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties
echo "LogAppend=true" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties
echo "StateCheckInterval=500" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties
echo "CrashRecoveryEnabled=false" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties
echo "StartScriptEnabled=true" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties
echo "LogFile=$mw_home/wlserver_10.3/common/nodemanager/nodemanager.log" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties
echo "LogFormatter=weblogic.nodemanager.server.LogFormatter" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties
echo "ListenBacklog=50" >>  $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties


# start Node Manager
nohup $mw_home/wlserver_10.3/server/bin/startNodeManager.sh 2>&1 > $mw_home/user_projects/domains/clouddemodomain/nodemanager.log &

# change  nodemanager.properties file
#cp $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties.orig
#sed 's/^\(StartScriptEnabled=\).*/\1true/; s/^\(StopScriptEnabled=\).*/\1true/' $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties.orig > $mw_home/wlserver_10.3/common/nodemanager/nodemanager.properties

# start WLS Servers
$mw_home/wlserver_10.3/common/bin/wlst.sh startNM_WLS.py

