#12/27/2018
#This script will add the mail routing address to mailboxes which have address policy inheritance disabled
#Change tenant to the name of the tenant the mail will be migrated to

#User mailboxes
$allmb = get-mailbox -IgnoreDefaultScope -ResultSize unlimited
$addalias = $allmb | where-object{$_.EmailAddressPolicyEnabled -eq $False}

foreach($mb in $addalias) {
	#If the mailbox already has the address, Set-Mailbox will display a warning but not modify anything
	Set-Mailbox -ignoredefaultscope -Identity $mb.DistinguishedName -EmailAddresses @{Add="smtp:$($mb.alias)@tenant.mail.onmicrosoft.com"}
}


#Distribution groups
$allgroups = Get-DistributionGroup -IgnoreDefaultScope -ResultSize unlimited
$addalias = $allgroups | where-object{$_.EmailAddressPolicyEnabled -eq $False}

foreach($mb in $addalias) {
	#If the mailbox already has the address, Set-DistributionGroup will display a warning but not modify anything
	Set-DistributionGroup -ignoredefaultscope -Identity $mb.DistinguishedName -EmailAddresses @{Add="smtp:$($mb.alias)@tenant.mail.onmicrosoft.com"}
}