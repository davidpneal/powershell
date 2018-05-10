#5/10/2018
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
			
			#Get the string value of the identity key from PSBoundParameters
			$val = $PSBoundParameters['identity'].tostring()
			
			#Get the first 8 characters (this blows up if the string is less than 8 characters)
			$val2 = $val.substring(0,8)
			
			
			#Update the identity key value
			#Fix - one of these commands displays 'True' to the console
			$PSBoundParameters.Remove('identity')
			$PSBoundParameters.Add('identity', $val2)
			
			#verify (testing)
			$newval = $PSBoundParameters['identity'].tostring()
			
			write-output "val = $val"
			write-output "newval = $newval"
			
			
			#try again - not sure if this is a valid way of doing this - might break the pipeline
			#Note - this works and gets the truncated identity but still throws the original error 
			Write-warning "$val not found, trying again with $val2"
			try {
				get-aduser @PSBoundParameters
			} catch {
				throw
			}
			
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