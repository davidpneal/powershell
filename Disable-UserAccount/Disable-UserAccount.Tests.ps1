#6/19/2018

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Disable-UserAccount" {

	#Guard mock ~ this might be too broad, narrow it to only AD module?
	#Mock Import-Module


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

	$MockCred = New-MockObject PSCredential

	
	
	


	
	It "Calls Get-Credential when a cred is not passed" {
		Disable-UserAccount -identity auser -force
		Assert-MockCalled Get-Credential -Times 1 -Exactly -Scope It
	}
	
	It "Does not call Get-Credential when a cred is passed" {
		Disable-UserAccount -identity auser -force -credential $MockCred
		Assert-MockCalled Get-Credential -Times 0 -Exactly -Scope It
	}
	
	#it calls Set-MailboxDelegation when the -delegateTo param is used
	
	#it calls Set-MailboxHidden when -delegateTo is not used
	
	#it takes more than one identity
	
	It 'Calls the other functions as expected' {
		Assert-VerifiableMock
	}
	
}
