#5-15-2017
#The cmdlets in this script require Server 2012R2 or newer

#To use the script, in FSRM, under the file screen, set this as the command:
#C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe 
#With argument: C:\scripts\Deny-CryptoUser.ps1
#Be sure to set the file screen to log the event as well since the script gets the username from it
#Set the script to run as Local System


#Need to wait for a second so the log can be written
sleep -seconds 1

#Get the offending user
$RansomwareEvents = get-eventlog -logname Application -message "*crypto*" -newest 1
$username = ($RansomwareEvents.message).split()[1]
$username = $username -replace ".*\\"

#Block their share permissions - this adds a deny to the share perms but leaves NTFS alone
Get-SmbShare | Where-Object currentusers -gt 0 | %{Block-SmbShareAccess -Name $_.name -AccountName $username -force}

#FSRM must be restart after being triggered - it wont run twice for some reason
restart-service "File Server Resource Manager" -force