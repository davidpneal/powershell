#12-23-2018
#This script is designed to be used in conjunction with the crypto FSRM file screens here: https://fsrm.experiant.ca/
#By default, it will lock out the user after 3 file violations in a minute, then unlock the account after 30 minutes
#If the user then triggers a lockout again within an hour, the script will not set an auto unlock

#Set FSRM to run this script when a file screen violation is triggered
#C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe with argument: C:\scripts\Add-CryptoBlock.ps1
#Set the file screen to log the event and run it as Local System

#Note, this script will add and remove deny ACE's on the share permissions; if your workflow uses share denies
#to restrict individual user access to a share, these might inadvertently get removed

#Get-WinEvent requires installing PS5 on Server 2008R2 machines


##Settings##
$to = "admin@company.com"
$from = "alert@company.com"
$smtpServer = "smtp.company.com"

$logfile = "c:\scripts\cryptoHits.csv"
$autoUnlockTime = 30



#Need to wait for a second so the log can be written
sleep -seconds 1

#Get the username
## Change: get event 8215 instead - Get-WinEvent -FilterHashtable @{Logname='Application';ID=8215}
#$logEvents = get-eventlog -logname Application -message "*crypto*" -newest 1
#Need to extract the username etc from the 'properties' property: $log.properties[6] = username, [0] = message with user a files - prob copy this to email
$username = ($logEvents.message).split()[1]
$username = $username -replace ".*\\"
#might set the script to ignore SYSTEM since it tends to generate false positives, esp with processing windows updates


'@ ~algorithm~

Get the user of the newest log

$lastMin = Count the events in the last 1 min
$last60 = Count the events in the last 60 minutes

If($lastMin > 3)
	Lockout the user
		#Block their share permissions - this adds a deny to the share perms but leaves NTFS alone
		Get-SmbShare | Where-Object currentusers -gt 0 | %{Block-SmbShareAccess -Name $_.name -AccountName $username -force}
		
	Set notification email subject to "user locked out"
		Body of the email: a list of the files that triggered the lockout
	
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