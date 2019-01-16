#1/16/2019
#This script is designed to be used in conjunction with the crypto FSRM file screens here: https://fsrm.experiant.ca/
#Install the screens and set FSRM to log the event

#For some reason, FSRM wont run the script again if triggered soon after the first incident
#To work around this, set the script to run as scheduled task that triggers on an event 
#Application log, SRMSVC, event 8215 and run the script:
#C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe with argument: C:\scripts\CryptoBlocker.ps1
#Note that to send emails, the script cant be run as SYSTEM

#Note, this script will add and remove deny ACE's on the share permissions; if your workflow uses share denies
#to restrict individual user access to a share, these might inadvertently get removed

#Get-WinEvent requires installing PowerShell 5 on Server 2008R2 machines
#Also note that the log scraping is based on the default FSRM message being used



##Settings##
$warningNotification = "admin@company.com"
$lockoutNotification = "it@company.com"
$from = "alert@company.com"
$smtpServer = "smtp.company.com"

#Default lockout parameters: lock out the user after 3 ($numEvents) file violations in 1 minute ($numMinutes)
$numEvents = 3
$numMinutes = 1



#Wait for 1 second so the log can be written
sleep -seconds 1
$logs = Get-WinEvent -FilterHashtable @{Logname='Application';ID=8215}

#Get the username; it is value 6 in the properties of the log object
$username = ($logs | select -first 1).properties[6].value

#Ignore SYSTEM; it tends to generate false positives with windows updates, plus blocking it from share permissions is pointless
if($username -eq 'NT AUTHORITY\SYSTEM'){
	exit
}


#Filter the log, retaining any entries in the past $numMinutes by the user
$time = (get-date).addminutes(-$numMinutes)

$lastMin = foreach($log in $logs){
	$user = $log.properties[6]
	
	#Match entries in the past $numMinutes that were caused by $username
	if($user.value -eq $username -and $log.timecreated -gt $time){
		$log
	}
}


$hostname = hostname
$timestamp = ($logs | select -first 1).timecreated

if(($lastMin | measure).count -gt $numEvents) {
	#Block the user's share permissions - this adds a deny to the share perms but leaves NTFS alone
	#This is done for speed and so every child's permissions dont need to be changed
	Get-SmbShare | Where-Object currentusers -gt 0 | foreach-object{
		Block-SmbShareAccess -Name $_.name -AccountName $username -force
	}
	
	$to = $lockoutNotification
	$subject = "$hostname CryptoLocker protection: $($username) has been locked out"
	
	$message = "Event time stamp: $timestamp`n"
	$message += "User: $($username)`n`n"
	$message += "These files matched the suspect extensions that triggered the lockout:`n"	
	
	#Generate a list of the files that triggered the lockout
	foreach($log in $lastMin) {
		$message += $log.properties[0].value.split()[5]
		$message += "`n"
	}
	
} else {
	#Send a warning the script was triggered but the lockout threshold was not reached
	$to = $warningNotification
	$subject = "$hostname CryptoLocker warning triggered for: $($username)"
	
	$message = "$($username) triggered a warning but has not been locked out`n`n"
	$message += "Most recent event time stamp: $timestamp`n`n"
	#Full message with info on why the event was triggered
	$message += (($logs | select -first 1).properties[0]).value
	
}

Send-MailMessage -SmtpServer $smtpServer -from $from -to $to -subject $subject -body $message
