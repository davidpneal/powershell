#1/4/2019

function Add-O365License {

	<#
	.SYNOPSIS
	This tool adds a license to an Office 365 user account.
	.DESCRIPTION
	This tool adds an E1 or E3 license and sets the usage location for an Office 365 user account.  It requires the MSOnline
	module to be installed.
	.PARAMETER UserPrincipalName
	The User Principal Name for the user that is to have a license assigned.
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
				   ValueFromPipelineByPropertyName=$True)]  
		[string[]]$UserPrincipalName,
		
		[Parameter(Position=1, 
				   Mandatory=$True)]
		[string]$License,			#Validate: E1 (alias to STANDARDPACK), E3 (alias to ENTERPRISEPACK)
		
		[Parameter(Position=2, 
				   Mandatory=$False)]
		[string]$UsageLocation 		#Validate: 2 characters only
	)
	

	BEGIN {
		write-verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"

		write-verbose "[BEGIN  ] Checking to make sure a connection has been established to Microsoft Online"
		#Capture the output since we can use it later on
		$sku = Get-MsolAccountSku -erroraction stop
		
		
		if (-not $PSBoundParameters.ContainsKey('UsageLocation')) {
			write-verbose "[BEGIN  ] UsageLocation not specified, using the Country Letter Code from the company information."
			#Caveat: it is unclear whether the UsageLocation code and CountyLetterCode always match for every region
			
			try {
				$UsageLocation = (Get-MsolCompanyInformation -erroraction stop).CountryLetterCode
			} catch {
				throw "Unable to set a default UsageLocation using Get-MsolCompanyInformation"
			}
			write-verbose "[BEGIN  ] UsageLocation has been set to $UsageLocation"
		}
		
		
		##Get the license string for the selected license - Get-MsolAccountSku
		
		
		##Check to make sure there are enough free licenses --> Do this in Begin??
		#	IF license is accepted from the pipeline (currently it isnt), anything related to it will need to be moved to process
		#Is this necessary?  MSOnline will probably throw an error if there arent enough licenses
		
		
	} #BEGIN
		
		
	PROCESS {
		foreach($user in $UserPrincipalName) {
		
		###TESTING:
		write-host $userprincipalname
		###
		
	
		}
	} #PROCESS
		
		
	END {
		
		
		
		write-verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
	} #END


}