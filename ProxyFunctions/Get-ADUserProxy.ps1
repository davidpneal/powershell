#5/14/2018
#The purpose of this proxy function is to help deal with old SAM account names that were truncated at 8 characters
#If a provided -identity isnt found, the function will retry with just the first 8 characters in the provided string

#Caveat: this will essentially create a second Get-ADUser command - when "help get-aduser" is run, help will return a list 
#  of the 2 commands instead of displaying the help page.  Can work around this by adding: -Category Cmdlet to the help call


function Get-ADUser {

	[CmdletBinding(DefaultParameterSetName='Filter', HelpUri='http://go.microsoft.com/fwlink/?LinkId=301397')]
	param()


	dynamicparam
	{
		try {
			$targetCmd = $ExecutionContext.InvokeCommand.GetCommand('ActiveDirectory\Get-ADUser', [System.Management.Automation.CommandTypes]::Cmdlet, $PSBoundParameters)
			$dynamicParams = @($targetCmd.Parameters.GetEnumerator() | Microsoft.PowerShell.Core\Where-Object { $_.Value.IsDynamic })
			if ($dynamicParams.Length -gt 0)
			{
				$paramDictionary = [Management.Automation.RuntimeDefinedParameterDictionary]::new()
				foreach ($param in $dynamicParams)
				{
					$param = $param.Value

					if(-not $MyInvocation.MyCommand.Parameters.ContainsKey($param.Name))
					{
						$dynParam = [Management.Automation.RuntimeDefinedParameter]::new($param.Name, $param.ParameterType, $param.Attributes)
						$paramDictionary.Add($param.Name, $dynParam)
					}
				}
				return $paramDictionary
			}
		} catch {
			throw
		}
	}

	
	begin
	{
		try {
			$outBuffer = $null
			if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
			{
				$PSBoundParameters['OutBuffer'] = 1
			}
			$wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('ActiveDirectory\Get-ADUser', [System.Management.Automation.CommandTypes]::Cmdlet)
			$scriptCmd = {& $wrappedCmd @PSBoundParameters}
			$steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
			$steppablePipeline.Begin($PSCmdlet)
		} catch {
			throw
		}
	} #BEGIN

	
	process
	{
		try {
			$steppablePipeline.Process($_)
		} catch {
		
			#Get the string value of the identity key from PSBoundParameters
			$ident = $PSBoundParameters['identity'].tostring()
			
			#If the identity string was less than 8 characters or if there is a '@' in the string (UPN address), no need to do anyting else
			if (($ident.length -gt 8) -and !($ident.contains('@')))  {
			
				$shortIdent = $ident.substring(0,8)
			
				#Update the identity key value
				#The .remove method will output 'True' when called, redirect this to $null
				$PSBoundParameters.Remove('identity') > $null
				$PSBoundParameters.Add('identity', $shortIdent) 
				
				Write-warning "Cannot find an object with identity: $ident; trying again with $shortIdent"
				
				#Call Get-ADUser with the truncated identity string
				try {
			
					$outBuffer = $null
					if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
					{
						$PSBoundParameters['OutBuffer'] = 1
					}
					$wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('ActiveDirectory\Get-ADUser', [System.Management.Automation.CommandTypes]::Cmdlet)
					$scriptCmd = {& $wrappedCmd @PSBoundParameters}
					$steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
					$steppablePipeline.Begin($PSCmdlet)
									
				} catch {
					throw
				}
			}
			
		}
	} #PROCESS


	end
	{
		try {
			$steppablePipeline.End()
		} catch {
			throw
		}
	} #END
	<#

	.ForwardHelpTargetName ActiveDirectory\Get-ADUser
	.ForwardHelpCategory Cmdlet

	#>
}