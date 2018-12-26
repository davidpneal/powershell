#12-25-2018
#This script is designed to be used in conjunction with the crypto FSRM file screens here: https://fsrm.experiant.ca/
#By default, it will lock out the user after 3 file violations in a minute, then unlock the account after 30 minutes
#If the user then triggers a lockout again within an hour, the script will not set an auto unlock

#Set FSRM to run this script when a file screen violation is triggered
#C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe with argument: C:\scripts\Add-CryptoBlock.ps1
#Set the file screen to log the event and run it as Local System

#Note, this script will add and remove deny ACE's on the share permissions; if your workflow uses share denies
#to restrict individual user access to a share, these might inadvertently get removed

#Get-WinEvent requires installing PowerShell 5 on Server 2008R2 machines


##Settings##
$to = "admin@company.com"
$from = "alert@company.com"
$smtpServer = "smtp.company.com"

$autoUnlockTime = 30



#Wait for 1 second so the log can be written
sleep -seconds 1
$logs = Get-WinEvent -FilterHashtable @{Logname='Application';ID=8215}

#Get the username; it is value 6 in the poperties of the log object
$username = ($logs | select -first 1).properties[6]

#Ignore SYSTEM; it tends to generate false positives with windows updates, plus blocking it from share permissions is pointless
###TEST THIS
if($username.value -eq 'NT AUTHORITY\SYSTEM'){
	exit
}

#Filter the log, retaining any entries in the past minute by the user
###TEST THIS - need integration testing
$time = (get-date).addminutes(-1)

$lastMin = foreach($log in $logs){
	$user = $log.properties[6]
	
	#Must match the user based on .value (to make them strings), comparing on the object level wont work
	if($user.value -eq $username.value -and $log.timecreated -gt $time){
		$log
	}
}




'@ ~algorithm~

If($lastMin > 3)
	Lockout the user
		#Block their share permissions - this adds a deny to the share perms but leaves NTFS alone
		Get-SmbShare | Where-Object currentusers -gt 0 | %{Block-SmbShareAccess -Name $_.name -AccountName $username -force}
	
	
	#$log.properties[0] = message with info on why the event was triggered; maybe copy this to email
	Set notification email subject to "user locked out"
		Body of the email: a list of the files that triggered the lockout
				
		
	$last60 = Count the events in the last 60 minutes
	If (unlocks in last 60m > 6)
		Add information to email notification indicating the user will not be auto unlocked
	Else
		Add a scheduled task to unlock the user after $autoUnlockTime minutes
	

@'



#Send a notification: 
$subject = "User locked out"

$message = "Time stamp: $($log.timegenerated)`n"
$message += "User: $($username)`n`n"
$message += 

Send-MailMessage -SmtpServer $smtpServer -from $from -to $to -subject $subject -body $message



----------------------------------------------------------------------


#Dec 18 - TEST this ~ still applies???
#FSRM must be restarted after being triggered - it wont run twice for some reason
restart-service "File Server Resource Manager" -force