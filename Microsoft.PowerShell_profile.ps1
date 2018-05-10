#5/10/2018
#This will dot source any ps1 files in the ConsoleLoad directory into the console when PowerShell is launched
#This is useful to easily test functions from the console host - drop this file at: $profile

$functions = @( Get-ChildItem -Recurse -Path c:\tools\scripting\ConsoleLoad\*.ps1 -ErrorAction SilentlyContinue )
foreach($import in $functions) {
    try {
        . $import.fullname
    } catch {
        write-error -Message "Failed to import function $($import.fullname): $_"
    }
}