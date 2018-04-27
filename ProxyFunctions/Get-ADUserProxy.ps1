#4/27/2018
#The purpose of this proxy function is to help deal with old SAM account names that were truncated at 8 characters

#The plan:
#If a provided -identity isnt found, the function will retry with just the first 8 characters in the provided string
#Might see if can make the proxy only kick in when running the console host; just to make sure it doesnt break random scripts

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
			$scriptCmd = {& $wrappedCmd @PSBoundParameters }
			$steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
			$steppablePipeline.Begin($PSCmdlet)
		} catch {
			throw
		}
	}

	process
	{
		try {
			$steppablePipeline.Process($_)
		} catch {
			write-error "This is where the extra error handling goes"
			throw
		}
	}

	end
	{
		try {
			$steppablePipeline.End()
		} catch {
			throw
		}
	}
	<#

	.ForwardHelpTargetName ActiveDirectory\Get-ADUser
	.ForwardHelpCategory Cmdlet

	#>
}