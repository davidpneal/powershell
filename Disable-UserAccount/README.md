# Disable-UserAccount

This is a template for a user decommissioning script which can be modified or expanded to fit a specific environment.  It is setup to integrate with Office 365 for the email components.  It will handle the following items:

* Record the Active Directory groups the user is a member of to a file and then remove the groups from the account.
* Optionally delegate access to the Office 365 mailbox to a specified user.
* If the mailbox is not delegated, it will hide the mailbox from the Global Address List.
* Mark the date the account was disabled in the description.
* Disable the Active Directory account.
* Move the account to a 'Disabled Users' OU.

### Requirements: 
* Connect Functions - these functions handle the connections to the Office 365 environment.  They are available under the PowerShell\Office 365 folder.
* If the script will delegate user accounts, the Set-MailboxDelegation function from the Office 365 folder will also need to be available.
* Active Directory module.
