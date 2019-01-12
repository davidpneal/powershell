# PowerShell

An assortment of PowerShell tools and functions, primarily for Windows and Office 365 administration.  Most of the more complex tools have help information that can provide additional information.  The Pester unit tests are currently in various states of functionality and do not all work correctly.

## Functions

### Disable-UserAccount
This is a template for a user decommissioning script - see the project for more information.

### Format-UserGroups
Outputs a formatted list of the active directory groups the specified user belongs to.

### Get-PasswordExpiration
This tool will calculate the password expiration date for an AD user.

### ProxyFunctions
Currently a single function that proxies Get-ADUser to help manage old SAM account names.  Adds functionality to the command so it will try the username again with just the first 8 characters if the original input is not found.

### Microsoft.PowerShell_profile.ps1
This will dot source any ps1 files in the ConsoleLoad directory into the console when PowerShell is launched.  This is useful to easily test functions from the console host - drop this file at: $profile

## Cryptolocker mitigation tooling

A pair of tools to help manage cryptolocker threats.

### CryptoBlocker
Not yet complete.  This script builds on the work at https://fsrm.experiant.ca/ and will automatically deny share permissions to a user if it looks like they are performing a cryptolocker attack.

### Remove-CryptoBlocker
A tool to unlock a user account (remove share deny ACE's) once the machine has been verified to be clean.