#3/25/2019
#This script will disable ActiveSync for a set of users - the input is provided as a migration batch name

function Disable-ActiveSyncBatch {
	

	[cmdletbinding()]
	Param(
		[Parameter(Mandatory = $True, 
				   Position = 0)]
		[string]$BatchId,
		[switch]$OutputOnly = $false
	)

	
	#Make sure the tenant commands are loaded
	$cmdlets = "Get-MigrationUser", "Set-CASMailbox"
	try {
		get-command $cmdlets -erroraction stop > $null
	} catch {
		throw "The necessary mailbox commands are not currently available. Please connect to the Exchange Tenant and try again."
	}


	#Populate the variables, stop the script if something fails
	try {
		$batch = Get-MigrationUser -BatchId $BatchId -erroraction stop | select identity
	} catch {
		throw $_
		return
	}
	

	#Disable ActiveSync for the accounts
	if($OutputOnly -eq $false){
		$batch | Set-CASMailbox -ActiveSyncEnabled $False  
	}
}