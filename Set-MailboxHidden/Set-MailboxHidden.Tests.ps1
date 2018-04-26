#4/26/2018

#In order for these tests to work, the Set-RemoteMailbox command must exist on the machine testing is being run from
#The easiest way is to make a connecion to the On-Prem EMS so it generates a temporary module with the command
#More information: #https://github.com/pester/Pester/issues/682

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Set-MailboxHidden" {
    
	Mock Set-RemoteMailbox {
		return 1
	}
	
	Mock Get-ADUser {
		return @{'Name'='John Smith';
				 'MemberOf'='{CN=Domain Users,OU=Security Groups,DC=domain,DC=com}'}
	}
	
	Mock Get-Command {
		return 1
	}
	
	#This mock isnt working at the moment; causes the last 2 "it" tests to fail since the real function is called
	Mock Import-PSSession {
		return 1
	}
	
	Mock Remove-Module {
		return 1
	}
	
	
	It "calls Set-RemoteMailbox" {
		Set-MailboxHidden -identity user
		Assert-MockCalled Set-RemoteMailbox -Times 1 -Exactly -Scope It
	}
	
	It "takes more than one user identity" {
		Set-MailboxHidden -identity user, user1
		Assert-MockCalled Set-RemoteMailbox -Times 2 -Exactly -Scope It
	}

	It "should accept input via the pipeline" {
		Get-ADUser dneal | Set-MailboxHidden
		Assert-MockCalled Set-RemoteMailbox -Times 1 -Exactly -Scope It
	}
	
	#This syntax doesnt work correctly at the moment
	#Might remove this test - if get the next test to work, it indicates this part works too
	It "changes $ShouldHide to $false if called with the -unhide switch" {
		Set-MailboxHidden -identity user -unhide
		$script:$ShouldHide | should be $false
	}
	
	It "attempts to Import-PSSession when the -session parameter is used" {
		Set-MailboxHidden -identity user -session "test" -verbose
		Assert-MockCalled Import-PSSession -Times 1 -Exactly -Scope It
	}
	
	It "removes the temporary module created when the -session parameter is used" {
		Set-MailboxHidden -identity user -session $session -verbose
		Assert-MockCalled Remove-Module -Times 1 -Exactly -Scope It
	}
	
}
