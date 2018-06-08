#6/8/2018

function Disable-UserAccount
{

	
	
	[CmdletBinding(SupportsShouldProcess,
				   ConfirmImpact='High')]
	
	Param(
		[Parameter(Position=0, 
				   Mandatory=$True,
				   ValueFromPipeline=$True,
				   HelpMessage="Enter one or more user accounts to disable.")]
		[string[]]$identity,
		
		[string[]]$delegateTo,
		
		[pscredential]$credential,
		
		[switch]$force
	)
		
	
	#Script Variables:
	$groupsLogPath = "\\server\share\scriptlogs\DisableUserAccount"
	$disabledOUDN = "OU=disabledusers,DC=company,DC=com"
	
	
	BEGIN {
		write-verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
		
	} #BEGIN

	
	PROCESS {
		foreach($user in $identity) {
		
		}
	} #PROCESS
	
	
	END {
		
		write-verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
	} #END
	
}