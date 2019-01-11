#7/24/2018

function Get-MailboxDelegation {
	
	<#
	.SYNOPSIS
		This command is used to view the assigned permissions on an Office 365 mailbox.
	.DESCRIPTION
		This command is used to view the mailbox permissions and the SendAs permissions set on a specific Office 365 
		mailbox in the exchange tenant.
				
		These settings are queried from the Exchange Tenant and require several cmdlets from the tenant to be available.  
		These cmdlets can either be loaded before running Get-MailboxDelegation or can be automatically loaded from a 
		PSSession that is passed to the command.
	.PARAMETER identity
		One or more user accounts to check the permissions for. This tool will accept a SAM account name or a UPN.
	.PARAMETER pssession
		This parameter can be used to pass a previously established PSSession (connected to the Exchange Tenant) 
		to the Get-MailboxDelegation tool.  Using this parameter has the advantage that the tool will load just the 
		cmdlets it needs to get the permissions then will unload them afterward.  Note that this functionality will
		automatically call Import-PSSession with the -allowclobber flag set.
	.EXAMPLE
		Get-MailboxDelegation -identity jsmith
		Gets the MailboxPermission and RecipientPermission (SendAs rights) for user jsmith. Requires the tenant commands 
		to be loaded into the current session.
	.NOTES
		When running the command using a pssession, the format.ps1xml file isnt imported from the tenant module.  The 
		result of this is the output is displayed as a list instead of a table.
	#>

	[CmdletBinding(SupportsShouldProcess,
				   ConfirmImpact = 'Low')]
				   
	Param(
		[Parameter(ValueFromPipeline = $True, 
				   Mandatory = $True,  
				   Position = 0)]
		[string[]]$identity,

		[object]$pssession
	)
	

	BEGIN {
		write-verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
		$SessionResult = $null
		$cmdlets = "Get-RecipientPermission", "Get-MailboxPermission"
		
		#If a PSSession was passed, the necessary mailbox commands need to be loaded
		if ($PSBoundParameters.ContainsKey('pssession')) {
			try {
				#Since a PSSession was explicitly passed, use -allowclobber in case the commands already exist
				write-verbose "[BEGIN  ] Attempting to import the necessary mailbox commands from the provided PSSession"
				$SessionResult = Import-PSSession -Session $pssession -CommandName $cmdlets -AllowClobber
			} catch {
				throw "Unable to import the mailbox commands using the provided PSSession"
			}
		}
		
		#Make sure the mailbox commands are loaded
		try {
			#redirect the output of this command to null to supress the output
			write-verbose "[BEGIN  ] Checking to make sure the mailbox commands are available"
			get-command $cmdlets -erroraction stop > $null
		} catch {
			throw "The necessary mailbox commands are not currently available. Please connect to the Exchange Tenant and try again."
		}
		
	} #BEGIN
	
	
    PROCESS {
		foreach($user in $identity) {
			write-verbose "[PROCESS] Mailbox permissions set on the mailbox $user"		
			Get-MailboxPermission -identity $user	
			
			write-verbose "[PROCESS] SendAs permissions set on the mailbox $user"			
			Get-RecipientPermission -identity $user
		}

	} #PROCESS
	
	
	END {
		if($SessionResult -ne $null) {
			write-verbose "[END    ] Unloading the temporary module containing the mailbox commands"
			#Need to add -whatif:$false otherwise the temp module is not unloaded when -WhatIf is used
			Remove-Module $SessionResult -whatif:$false -confirm:$false
		}	
		
		write-verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
		
	} #END

}