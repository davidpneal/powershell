#12/28/2018

function Add-O365License {

	<#
	.SYNOPSIS
	This tool adds a license to an Office 365 user account.
	.DESCRIPTION
	This tool adds an E1 or E3 license and set the usage location for an Office 365 user account.
	.PARAMETER UserPrincipleName
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
	#>


	[CmdletBinding(SupportsShouldProcess,ConfirmImpact='Medium')]
	Param(
		[Parameter(Position=0, 
				Mandatory=$True,
				ValueFromPipeline=$True)]
		[string[]]$UserPrincipleName,
		
		[Parameter(Position=1, 
				Mandatory=$True)]
		[string]$License,			#Validate: E1 (alias to STANDARDPACK), E3 (alias to ENTERPRISEPACK)
		
		[Parameter(Position=2, 
				Mandatory=$False)]
		[string]$UsageLocation 		#ADD Validate: 2 characters only
	)
	

	BEGIN {
		write-verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"

		
		
	} #BEGIN
		
		
	PROCESS {
		

		
	} #PROCESS
		
		
	END {
		
		
		
		write-verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
	} #END


}