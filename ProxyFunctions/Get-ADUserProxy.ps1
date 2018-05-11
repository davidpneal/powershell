#5/11/2018
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
			$scriptCmd = {& $wrappedCmd @PSBoundParameters}
			$steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
			$steppablePipeline.Begin($PSCmdlet)
		} catch {
			write-output "1 begin catch block"
			throw
		}
		write-output "2 begin block end"
	}

	process
	{
		write-output "3 process block start"
		try {
			$steppablePipeline.Process($_)
		} catch {
			
						
			#Get the string value of the identity key from PSBoundParameters
			$val = $PSBoundParameters['identity'].tostring()
			
			#Get the first 8 characters (this blows up if the string is less than 8 characters)
			$val2 = $val.substring(0,8)
			
			
			#Update the identity key value
			#The .remove method will output 'True' when called, redirect this to $null
			$PSBoundParameters.Remove('identity') > $null
			$PSBoundParameters.Add('identity', $val2) 
			
			#verify (testing)
			$newval = $PSBoundParameters['identity'].tostring()
			
			#write-output "val = $val"
			#write-output "newval = $newval"
			
			
			#try again - not sure if this is a valid way of doing this - might break the pipeline
			#Note - this works and gets the truncated identity but still throws the original error 
			Write-warning "$val not found, trying again with $val2"
			try {
				write-output "4 calling get-aduser again"
				#get-aduser @PSBoundParameters
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
					write-output "99 begin catch block"
					throw
				}
			} catch {
				write-output "5 catch from re-call"
				throw
			}
			
			write-output "6 catch from process block - end"
		}
		write-output "7 end of process block"
		
	}


	end
	{
		write-output "8 end block start"
		
		try {
			#$global:error.clear()
			#write-output "end block error count: $error.count"
			#write-output "end block error 0: $error[0]"
			#write-output "end block  global error 0: $global:error[0]"
			write-output "9 calling the end steppablePipeline"
			$steppablePipeline.End()
			write-output "10 after calling the end steppablePipeline"
		} catch {
			write-output "11 catch from end block"
			throw
			#THIS is where the throw message from the original error comes from -> $steppablePipeline.End() generates an error when called
			#this probably isnt valid to comment out - seems to go into an infinite re-call loop without it (TEST MORE)
			
		}
		write-output "12 end of end block"
	}
	<#

	.ForwardHelpTargetName ActiveDirectory\Get-ADUser
	.ForwardHelpCategory Cmdlet

	#>
}