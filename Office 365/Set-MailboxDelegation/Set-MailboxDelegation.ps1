#7/12/2018

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
	.PARAMETER pssession
		This parameter can be used to pass a previously established PSSession (connected to the Exchange Tenant) 
		to the Set-MailboxDelegation tool.  Using this parameter has the advantage that the tool will load just the 
		cmdlets it needs to change the permissions then will unload them afterward.  Note that this functionality will
		automatically call Import-PSSession with the -allowclobber flag set.
	.PARAMETER RemovePermissions
		Use this flag to remove delegate permissions. Note that this command will specifically remove FullAccess and
		SendAs permissions, if other permissions were set, those will need to be removed by other means.
	.PARAMETER Force
		When using RemovePermissions, PowerShell will prompt to confirm removing access. Use this flag to suppress that
		prompt.  If the confirm switch is called along with force, confirm will take precedence.
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
		Set-MailboxDelegation -identity jsmith -delegateTo dneal -pssession $session
		Delegates the permissions using the specified PSSession connection to the tenant
	.EXAMPLE
		(Get-ADUser jsmith).userprincipalname | Set-MailboxDelegation -delegateTo dneal
		Example usage for pipeline input.  Note that the output from Get-ADUser will be coerced into a distinguished name 
		which the hybrid tenant cannot use; hence specifically passing the UPN.  Passing the SAM Account Name works too.
	.EXAMPLE	
		"jsmith","ajones" | Set-MailboxDelegation -delegateTo dneal
		Example usage for pipeline input.  Passing an array of SAM Account Names or UPN's is acceptable.
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
		
		[object]$pssession,
		
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
		
		#The Remove commands both prompt for confirmation by default. Set-MailboxDelegation takes both a force and confirm switch - force
		#suppresses the prompts on the two individual Remove commands and Confirm prompts when calling the two Add or two Remove cmdlets. 
		#The result is the only time the individual Remove commands should prompt is if neither Confirm or Force are called
		#Note that if Confirm and Force are called together, the Confirm behavior takes precedence
		if (($Force -eq $false) -and (-not ($PSBoundParameters.ContainsKey('confirm')))) {
			$showConfirm = $true
		} else {
			$showConfirm = $false
		}
		
	} #BEGIN
	
	
    PROCESS {
		foreach($user in $delegateTo) {
					
			foreach($mailbox in $identity) {
				
				if($PSBoundParameters.ContainsKey('RemovePermissions')) {
								
					if($PSCmdlet.ShouldProcess($mailbox, "Remove mailbox permissions")) { 
						write-verbose "[PROCESS] Removing permissions from mailbox $mailbox for user $user"
						Remove-MailboxPermission -Identity $mailbox -User $user -AccessRights 'FullAccess' -confirm:$showConfirm
						Remove-RecipientPermission -Identity $mailbox -Trustee $user -AccessRights sendas -confirm:$showConfirm
					}
					
				} else {
					if($PSCmdlet.ShouldProcess($mailbox, "Add mailbox permissions")) {
						write-verbose "[PROCESS] Adding FullAccess permissions for user $user to mailbox $mailbox"
						Add-MailboxPermission -Identity $mailbox -User $user -AccessRights 'FullAccess' -AutoMapping $AutoMapping

						if($PSBoundParameters.ContainsKey('SendAs')) {
							write-verbose "[PROCESS] Adding SendAs permissions for user $user to mailbox $mailbox"
							Add-RecipientPermission -Identity $mailbox -Trustee $user -AccessRights sendas -confirm:$false
						}
					}
				}
			}
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