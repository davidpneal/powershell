#6/15/2018

function Disable-UserAccount
{

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