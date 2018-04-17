#4/17/2018

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Format-UserGroups" {
	
	#Mock Get-Module{ return $true }
	#Note: as of April 2018, mocking Get-Module will fail: https://github.com/pester/Pester/issues/1007
	
	Mock Get-ADUser{
		return @{'Name'='John Smith';
				 'MemberOf'='{CN=EmailUsers,OU=Distribution Lists,DC=domain,DC=com, CN=Domain Users,OU=Security Groups,DC=domain,DC=com}'}
	}

    It "calls Get-ADUser once per user" {
        Format-UserGroups -identity dneal, jsmith
		Assert-MockCalled Get-ADuser -Times 2 -Exactly -Scope It
    }
	
	#May delete this test
	It "should output one string per user" {
        Format-UserGroups -identity dneal, jsmith
		#test?
    } -skip
	
	It "should accept input via the pipeline" {
		Get-ADUser jsmith | Format-UserGroups |
		Should -Not -BeNullOrEmpty
	}
	
}
