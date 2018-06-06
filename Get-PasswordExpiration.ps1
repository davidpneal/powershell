#12/10/2016
#This function will calculate the password expiration date for the specified account(s).
#Outputs an ADUser object with 2 fields - Displayname and Expiration Date

#Improve: currently, if the user account "PasswordNeverExpires" is $true, the script returns a blank for the expiration date
#Improve - allow pipeline input
Function Get-PasswordExpiration()
{
    <#
	.SYNOPSIS
	Gets the password expiration date for the specified user(s).
	.PARAMETER users
	The user account(s) to check the password expiration date for.  Needs to be specified as a SAMaccount name.
	.EXAMPLE
	Get-PasswordExpiration -users "jsmith","jdoe"
	Returns the password expiration date and time for jsmith and jdoe
	#>
	
	[cmdletbinding()]
	param([parameter(Mandatory=$true)][AllowEmptyString()][String[]]$users)	
	#improve - allow to pass objects from pipeline (ValueFromPipeline=$true), and if possible also pass by value - identity (from aduser)
		
	foreach($user in $users) {
		#Try catch failed AD Lookup
		#If there is no expiration date. specify "Never Expires"
		Get-ADUser $user -Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" |
			select -Property "Displayname",@{Name="Expiration Date";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}
	}
}