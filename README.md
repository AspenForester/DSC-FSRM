# DSC-FSRM
DSC configuration for File Server Resource Manager

A DSC Configuration to set up FSRM to protect shareed directories from potential ransom-ware attacks. 

# Acknowledgements
Inspired by [Tim Buntrock's contribution to the Script Gallery](https://gallery.technet.microsoft.com/scriptcenter/Protect-your-File-Server-f3722fce) and the further contributions of the commentors.

Visit https://fsrm.experiant.ca/ for more details

# Notes
This configuration creates an event log entry, and in my production environment we have SCOM generate an alert on the event log entry.

I did not opt to use Tim's script to deny access to the share for the user.

There are two examples of psd1 files, one for a single target, and one for a collection of targets.

# Requirements
This configuration requires the FSRMDsc module available from PowerShell Gallery be available on the target server.


