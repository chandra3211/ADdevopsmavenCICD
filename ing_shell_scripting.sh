==============================================================================================================================


#!/bin/bash

LINUXACCOUNT="$1"
STATUSLINUXACCOUNT=`pam_tally2 --user="$LINUXACCOUNT"`
e=$(which echo)

logged=`who | grep $LINUXACCOUNT |wc -l`
if [ $logged -ge 3 ]; then
                ${e} -e "$LINUXACCOUNT account has three or over logins| $LINUXACCOUNT has three or over logins"
                exit 1
fi

if [ "$(pam_tally2 --user="$LINUXACCOUNT" |awk 'NR>1'| awk '{print $2}'|bc)" -lt 3 ]; then
 ${e} "$LINUXACCOUNT account is OK  | $LINUXACCOUNT account is OK "
 exit 0
elif [  "$(pam_tally2 --user="$LINUXACCOUNT" |awk 'NR>1'| awk '{print $2}'|bc)" -gt 2 ]; then
 ${e} -e "$LINUXACCOUNT account is locked (3 or over bad logins) | $LINUXACCOUNT account is locked.\nUse pam_tally2 --user=$LINUXACCOUNT --reset to un
lock account.\n$STATUSLINUXACCOUNT"
 exit 1
else
 ${e} "Script problem or no Linux account | Error in the script or no Linux account"
 exit 2
fi


=================================================================================================================================

SSL cert creation:
https://tfs/tfs/ING%20Direct/ING%20Incubator/_git/ob-client-cert?path=%2Fopenssl%2Fsan.cnf&version=GBmaster

for vm in biabjava11msa01 biabansible01 biabb2bapigw01 biabcfapi01 biabztdgw01 biabdgwdoc01 biabdocker01 biabfapi01 biabpingacs01 biabpingfed01 biabssm01
do
    echo "*** VM Name: $vm ***"
    ssh -q $vm grep ^jdk.tls.disabledAlgorithms -A 4 -B 2 /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.292.b10-1.el7_9.x86_64/jre/lib/security/java.security
    printf "\n"
done 

=====================================================================================================================================================


#!/bin/bash

echo "please enter ipaddress"
read ipaddress

ssh $ipaddress

scp LFKey.keystore testadmin@$ipaddress:/tmp

# stop jbossas stop

service jbossas stop

#Moving to desired location

sudo cd /opt/jboss/

#Rename the old keystore location
sudo mv LFKey.keystore LFKey.keystore_old

#Copy the new keystore file
sudo cp /tmp/LFKey.keystore /opt/jboss

#Change the ownership
sudo chown jboss:jboss LFKey.keystore

#Restart jboss service
service jbossas restart

===================================================================================================================================================


this script to execute to check total 81 bancs is up and running or nor:

#!/bin/bash
aactive=$(su - fnsonlpd -c "whatsup" | tail -1  | awk -F " " '{print $3}')
if [ $aactive != 81 ]; then
        /usr/local/sbin/bancs_kill.sh
        /usr/local/sbin/bancs_startup.sh
else
        echo "All Good"
        exit 0
fi


===================================================================================================================================================
#!/bin/bash

# declare list of micro services
declare -a micro_services=(     "riskshield-transaction-producer"
                                "bancs-connector"
                                "address"
                                "captcha"
                                "home-loans"
                                "password-means"
                                "smsotp-means"
                                "token"
                                "cddservice"
                                "means-management"
                                "transaction-producer"
                                "loanapplications"
                                "brokers"
                                "isolatedlogin"
                                )

# declare list of valid operations
declare -a valid_ope=(  "status"
                        "stop"
                        "start"
                        "restart")

# default operation
ope="status"

if [ $# -ne 1 ]; then
        echo $'Usage: sh msa.sh [ope]\nValid operations are status, stop, start, restart\n'
        exit 1
else
        ope=$1
fi

if [[ ! "${valid_ope[@]}" =~ "${ope} " ]]; then
        echo $'Usage: sh msa.sh [ope]\nValid operations are status, stop, start, restart\n'
        exit 1
fi

for item in ${micro_services[*]}
do
        cmd="sudo /bin/systemctl $ope $item.service"
        $cmd
done

===================================================================================================================================================

#kill selenium and chrome processes
Get-Process | ? {$_.Name -eq "Chrome" -or $_.Name -like "*chromedriver*"} | Stop-Process -Force

==================================================================================================================================================
#TBD: As part of pipeline repo will be downloaded

MSA_PATH="MSA_repo/certs/biab/"
now_epoch=$( date +%s )
Allcerts=$(find $MSA_PATH -name "*.jks")
IFS=$'\n'

for JKS in $Allcerts
do
  echo " Certificate $JKS "
  Cert_UNTIL=$(keytool -v -list -keystore $JKS -storepass password |grep "until:" 2>/dev/null | sed 's/.*until: //')

  for line in $Cert_UNTIL
  do
    expiry_date=$line
    expiry_epoch=$( date -d "$expiry_date" +%s )
    expiry_days="$(( ($expiry_epoch - $now_epoch) / (3600 * 24) ))"
    echo " Days left: $expiry_days days"
    if [ $expiry_days -lt 30 ]
    then
                #TBD : Action on renew

        echo " $JKS Certificate expires in $expiry_days days"
    fi
  done
done

===================================================================================================================================================


$version = (Get-Item (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe').'(Default)').VersionInfo.FileVersion
$Source = "\\nrtfsnas.au.ingdirect.intranet\tfsbuildoutput\Devops\Chrome\"
$Folder = "Chrome_For_Digital"
$Destination = "C:\temp\"
$msi = "googlechromestandaloneenterprise.msi"
$dversion = "98.0.4758.80"
$update = "C:\Program Files (x86)\Google"

if ($version -eq $null) {

   write-host("Installing chrome")

   Write-Output "Create a folder under Temp Directory"
   New-Item -ItemType directory -Path $Destination\$Folder 
   Write-Output "Copy Chrome to Temp Directory"  
   Copy-Item -Path $source\*.* -Destination $Destination\$Folder 
   Write-Output "Installing msi for Chrome"
   Start-Process $Destination\$Folder\$msi -ArgumentList "/quiet"
   Start-Sleep -Seconds 30
   Remove-Item $Destination\$Folder -Recurse
   Remove-Item $update\Update_change -Recurse
   Rename-Item $update\Update  -NewName "Update_change"

} elseif ($version -ne $dversion  ) {
 
   write-host("Uninstalling chrome")

   $version = (Get-Item (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe').'(Default)').VersionInfo.FileVersion
   $app = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -match "Google Chrome"} ; $app.Uninstall()
   Start-Sleep -Seconds 2

   write-host("Installing chrome")
   Write-Output "Create a folder under Temp Directory"
   New-Item -ItemType directory -Path $Destination\$Folder 
   Write-Output "Copy Chrome to Temp Directory"  
   Copy-Item -Path $source\*.* -Destination $Destination\$Folder 
   Write-Output "Installing msi for Chrome"
   Start-Process $Destination\$Folder\$msi -ArgumentList "/quiet"
   Start-Sleep -Seconds 30
   Remove-Item $Destination\$Folder -Recurse
   Remove-Item $update\Update_change -Recurse
   Rename-Item $update\Update  -NewName "Update_change"
    
} else {

   write-host("Chrome already installed")
}
===================================================================================================================================================

#!/bin/bash

echo "############!!!!!! checking javamock server status !!!!!!############"
value=`docker inspect javamockserver | grep running`
code=`echo $?`
if [ $code != 0 ]; then
echo "Looks like javamocker server is down"
                echo "############ Stopping Container ############"
                sh /home/testadmin/jmoksvc/stopContainer.sh javamockserver
                echo "############ Running script to Bring up the container ############"
                sudo docker run -d -p 9127:9127 -h jmoksvc --name javamockserver -v /opt/javamockserver/:/opt/javamockserver:rw -i --expose=9127 docker.artifactory.au.ingdirect.intranet/ing/jmocksvc /usr/bin/bash -c /opt/javamockserver/javamockserver-docker-run.sh
                value=`docker inspect javamockserver | grep running`
                code=`echo $?`
                        if [ $code != 0 ]; then
                                echo "############ Still javamocker server is down, please bring up manually ############"
                        fi
else
        echo "java mock server is up"
fi
    echo "############!!!!!! checking bancsapi server status !!!!!!############"
value=`docker inspect bancsapi  | grep running`
code=`echo $?`
if [ $code != 0 ]; then
    echo "Looks like bancsapi server is down"
else
    echo "bancsapi server is up"
fi
    echo "############!!!!!! checking mockcuscal server status !!!!!!############"
value=`docker inspect mockcuscal  | grep running`
code=`echo $?`
if [ $code != 0 ]; then
    echo "Looks like mockcuscal server is down"
else
    echo "mockcuscal server is up"
fi
    echo "############!!!!!! checking mockserver server status !!!!!!############"
value=`docker inspect mockserver  | grep running`
code=`echo $?`
if [ $code != 0 ]; then
    echo "Looks like mockserver server is down"
else
    echo "mockserver server is up"
fi
echo "############!!!!!! checking filterpolicy server status !!!!!!############"
value=`docker inspect filterpolicy | grep running`
code=`echo $?`
if [ $code != 0 ]; then
    echo "Looks like filterpolicy server is down"
else
    echo "filterpolicy server is up"
fi
echo "############!!!!!! checking ingnginx server status !!!!!!############"
value=`docker inspect ingnginx | grep running`
code=`echo $?`
if [ $code != 0 ]; then
    echo "Looks like ingnginx server is down"
else
    echo "ingnginx server is up"
fi
echo "############!!!!!! checking docup_api server status !!!!!!############"
value=`docker inspect docup_api | grep running`
code=`echo $?`
if [ $code != 0 ]; then
    echo "Looks like docup_api server is down"
else
    echo "docup_api server is up"
fi

=================================================================================================================================================
python script to import json file:
import json
f = open('2test.json', "r")
data = json.loads(f.read())
for i in data["value"]:
    print(i["name"])
f.close()

=============================================================================================================================================
==============================================================================================================================================

#!/bin/bash
aactive=$(su - fnsonlpd -c "whatsup" | tail -1  | awk -F " " '{print $3}')
if [ $aactive != 81 ]; then
        echo "Starting the bancs killing..."
        /usr/local/sbin/bancs_kill.sh
        echo "Kill completed.....bancs are going to start...."
        /usr/local/sbin/bancs_startup.sh
        echo "startup completed"
else
        echo "All Good"
        echo "Bancs is up and  81 replicals active state"
        exit 0
fi

===============================================================================================================================================


