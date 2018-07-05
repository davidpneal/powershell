#7/5/2018

function Disable-UserAccount {

	<#
	.SYNOPSIS
	This function will disable the Active Directory and Office365 accounts for the specified user(s).
	.DESCRIPTION
	This function is used to disable the user accounts for a departing user.  It will disable the user in Active Directory, move the user account to a 'disabled users' OU, remove all groups from the account with the exception of Domain Users, hide the user in the Global Address List and optionally set a delegate user who can access the departing users' mailbox.
	.PARAMETER identity
	One or more user accounts to disable.  Must be specified as a SAMaccount name.
	.PARAMETER delegateTo
	One or more users to delegate email access to.  This delegate permission will be applied to all identity accounts.  This delegation will not grant
	SendAs rights or map the delegated mailbox into the 'delegateTo' user's Outlook client.
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
		#$groupsLogPath = "\\server\share\scriptlogs\DisableUserAccount"
		$groupsLogPath = "c:\tools\scripting"
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
			write-verbose "[PROCESS] Querying Active Directory for the user account that matches $user"
			try {
				$userAccount = get-aduser "$user" -properties memberof, description
				write-verbose "[PROCESS] AD account found: $userAccount"
			} catch {
				write-error "An error has occurred trying to access the user account for $user, please try again."
				continue
			}
			
			$userName = $userAccount.Name
			$userUPN = $userAccount.UserPrincipalName
			#Also grab the OU where the account is located
			
			if($force -or $PSCmdlet.ShouldContinue("Do you wish to continue?","The account for $userName will be disabled")) {
			
				write-verbose "[PROCESS] Making a record of the user's groups to $groupsLogPath\$user.txt"
				try {
					Format-UserGroups $user | out-file "$groupsLogPath\$user.txt" -append -encoding UTF8
					Add-Content -path "$groupsLogPath\$user.txt" -value "`r`nReport generated $(get-date -format d)"
					write-verbose "[PROCESS] User's groups have successfully been added to the file $groupsLogPath\$user.txt"
				} catch {
					write-warning "An error has occurred when trying to record the user's group memberships to $groupsLogPath\$user.txt"
					$continueMsg = "If the disable script continues, the user group membership information will be lost."
					if( -not ($PSCmdlet.ShouldContinue("Do you wish to continue?",$continueMsg))) {
						continue
					}
				}
				
				write-verbose "[PROCESS] Removing the user from all Active Directory groups except Domain Users"
				if($PSCmdlet.ShouldProcess($user, "Remove Active Directory group memberships")) {	
					try {	
						$userAccount.memberof | foreach-object { 
							Get-ADGroup $_ -erroraction stop | Remove-ADGroupMember -confirm:$false -member $user -erroraction stop
						}
					} catch {
						write-error "An error has occurred when trying to remove the Active Directory groups from $user"
					}
				}
				
				$params = @{
					identity = $user
					WhatIf = $WhatIfPreference
					Verbose = $VerbosePreference
				}
				
				#If the user's mailbox is being delegated, it cant be hidden in the GAL since OWA must be able to search for and find it
				if ($PSBoundParameters.ContainsKey('delegateTo')) {
					write-verbose "[PROCESS] Call the command to delegate access to the mailbox"
					
					$params.add("delegateTo", $delegateTo)	
					$params.add("session", $TenantSession)	
					try {
						Set-MailboxDelegation @params
					} catch {
						write-error "There was an error when attempting to delegate access to the mailbox.  This step will need to be done manually."
					}
				} else {
					write-verbose "[PROCESS] Call the command to hide the mailbox in the Global Address List."
					
					$params.add("session", $EMSSession)	
					try {
						Set-MailboxHidden @params
					} catch {
						write-error "There was an error when attempting to hide the mailbox in the GAL. This step will need to be done manually."
					}
				}

				
			
				write-output "end of process"
							
			} #End ShouldContinue
			
		} #End foreach
				
	} #PROCESS
	
	
	END {
		write-verbose "[END    ] Close the open PSSessions"
		
		if($TenantSession -ne $null) {
			Remove-PSSession $TenantSession -WhatIf:$false
		}
			
		if($EMSSession -ne $null) {
			Remove-PSSession $EMSSession -WhatIf:$false
		}
				
		write-verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
		
	} #END
	
}