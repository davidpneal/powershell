# Office 365 Administration Tooling

This is a collection of tools to help with administrating the Office 365 environment.  The tooling is mostly geared around Exchange, but there are some functions geared around user administration and ease of use.

## Functions

### Add-O365License
Not yet complete.  This tool will assign licensing to Azure AD (MS Online) users.

### ConnectFunctions
This is a set of functions that are used to connect to the various Office 365 services.  These functions are:
* Connect-Tenant - to connect to the Office 365 Exchange Tenant.
* Connect-OnPremEMS - to connect to the on premises hybrid exchange server.  Please note that this function will require the address of your server to be set.
* Connect-O365 - calls connect-msolservice to connect to the MS Online service.  Requires the MSOnline module.

### Get-MailboxDelegation
This tool is used to view the assigned permissions on an Office 365 mailbox.

### Get-MailboxHidden
This function checks to see if an Office 365 mailbox is hidden.  It requires an established connection to the on-prem Exchange Management Shell (EMS).

### Set-MailboxDelegation
This tool is used to delegate access of an Office 365 mailbox to another user.

### Set-MailboxHidden
This command can be used to hide or unhide a mailbox from the global address list.

### Tenant Migration
Some quick scripts to aid in migrating users to the Office 365 environment.