#5/8/2018

function Set-MailboxHidden {
	
	<#
	.SYNOPSIS
		This command can be used to hide or unhide a mailbox from the global address list.
	.DESCRIPTION
		This command can be used to hide or unhide a mailbox from the global address list in the Office 365 
		exchange tenant.  This setting is made in the On-Premises Exchange Management Shell and requires 
		the Set-RemoteMailbox cmdlet to be available.  The cmdlet can either be loaded before running 
		Set-MailboxHidden or can be loaded from a PSSession that is passed to the command.
	.PARAMETER identity
		One or more user account names to hide or unhide from the global address list.  This tool will accept
		a SAM account name or a UPN.
	.PARAMETER session
		This parameter can be used to pass a previously established PSSession (connected to the On-Prem hybrid 
		exchange server) to the Set-MailboxHidden tool.  Using this parameter has the advantage that the tool 
		will load just the single Set-RemoteMailbox command it needs then will unload it afterward.  Note that 
		this functionality will automatically call Import-PSSession with the -allowclobber flag set.
	.PARAMETER unhide
		The default behavior of the tool is to hide the mailbox.  Use this switch to unhide the mailbox.  Note
		that if more than one identity is provided, the unhide action will be applied to all users in the call. 
	.EXAMPLE
		Set-MailboxHidden -identity user 
		Typical usage - hides the mailbox for the specified user, the OnPrem EMS mailbox command 
		Set-RemoteMailbox must already be loaded into the PowerShell session
	.EXAMPLE
		Set-MailboxHidden -identity user, user1
		Hides the mailbox for user and user1
	.EXAMPLE
		Set-MailboxHidden -identity user -unhide
		Unhides the specified mailbox
	.EXAMPLE
		Get-ADUser jsmith | Set-MailboxHidden
		Example usage for pipeline input
	.EXAMPLE
		Set-MailboxHidden -identity user -PSSession $session
		Hides the mailbox using the specified PSSession connection to the on-prem EMS
	#>

	
	[CmdletBinding(SupportsShouldProcess,
				   ConfirmImpact='Low')]

    Param(
		[Parameter(ValueFromPipeline = $True, 
				   Mandatory = $True, 
				   Position = 0)]
		[string[]]$identity,
		
		#could probably also change this to type System.Management.Automation.Runspaces.PSSession
		[object]$session,
		
		[switch]$unhide
	)

	
	BEGIN {
		write-verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
		$SessionResult = $null

		#If a PSSession was passed, the necessary mailbox function needs to be loaded
		if ($PSBoundParameters.ContainsKey('session')) {
			try {
				#Since a PSSession was explicitly passed, use -allowclobber in case the Set-RemoteMailbox command already exists
				#write-verbose "[BEGIN  ] Attempting to import Set-RemoteMailbox from the provided PSSession"
				$SessionResult = Import-PSSession -Session $session -CommandName "Set-RemoteMailbox" -AllowClobber
			} catch {
				write-warning $_
				throw "Unable to import the Set-RemoteMailbox EMS command using the provided PSSession"
			}
		}

		
		#Make sure the Set-RemoteMailbox command is loaded
		try {
			#redirect the output of this command to null to supress the output
			write-verbose "[BEGIN  ] Checking to make sure the Set-RemoteMailbox command is available"
			get-command "Set-RemoteMailbox" -erroraction stop > $null
		} catch {
			write-warning $_
			throw "The Set-RemoteMailbox command is not currently available. Please connect to the OnPrem EMS and try again."
		}
			
			
		#The default action of the tool is to hide the mailbox ($true), if $unhide is set, then need to flip the setting to $false
		if ($PSBoundParameters.ContainsKey('unhide')) {
			write-verbose "[BEGIN  ] The -unhide switch was passed, setting ShouldHide to false"
			$ShouldHide = $false
		} else {
			$ShouldHide = $true
		}
		
	} #BEGIN
	
	
    PROCESS {
		foreach($user in $identity) {
			#write-verbose "[PROCESS] Attempting to set the HiddenFromAddressListsEnabled attribute on $user"
			
			if ($PSCmdlet.ShouldProcess($user)) { 
				Set-RemoteMailbox -identity $user -HiddenFromAddressListsEnabled $ShouldHide
			}
		}
		
	} #PROCESS
	
	
	END {
		If($SessionResult -ne $null) {
			write-verbose "[END    ] Unloading the temporary module containing Set-RemoteMailbox"
			#Unload the temp module
			Remove-Module $SessionResult
		}	
		
		write-verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
		
	} #END
}
