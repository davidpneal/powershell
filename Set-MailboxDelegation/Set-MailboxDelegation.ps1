#5/30/2018

function Set-MailboxDelegation {

	<#
	.SYNOPSIS
		This command is used to delegate access of an Office 365 mailbox to another user.
	.DESCRIPTION
		This command is used to modify access of an Office 365 mailbox in the exchange tenant to another user. 
		The tool has the ability to grant FullAccess permission, SendAs permission or to remove those permissions.
				
		These setting are made in the Exchange Tenant and require several cmdlets from the tenant to be available.  
		These cmdlets can either be loaded before running Set-MailboxDelegation or can be automatically loaded from a 
		PSSession that is passed to the command.
	.PARAMETER identity
		One or more user accounts which will be delegated out. This tool will accept a SAM account name or a UPN.
	.PARAMETER delegateTo
		One or more user accounts to grant delegate access to.  This tool will assign FullAccess permissions for each 
		'delegateTo' user to the specified 'identity' account(s). This tool will accept a SAM account name or a UPN.
	.PARAMETER AutoMapping
		This flag will set the account so it automatically is added to the delegee users' Outlook client.  The default
		behavior is to not automatically map the mailbox into Outlook.
	.PARAMETER SendAs
		Use this flag to grant SendAs permission, by default this permission is not added. This permission is required
		if the delegee user is to send emails from the delegated account.
	.PARAMETER session
		This parameter can be used to pass a previously established PSSession (connected to the Exchange Tenant) 
		to the Set-MailboxDelegation tool.  Using this parameter has the advantage that the tool will load just the 
		cmdlets it needs to change the permissions then will unload it afterward.  Note that this functionality will
		automatically call Import-PSSession with the -allowclobber flag set.
	.PARAMETER RemovePermissions
		Use this flag to remove delegate permissions. Note that this command will specifically remove FullAccess and
		SendAs permissions, if other permissions were set, those will need to be removed by other means.
	.PARAMETER Force
		When using RemovePermissions, PowerShell will prompt to confirm removing access. Use this flag to suppress that
		prompt.
	.EXAMPLE
		Set-MailboxDelegation -identity jsmith -delegateTo dneal
		To delegate jsmith's mailbox to dneal with FullAccess permissions. Requires the tenant commands to be loaded 
		into the current session.
	.EXAMPLE
		Set-MailboxDelegation -identity jsmith -delegateTo dneal -AutoMapping
		To delegate the permissions and automatically map the new mailbox into dneals outlook (default is disabled)
	.EXAMPLE
		Set-MailboxDelegation -identity jsmith -delegateTo dneal -SendAs
		To delegate the permissions and also grant SendAs permissions for dneal.
	.EXAMPLE
		Set-MailboxDelegation -identity jsmith -delegateTo dneal -RemovePermissions
		This command will remove the FullAccess and SendAs permissions from jsmith's mailbox for the user dneal. 
	.EXAMPLE
		Set-MailboxDelegation -identity jsmith -delegateTo dneal -PSSession $session
		Delegates the permissions using the specified PSSession connection to the tenant
	.EXAMPLE
		Get-aduser jsmith | Set-MailboxDelegation -delegateTo dneal
		Example usage for pipeline input
	.EXAMPLE
		Set-MailboxDelegation -identity jsmith -delegateTo dneal -RemovePermissions
		To remove the delegation permissions for dneal from the jsmith account
		Note: if this switch is used, the tool will ignore the SendAs and AutoMapping switches
	#>
	
	
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
		
		[switch]$SendAs,
		
		[switch]$AutoMapping = $False,
		
		[switch]$RemovePermissions,
		
		[switch]$Force
	)
	

	BEGIN {
		write-verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
		$SessionResult = $null
		$cmdlets = "Add-RecipientPermission", "Add-MailboxPermission", "Remove-MailboxPermission", "Remove-RecipientPermission"
		
		#If a PSSession was passed, the necessary mailbox commands need to be loaded
		if ($PSBoundParameters.ContainsKey('session')) {
			try {
				#Since a PSSession was explicitly passed, use -allowclobber in case the commands already exist
				#write-verbose "[BEGIN  ] Attempting to import the necessary mailbox commands from the provided PSSession"
				$SessionResult = Import-PSSession -Session $session -CommandName $cmdlets -AllowClobber
			} catch {
				write-warning $_
				throw "Unable to import the mailbox commands using the provided PSSession"
			}
		}

		
		#Make sure the mailbox commands are loaded
		try {
			#redirect the output of this command to null to supress the output
			write-verbose "[BEGIN  ] Checking to make sure the mailbox commands are available"
			get-command $cmdlets -erroraction stop #> $null
		} catch {
			write-warning $_
			throw "The necessary mailbox commands are not currently available. Please connect to the Exchange Tenant and try again."
		}
			
	} #BEGIN
	
	
    PROCESS {
		foreach($user in $delegateTo) {
					
			foreach($mailbox in $identity) {
				
				if(RemovePerms bound) {
					if($PSCmdlet.ShouldProcess($mailbox)) { 
						#remove perms
						Remove-MailboxPermission
						Remove-RecipientPerms
					}
				} else {
					if($PSCmdlet.ShouldProcess($mailbox)) {
						#add delegation
						Add-MailboxPermission 
						
						#see what error message you get if delegating fails - might not need to catch at all; if it fails the user should see the error
						
						if(sendas bound) {
							Add-RecipientPermission
						}
					}
				}
			}
		}
		
	} #PROCESS
	
	
	END {
		if($SessionResult -ne $null) {
			write-verbose "[END    ] Unloading the temporary module containing the mailbox commands"
			#Unload the temp module
			Remove-Module $SessionResult
		}	
		
		write-verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
		
	} #END

}
