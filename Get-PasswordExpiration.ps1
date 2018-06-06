#6/6/2018

Function Get-PasswordExpiration()
{
    <#
	.SYNOPSIS
	This function will calculate the password expiration date for the specified account(s).
	.PARAMETER identity
	The user account(s) to get the password expiration date for.
	.EXAMPLE
	Get-PasswordExpiration -identity "jsmith","jdoe"
	Get the password expiration date and time for jsmith and jdoe.
	.EXAMPLE
	Get-ADUser jsmith | Get-PasswordExpiration
	Pipeline usage example.
	.EXAMPLE
	get-aduser -searchbase "OU=Office,OU=Remote,DC=company,DC=com" -filter * | Get-PasswordExpiration
	Get the expiration date of all users in the 'Office' OU.
	#>
	
	
	[cmdletbinding()]
	
	Param(	
		[Parameter(ValueFromPipeline = $True, 
				   Mandatory = $True,  
				   Position = 0)]
		[string[]]$identity
	)

	
	BEGIN {
		#Intentionally empty
	} #BEGIN

	
	PROCESS {
		foreach($user in $identity) {
		
			$adObject = Get-ADUser $user -Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed", "PasswordNeverExpires"
			
			if($adObject.PasswordNeverExpires -eq $true) {
				write-output $adObject | select -Property "Displayname",@{Name="ExpirationDate";Expression={"Never Expires"}}
			} else {
				write-output $adObject | select -Property "Displayname",@{Name="ExpirationDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}
			}
		}
		
	} #PROCESS
	
	
	END {
		#Intentionally empty
	} #END
	
}