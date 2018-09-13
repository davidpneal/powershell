#9/13/2018

function Unblock-CryptoDeny {
	
    <#
	.SYNOPSIS
	This function will remove the SMB share deny ACEs for all shares on a target server for a
	specified user.
	.PARAMETER identity
	One or more user account(s) to unblock from the target server.  Specify the username as an UPN.
	.PARAMETER ComputerName
	One or more computer names to run the command against.  Note, this function uses the 
	Unblock-SmbShareAccess cmdlet which requires PowerShell 3 (Server 2012 or higher)
	.EXAMPLE
	Unblock-CryptoDeny -identity "jsmith" -ComputerName FileServer01
	Remove the SMB share deny for jsmith from computer FileServer01
	.EXAMPLE
	Unblock-CryptoDeny -identity "jsmith" -ComputerName FileServer01, FileServer02
	Remove the SMB share deny for jsmith from computer FileServer01 and FileServer02
	.EXAMPLE
	Get-ADUser jsmith | Unblock-CryptoDeny -ComputerName FileServer01
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
		foreach($computer in $ComputerName) {
		
			#make a pssession to the computer
		
			foreach($user in $identity) {
		
				#invoke-command ? to the pssession
			
			}
			
			#remove the pssession
		}
		
	} #PROCESS
	
	
	END {
		#Intentionally empty
	} #END