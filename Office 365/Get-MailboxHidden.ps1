#4/27/2018
#This function checks to see if an Office 365 mailbox is hidden.  It requires a connection to the on-prem Exchange Management Shell (EMS)
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