#5/16/2018

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
		
		[object]$session,
		
		[switch]$SendAs = $False,
		
		[switch]$AutoMapping = $False,
		
		[switch]$RemovePermissions
	)
	

	BEGIN {
		write-verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
		$SessionResult = $null

		#If a PSSession was passed, the necessary mailbox commands need to be loaded
		if ($PSBoundParameters.ContainsKey('session')) {
			try {
				#Since a PSSession was explicitly passed, use -allowclobber in case the commands already exist
				#write-verbose "[BEGIN  ] Attempting to import the necessary mailbox commands from the provided PSSession"
				$SessionResult = Import-PSSession -Session $session -CommandName "Set-RemoteMailbox" -AllowClobber
			} catch {
				write-warning $_
				throw "Unable to import the mailbox commands using the provided PSSession"
			}
		}

		
		#Make sure the mailbox commands are loaded
		try {
			#redirect the output of this command to null to supress the output
			write-verbose "[BEGIN  ] Checking to make sure the mailbox commands are available"
			
			## Decide how to check this - check for all 4 commands?  In theory, as long as connected to tenant, they should all be available
			get-command "Set-RemoteMailbox" -erroraction stop > $null
			
		} catch {
			write-warning $_
			throw "The necessary mailbox commands are not currently available. Please connect to the Exchange Tenant and try again."
		}
			
	} #BEGIN
	
	
    PROCESS {
		foreach($user in $identity) {
			
			if ($PSCmdlet.ShouldProcess($user)) { 
				
				
			}
		}
		
	} #PROCESS
	
	
	END {
		If($SessionResult -ne $null) {
			write-verbose "[END    ] Unloading the temporary module containing the mailbox commands"
			#Unload the temp module
			Remove-Module $SessionResult
		}	
		
		write-verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
		
	} #END

}
