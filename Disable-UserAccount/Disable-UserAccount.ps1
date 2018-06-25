#6/25/2018

function Disable-UserAccount {

	<#
	.SYNOPSIS
	This function will disable the Active Directory and Office365 accounts for the specified user(s).
	.DESCRIPTION
	This function is used to disable the user accounts for a departing user.  It will disable the user in Active Directory, move the user account to a 'disabled users' OU, remove all groups from the account with the exception of Domain Users, hide the user in the Global Address List and optionally set a delegate user who can access the departing users' mailbox.
	.PARAMETER identity
	One or more user accounts to disable.  Must be specified as a SAMaccount name.
	.PARAMETER delegateTo
	One or more users to delegate email access to.  This delegate permission will be applied to all identity accounts
	Note: when this parameter is invoked, the user will not be hidden in the GAL.
	.PARAMETER credential
	Credentials used to connect to the exchange environment.  The username in the credential must be specified as a UPN.  This parameter only affects the credentials used to access the exchange environments (tenant and on-prem); the rest of the commands will be run under the currently logged on user.
	.PARAMETER force
	Forces the script to execute without verifying the user account.
	.EXAMPLE
	Disable-UserAccount jsmith
	Basic usage.  Will remove the accounts for jsmith.
	.EXAMPLE
	Disable-UserAccount jsmith -force
	Disable the user account without verifying the correct user was selected.
	.EXAMPLE
	Disable-UserAccount jsmith -delegateTo dneal, ajones
	Delegates email access to dneal and ajones when disabling the user account.  Account names must be specified as a SAMaccount name.
	#>
	
	
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

	
	BEGIN {
		write-verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
		
		#Script Variables:
		$groupsLogPath = "\\server\share\scriptlogs\DisableUserAccount"
		$disabledOUDN = "OU=disabledusers,DC=company,DC=com"
	
		write-verbose "[BEGIN  ] Test to see if the Active Directory module is already loaded in the current session."
		if (Get-Module -Name "ActiveDirectory") {
			write-verbose "[BEGIN  ] The Active Directory module was already loaded in the current session."
		} else {
			write-verbose "[BEGIN  ] The Active Directory module is not currently loaded, attempting to load it now."
			Import-Module ActiveDirectory -verbose:$false -erroraction stop
		}

		if ( -not $PSBoundParameters.ContainsKey('credential')) {
			write-verbose "[BEGIN  ] Get user credentials so a connection to the exchange environment can be established."
			$credential = get-credential -credential $credUser
		} else {
			write-verbose "[BEGIN  ] User credentials were passed to the function when it was called."
		}
		
		if ($PSBoundParameters.ContainsKey('delegateTo')) {
			write-verbose "[BEGIN  ] Create a connection to the Exchange Tenant"
			
			try {
				$TenantSession = Connect-Tenant -credential $credential -sessiononly -erroraction stop
			} catch {
				write-warning "There was an issue connecting to the Exchange Tenant"
				$continueMsg = "Without this connection, the mailbox delegation will need to be set manually."
				if( -not ($PSCmdlet.ShouldContinue("Do you wish to continue?",$continueMsg))) {
					break
				}
			}
		} else {
			write-verbose "[BEGIN  ] Create a connection to the On Premises Exchange environment"
		
			try {
				$EMSSession = Connect-OnPremEMS -credential $credential -sessiononly -erroraction stop
			} catch {
				write-warning "There was an issue connecting to the On Premises Exchange environment"
				$continueMsg = "Without this connection, the mailbox will need to be hidden in the global address list manually."
				if( -not ($PSCmdlet.ShouldContinue("Do you wish to continue?",$continueMsg))) {
					break
				}
			}
		}
				
	} #BEGIN

	
	PROCESS {
		foreach($user in $identity) {
			write-verbose "[PROCESS] Disabling account $user"
		}
		
		
	} #PROCESS
	
	
	END {
		write-verbose "[END    ] Close the open PSSessions"
		
		if($TenantSession -ne $null) {
			Remove-PSSession $TenantSession
		}
			
		if($EMSSession -ne $null) {
			Remove-PSSession $EMSSession 
		}
				
		write-verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
		
	} #END
	
}