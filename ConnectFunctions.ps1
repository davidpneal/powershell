#Before using, specify the URI of the on-prem exchange server in the Connect-OnPremEMS function
#Note that Basic Authentication must be enabled on the on-prem exchange server's powershell IIS site
#for the Connect-OnPremEMS function to work


#12/15/2016
#This function connects to the Office365 Exchange Tenant powershell interface
Function Connect-Tenant
{
	<#
	.SYNOPSIS
	This function will create a PSSession to the online Office365 Exchange tenant.
	.PARAMETER connectAs
	Used to connect with a different account than specified by the $credUser variable.  Requires a UPN.
	.PARAMETER credential
	Pass a credential object to the function instead of prompting for the username and password.
	.PARAMETER sessionOnly
	Instead of importing the PSSession into the current PowerShell session, it will return the PSSession as an object.
	.EXAMPLE
	Connect-Tenant
	Basic usage.  Will connect to the tenant with the $credUser username set in the PowerShell environment.  If 
	$credUser is not specified, the username will be prompted for.
	.EXAMPLE
	Connect-Tenant -connectAs user@company.com
	Specify a username to use when connecting to the tenant.
	.EXAMPLE
	$tenant = Connect-Tenant -sessionOnly
	Returns a PSSession object with the tenant connection instead of importing it into the current session.
	Note: if there is an error creating the PSSession, it will return a $null variable.
	.EXAMPLE
	Connect-Tenant -credential $cred
	Passes a preexisting PSCredential object named $cred to be used for authenticating to the tenant.
	#>
	
	[cmdletbinding()]
    param(
		[parameter(Mandatory=$false,Position=0)][String]$connectAs = $credUser,
		[pscredential]$credential = $null,
		[switch]$sessionOnly = $false
	)
	
	write-verbose "Calling the ConnectServer function"
		
	$URI = "https://ps.outlook.com/powershell/"
	ConnectServer -URI $URI -connectAs $connectAs -credential $credential -sessionOnly $sessionOnly -exchange
	#Dont need to explictly return the PSSession (if it exists) since PS will return anything left in the pipeline
	
	write-verbose "Exiting the Connect-Tenant function"
}



#12/15/2016
#This function connects to the On Premises Exchange powershell interface
Function Connect-OnPremEMS
{
	<#
	.SYNOPSIS
	This function will create a PSSession to the On Premises Exchange Management Shell.
	.PARAMETER connectAs
	Used to connect with a different account than specified by the $credUser variable.  Requires a UPN.
	.PARAMETER credential
	Pass a credential object to the function instead of prompting for the username and password.
	.PARAMETER sessionOnly
	Instead of importing the PSSession into the current PowerShell session, it will return the PSSession as an object.
	.EXAMPLE
	Connect-OnPremEMS
	Basic usage.  Will connect to the on premises exchange server with the $credUser username set in the PowerShell 
	environment.  If $credUser is not specified, the username will be prompted for.
	.EXAMPLE
	Connect-OnPremEMS -connectAs user@company.com
	Specify a username to use when connecting to the exchange server.
	.EXAMPLE
	$EMS = Connect-OnPremEMS -sessionOnly
	Returns a PSSession object with the EMS connection instead of importing it into the current session.
	Note: if there is an error creating the PSSession, it will return a $null variable.
	.EXAMPLE
	Connect-OnPremEMS -credential $cred
	Passes a preexisting PSCredential object named $cred to be used for authenticating to the exchange server.
	#>
	
	[cmdletbinding()]
    param(
		[parameter(Mandatory=$false,Position=0)][String]$connectAs = $credUser,
		[pscredential]$credential = $null,
		[switch]$sessionOnly = $false
	)
	
	write-verbose "Calling the ConnectServer function"
	
	$URI = "https://server.company.com/powershell"
	ConnectServer -URI $URI -connectAs $connectAs -credential $credential -sessionOnly $sessionOnly -exchange
	#Dont need to explictly return the PSSession (if it exists) since PS will return anything left in the pipeline
	
	write-verbose "Exiting the Connect-OnPremEMS function"
}



#7/12/2016
#This function connects to the Office 365 Tenant powershell interface
#This function requires the MSOnline module to be installed - for the connect-msolservice cmdlet
#Improve: Have the function check and make sure the MSOnline module is installed
Function Connect-O365
{
	$cred = Get-Credential -credential $credUser
	connect-msolservice -credential $cred
}



#4/27/2018
#Private Function
#Used to make the PSSession connection to the specified URI and optionaly load the commands
Function ConnectServer
{
	[cmdletbinding()]
    param(
		[parameter(Mandatory=$true,Position=0)][String]$URI,
		[parameter(Mandatory=$false,Position=1)][String]$connectAs,
		[pscredential]$credential = $null,
		[bool]$sessionOnly = $false,
		[switch]$exchange
	)
	
	if($credential -eq $null) {
		write-verbose "Prompt the user for the password for the specified account"
		try {
			$credential = Get-Credential -credential $($connectAs)
		} catch {
			write-error "There was an error getting the user credential"
			return
		}
	} else {
		write-verbose "A user credential was passed to the ConnectServer function"
	}
	
	write-verbose "Creating the PSSession to the remote server"
	try {
		#If we are connecting to an exchange server, need to connect to the ECP config with Basic auth.  Otherwise use the New-PSSession defaults.
		if($exchange -eq $true) {
			#Calling this with Error Action SilentlyContinue since the error code it generates isnt much use (HTTP 400)
			write-verbose "Function called with the exchange switch, calling New-PSSession with the exchange parameters"
			$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $URI -Credential $credential -Authentication basic -AllowRedirection -ErrorAction SilentlyContinue
		} else {
			write-verbose "Calling New-PSSession with regular parameters"
			$session = New-PSSession -ConnectionUri $URI -Credential $credential
		}
	} catch {
		#This will not catch a bad password: it gives a error 400 but doesnt trigger a catch error since its non-terminating
		write-error "There was an error opening the PSSession to the remote machine"
	}
	
	if($session -eq $null) {
		write-error 'The session has a $null variable which indicates there was an issue creating the PSSession connection.'
	} else {
		if($sessionOnly -eq $false) {
			write-verbose "Importing the PSSession into the current session"
		
			#Setting -Verbose:$False on import-module doesnt suppress output like expected - need to set the VerbosePreference as a workaround
			$origVerbPref = $VerbosePreference
			$VerbosePreference = 'SilentlyContinue' 
		
			#Import-PSSession returns a module object - it must be imported this way so it works when the functions exits (scope)
			Import-Module (Import-PSSession $session -DisableNameChecking) -global -DisableNameChecking
		
			$VerbosePreference = $origVerbPref
		}
	}
	write-verbose "Return the PSSession object and exit the ConnectServer function"
	
	#Note - if the return isnt captured, it will display the PSSession object to host
	return $session
}