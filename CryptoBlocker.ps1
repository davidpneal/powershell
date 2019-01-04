#1-3-2018
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
$warningNotification = "admin@company.com"
$lockoutNotification = "it@company.com"
$from = "alert@company.com"
$smtpServer = "smtp.company.com"

#$autoUnlockTime = 30



#Wait for 1 second so the log can be written
sleep -seconds 1
$logs = Get-WinEvent -FilterHashtable @{Logname='Application';ID=8215}

#Get the username; it is value 6 in the properties of the log object
$username = ($logs | select -first 1).properties[6].value

#Ignore SYSTEM; it tends to generate false positives with windows updates, plus blocking it from share permissions is pointless
if($username -eq 'NT AUTHORITY\SYSTEM'){
	exit
}


#Filter the log, retaining any entries in the past minute by the user
$time = (get-date).addminutes(-1)

$lastMin = foreach($log in $logs){
	$user = $log.properties[6]
	
	if($user.value -eq $username -and $log.timecreated -gt $time){
		$log
	}
}


if(($lastMin | measure).count -gt 3) {
	$hostname = hostname
	$timestamp = ($logs | select -first 1).timecreated
	
	#Block the user's share permissions - this adds a deny to the share perms but leaves NTFS alone
	#This is done for speed and so every child's permissions dont need to be changed
	Get-SmbShare | Where-Object currentusers -gt 0 | foreach-object{
		Block-SmbShareAccess -Name $_.name -AccountName $username -force
	}
	
	
	$subject = "$hostname CryptoLocker protection: $($username) has been locked out"
	
	$message = "Most recent event time stamp: $timestamp`n"
	$message += "User: $($username)`n`n"
	
	
	#$log.properties[0] = full message with info on why the event was triggered; maybe copy this to email
	
	##(WIP) - need a for loop to do this:
	#Body of the email: a list of the files that triggered the lockout
	$message += 		
	#File names: $log.properties[0].value.split()[5]
		
		
##Decide if want to implement this section:	
#	$last60 = Count the events in the last 60 minutes
#	If (unlocks in last 60m > 6)
#		Add information to email notification indicating the user will not be auto unlocked
#	Else
#		Add a scheduled task to unlock the user after $autoUnlockTime minutes



} else {
	#Send a warning the script was triggered but the lockout threshold was not reached

	
}


Send-MailMessage -SmtpServer $smtpServer -from $from -to $to -subject $subject -body $message



----------------------------------------------------------------------


#Dec 2018 - TEST this ~ still applies???
#FSRM must be restarted after being triggered - it wont run twice for some reason
restart-service "File Server Resource Manager" -force


@'
Testing hack - can use multiple variable assignment to drop off the first element(s) from the logs array
based on the principle of: $a, $b, $c = 1, 2, 3 -- gives a = 1, b = 2, c = 3
>If there are more items on the right side of the evaluation than on the left, the remaining elements are
assigned to the last element, so this will drop the first element (it gets assigned to $null):
$null, $logs = $logs

'@