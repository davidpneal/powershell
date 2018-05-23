#5/23/2018

#In order for these tests to work, the exchange tenant commands must exist on the machine testing is being run from
#The easiest way is to make a connecion to the Exchange tenant so it generates a temporary module with the commands
#More information: #https://github.com/pester/Pester/issues/682

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Set-MailboxDelegation" {
    
	Mock Add-RecipientPermission {
		return 1
	}
	
	Mock Add-MailboxPermission {
		return 1
	}
	
	Mock Remove-MailboxPermission {
		return 1
	}
	
	Mock Remove-RecipientPermission {
		return 1
	}
		
	Mock Get-ADUser {
		return @{'Name'='John Smith';
				 'MemberOf'='{CN=Domain Users,OU=Security Groups,DC=domain,DC=com}'}
	}
	
	
	It "calls Add-MailboxPermission in basic usage" {
		Set-MailboxDelegation -identity jsmith -delegateTo dneal
		Assert-MockCalled Add-MailboxPermission -Times 1 -Exactly -Scope It
	}
	
	It "takes more than one user identity" {
		Set-MailboxDelegation -identity jsmith, auser -delegateTo dneal
		Assert-MockCalled Add-MailboxPermission -Times 2 -Exactly -Scope It
	}
	
	It "takes more than one delegateTo user" {
		Set-MailboxDelegation -identity jsmith -delegateTo dneal, ajones
		Assert-MockCalled Add-MailboxPermission -Times 2 -Exactly -Scope It
	}
	
	It "applies multiple delegees to multiple identitys" {
		Set-MailboxDelegation -identity jsmith, auser -delegateTo dneal, ajones
		Assert-MockCalled Add-MailboxPermission -Times 4 -Exactly -Scope It
	}
	
	It "calls Add-RecipientPermission when the -SendAs switch is used" {
		Set-MailboxDelegation -identity jsmith -delegateTo dneal -SendAs
		Assert-MockCalled Add-RecipientPermission -Times 1 -Exactly -Scope It
	}
		
	It "should not call Add-MailboxPermission if the -WhatIf flag is used" {
		Set-MailboxDelegation -identity jsmith -delegateTo dneal -whatif
		Assert-MockCalled Add-MailboxPermission -Times 0 -Exactly -Scope It
	}
	
	It "should call Remove-RecipientPermission and Remove-MailboxPermission when the -RemovePermissions flag is used" {
		Set-MailboxDelegation -identity jsmith -delegateTo dneal -RemovePermissions
		Assert-MockCalled Remove-RecipientPermission -Times 1 -Exactly -Scope It
		Assert-MockCalled Remove-MailboxPermission -Times 1 -Exactly -Scope It
	}
	
	It "should not call Remove-RecipientPermission and Remove-MailboxPermission if the -WhatIf and -RemovePermissions flags are used" {
		Set-MailboxDelegation -identity jsmith -delegateTo dneal -RemovePermissions -whatif
		Assert-MockCalled Remove-RecipientPermission -Times 0 -Exactly -Scope It
		Assert-MockCalled Remove-MailboxPermission -Times 0 -Exactly -Scope It
	}

	It "should accept input via the pipeline" {
		Get-aduser jsmith | Set-MailboxDelegation -delegateTo dneal
		Assert-MockCalled Add-MailboxPermission -Times 1 -Exactly -Scope It
	}
	
}
