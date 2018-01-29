#1/26/2018

function Set-MailboxDelegation {

	[CmdletBinding(SupportsShouldProcess,
				   ConfirmImpact = 'Low')]
				   
	Param(
		[Parameter(ValueFromPipeline = $True, 
				   Mandatory = $True,  
				   Position = 0)]
		[string[]]$identity,
		
		[Parameter(Mandatory = $True, 
				   Position = 1)]
		[string[]]$delegateTo,
		
		[string]$pssession = $null,
		
		[switch]$SendAs = $False,
		
		[switch]$RemovePermissions = $False,
		
		[switch]$AutoMapping = $False
	)
	

	BEGIN {
	
	} #BEGIN
	
	
    PROCESS {
	
	} #PROCESS
	
	
	END {
	
	} #END

}
