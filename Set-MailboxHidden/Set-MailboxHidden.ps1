#1/26/2018

function Set-MailboxHidden {

	[CmdletBinding(SupportsShouldProcess,
				   ConfirmImpact='Low')]
			
	Param(
		[Parameter(ValueFromPipeline = $True, 
				   Mandatory = $True, 
				   Position = 0)]
		[string[]]$identity,
		
		[string]$pssession = $null,
		
		[switch]$unhide = $False
	)


	BEGIN {
	
	} #BEGIN
	
	
    PROCESS {
	
	} #PROCESS
	
	
	END {
	
	} #END
}
