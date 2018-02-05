#2/5/2018

function Format-UserGroups {

	[cmdletbinding()]
	Param(
		[Parameter(ValueFromPipeline = $True, 
				   Mandatory = $True, 
				   Position = 0)]
		[string[]]$identity
	)
	

	BEGIN {
		write-verbose "[BEGIN ] Starting: $($MyInvocation.Mycommand)"
		
		write-verbose "[BEGIN ] Test to see if the Active Directory module is already loaded in the current session."
		if (Get-Module -Name "ActiveDirectory") {
			write-verbose "[BEGIN ] The Active Directory module was already loaded in the current session."
		} else {
			write-verbose "[BEGIN ] The Active Directory module is not currently loaded, attempting to load it now."
			Import-Module ActiveDirectory -verbose:$false -erroraction stop
		}
	} # BEGIN
	
	
    PROCESS {
	
	
	} # PROCESS
	
	
	END {
		write-verbose "[END   ] Ending: $($MyInvocation.Mycommand)"
	} # END
}
