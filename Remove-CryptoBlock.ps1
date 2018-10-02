#10/2/2018

function Remove-CryptoBlock {
	
    <#
	.SYNOPSIS
	This function will remove the SMB share deny ACEs for all shares on a target server for a
	specified user.  
	Important: The underlying SmbShare module requires Server 2012 or newer on the target machine.
	.PARAMETER identity
	One or more user account(s) to unblock from the target server.  Specify the username as an UPN.
	.PARAMETER ComputerName
	One or more computer names to run the command against.  Note, this function uses cmdlets from 
	the SmbShare module which requires server 2012 or newer to function.
	.EXAMPLE
	Remove-CryptoBlock -identity "jsmith" -ComputerName FileServer01
	Remove the SMB share deny for jsmith from computer FileServer01
	.EXAMPLE
	Remove-CryptoBlock -identity "jsmith" -ComputerName FileServer01, FileServer02
	Remove the SMB share deny for jsmith from computer FileServer01 and FileServer02
	.EXAMPLE
	Get-ADUser jsmith | Remove-CryptoBlock -ComputerName FileServer01
	Pipeline usage example.
	#>
	
	
	[cmdletbinding()]
	
	Param(	
		[Parameter(ValueFromPipeline = $True, 
				   Mandatory = $True,  
				   Position = 0)]
		[string[]]$identity,
		
		[Parameter(Mandatory = $True,  
				   Position = 1)]
		[string[]]$ComputerName
	)

	
	BEGIN {
		#Intentionally empty
	} #BEGIN

	
	PROCESS {
		foreach($user in $identity) {
	
			write-verbose "[PROCESS] Setting permissions for $user"
	
			Invoke-Command -Computername $ComputerName -ArgumentList $user -ScriptBlock { 
				#Need a param block so the ArgumentList switch can populate the user variable in the remote scope
				param($user)
				
				#Get all shares on the server and pipe them into the unblock SMB command
				Get-SmbShare | ForEach-Object {UnBlock-SmbShareAccess -Name $_.name -AccountName $user -force}
			}

		}

	} #PROCESS

	
	END {
		#Intentionally empty
	} #END
	
}