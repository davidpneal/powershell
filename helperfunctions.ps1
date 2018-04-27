#4/27/2018

#This file contains small 'helper' functions that dont really belong elsewhere and aren't 
#complex enough to warrant their own file


function Get-MailboxHidden {

    Param(
		[Parameter(ValueFromPipeline = $True, 
				   Mandatory = $True, 
				   Position = 0)]
		[string]$identity
		
	)
	
	#Make sure the Get-RemoteMailbox command is loaded
	try {
		get-command "Get-RemoteMailbox" -erroraction stop > $null
	} catch {
		write-verbose $_
		throw "The Get-RemoteMailbox command is not currently available. Please connect to the OnPrem EMS and try again."
	}
		
	Get-RemoteMailbox -Identity $identity | ft name, HiddenFromAddressListsEnabled

}


function Remove-AllPSSession {
	Get-PSSession | Remove-PSSession
}