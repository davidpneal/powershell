#12/31/2018

function Add-O365License {

	<#
	.SYNOPSIS
	This tool adds a license to an Office 365 user account.
	.DESCRIPTION
	This tool adds an E1 or E3 license and set the usage location for an Office 365 user account.
	.PARAMETER UserPrincipalName
	The User Principle Name for the user that is to have a license assigned.
	.PARAMETER License
	The license type to apply.  Currently the tool will only license for E1 or E3 licenses.  
	Can be specified as E1, E3 or the full names STANDARDPACK, ENTERPRISEPACK.
	.PARAMETER UsageLocation
	The geographical region the user is located.  Microsoft requires this to be set before a license can be applied.
	This parameter is optional, if it not provided the country letter code of the tenant will be assigned as the usage location.
	.EXAMPLE
	Add-O365License -userprincipalname jsmith@company.com -license E1
	Assigns an E1 license to jsmith.  Requires a msol session to be established (MSOnline module).  
	.EXAMPLE
	Add-O365License -userprincipalname jsmith@company.com -license E3 -usageLocation US
	Specifies the usage location (country) for the user.
	.EXAMPLE
	Get-ADUser jsmith -Properties userprincipalname | Add-O365License -license E3
	Add a license to a user via pipeline input.
	#>


	[CmdletBinding(SupportsShouldProcess,
				   ConfirmImpact='Medium')]
	Param(
		[Parameter(Position=0, 
				   Mandatory=$True,
				   ValueFromPipeline=$True)]   #Might need to change this to ValueFromPipelineByPropertyName 
		[string[]]$UserPrincipalName,
		
		[Parameter(Position=1, 
				   Mandatory=$True)]
		[string]$License,			#Validate: E1 (alias to STANDARDPACK), E3 (alias to ENTERPRISEPACK)
		
		[Parameter(Position=2, 
				   Mandatory=$False)]
		[string]$UsageLocation 		#ADD Validate: 2 characters only
	)
	

	BEGIN {
		write-verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"

		
		#Make sure MSOnline is connected
		try {
			#redirect the output of this command to null to suppress the output
			write-verbose "[BEGIN  ] Checking to make sure a connection has been established to Microsoft Online"
			#PROB: call a msolcmd with -erroraction stop > $null
					
		} catch {
			#ALT Decide, call Connect-MsolService automatically?  Use a write-warning, be sure to recheck the connection is working before continuing
			throw "The necessary cmdlets are not currently available. Please connect to Microsoft Online and try again."
		}
		
		
		if (-not $PSBoundParameters.ContainsKey('UsageLocation')) {	##Make sure this works as expected
			write-verbose "UsageLocation not specified, using the Country Letter Code from the company information."
			#Caveat: it is unclear whether the UsageLocation code and CountyLetterCode always match for every region
			
			try {
				$UsageLocation = (Get-MsolCompanyInformation).CountryLetterCode
			} catch {
				throw "Unable to set a default UsageLocation using Get-MsolCompanyInformation"
			}
		}
		
		
		##Get the license string for the selected license - Get-MsolAccountSku
		
		
		##Check to make sure there are enough free licenses --> Do this in Begin??
		
		
	} #BEGIN
		
		
	PROCESS {
		foreach($user in $UserPrincipalName) {
		
		
	
		}
	} #PROCESS
		
		
	END {
		
		
		
		write-verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
	} #END


}