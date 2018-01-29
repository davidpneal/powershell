#1/26/2018

function Format-UserGroups {

	[cmdletbinding()]
	Param(
		[Parameter(ValueFromPipeline = $True, 
				   Mandatory = $True, 
				   Position = 0)]
		[string[]]$identity
	)
	

	BEGIN {}
	
    PROCESS {
	
	} #PROCESS
	
	END {}
}
