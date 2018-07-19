#6/26/2018

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Disable-UserAccount" {

	#Guard mock ~ this might be too broad, narrow it to only AD module?
	#Mock Import-Module

	#These two mocks dont seem to work...
	Mock Connect-OnPremEMS {
		return $true
	}
	Mock Connect-Tenant {
		return $true
	}
	
	
	Mock Format-UserGroups -verifiable {
	} 
	
	Mock Set-MailboxDelegation {
	}
	
	Mock Set-MailboxHidden {
	} 


	Mock Get-ADUser -verifiable {
		#needs to return: name, userprincipalname, memberof, description
	}
	
	Mock Get-ADGroup -verifiable {
		#needs to return since it passes the object down the pipeline
		return $true
	}
	Mock Remove-ADGroupMember -verifiable {
	}
	Mock Set-ADUser -verifiable {
	}
	Mock Disable-ADAccount -verifiable {
	}
	Mock Move-ADObject -verifiable {
	}
	Mock Remove-PSSession -verifiable {
	}
	
		
	Mock Get-Credential {
	}

	$MockCred = New-MockObject System.Management.Automation.PSCredential

	
	
		
	It "Calls Get-Credential when a cred is not passed" {
		Disable-UserAccount -identity auser -force
		Assert-MockCalled Get-Credential -Times 1 -Exactly -Scope It
	}
	
	It "Does not call Get-Credential when a cred is passed" {
		Disable-UserAccount -identity auser -force -credential $MockCred
		Assert-MockCalled Get-Credential -Times 0 -Exactly -Scope It
	}
	
	It "Calls Set-MailboxDelegation when the -delegateTo param is used" {
		Disable-UserAccount -identity auser -force -delegateTo jsmith -credential $MockCred
		Assert-MockCalled Set-MailboxDelegation -Times 1 -Exactly -Scope It
	}
	
	It "Calls Set-MailboxHidden when -delegateTo is not used" {
		Disable-UserAccount -identity auser -force -credential $MockCred
		Assert-MockCalled Set-MailboxHidden -Times 1 -Exactly -Scope It
	}
	
	It "Takes more than one identity" {
		Disable-UserAccount -identity auser -force -credential $MockCred
		Assert-MockCalled Set-MailboxHidden -Times 2 -Exactly -Scope It
	}
	
	It 'Calls the other functions as expected' {
		Assert-VerifiableMock
	}
	
}
