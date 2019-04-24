Configuration FileGroupAndTemplate
{
    Import-DscResource -ModuleName FSRMDsc

    $Filters = @((Invoke-WebRequest -Uri "https://fsrm.experiant.ca/api/v1/combined" -UseBasicParsing).content `
            | convertfrom-json `
            | ForEach-Object {$_.filters})
    Write-Verbose ("{0} items filtered by Experiant.ca" -f $Filters.Count)

    Node $AllNodes.NodeName
    {
        WindowsFeature FSRM
        {
            Ensure = "Present"
            Name = "FS-Resource-Manager"
        }
        
        FSRMFileGroup FSRMFileGroupRansomwareFiles
        {
            Name = 'Experiant Ransomware Files'
            Description = 'files and extenstions associated with Ransomware attacks'
            Ensure = 'Present'
            IncludePattern = $Filters
            DependsOn = "[WindowsFeature]FSRM"
        } 

        FSRMFileGroup FSRMFileGroupExceptions
        {
            Name = 'Exceptions'
            Description = 'Files and extensions that we agree should not trigger an alert'
            Ensure = 'Present'
            IncludePattern = '*.key','readme.txt','*.one'
        }

        FSRMFileScreenTemplate FileScreenRansomware
        {
            Name = "Block Ransomware Files"
            Description = "File Screen to block Ransomware files and extenstions"
            Ensure = 'Present'
            Active = $true
            IncludeGroup = 'Experiant Ransomware Files'
            DependsOn = "[FSRMFileGroup]FSRMFileGroupRansomwareFiles"
        }

        FSRMFileScreenTemplateAction FileScreenRansomwareEvent
        {
            Name = "Block Ransomware Files"
            Ensure = 'Present'
            Type = 'Event'
            Body = 'The system detected that user [Source Io Owner] attempted to save [Source File Path] on [File Screen Path] on server [Server]. This file matches the [Violated File Group] file group which is not permitted on the system.'
            EventType = 'Warning'
            DependsOn = '[FSRMFileScreenTemplate]FileScreenRansomware'
        }
        
        foreach ($path in $Node.paths)
        {
            $Name = "FSRMFileScreen_$($path.split('\')[1,2] -join(''))"
            FSRMFileScreen $Name
            {
                Path = $path
                Description = 'File Screen blocking Ransomware files'
                Ensure = 'Present'
                Template = "Block Ransomware Files"
                MatchesTemplate = $true
                DependsOn = "[FSRMFileScreenTemplate]FileScreenRansomware",
                            "[FSRMFileScreenTemplateAction]FileScreenRansomwareEvent"
            }

            # add an exception item here
            $Name = "FileScreenExceptions_$($path.split('\')[1,2] -join(''))"
            FSRMFileScreenException $Name
            {
                Path = $path
                Description = "Exceptions to the downloaded File Group"
                Ensure = 'Present'
                IncludeGroup = 'Exceptions'
                DependsOn = '[FSRMFileGroup]FSRMFileGroupExceptions'
            }
        }
    }
}

$DSCPath = "C:\Users\jole001\OneDrive - Hennepin County\WindowsPowerShell\DSC"


FileGroupAndTemplate -OutputPath "$DSCPath\FSRM" `
                         -ConfigurationData "$DSCPath\FSRM\FSRMFileScreen-DSC.psd1" `
                         -verbose

$Creds = Get-Credential -Credential hc_Acct\lajole001
#$computername = 'itinfdw002'
Start-DscConfiguration -Force -Wait -Path "$DSCPath\FSRM"  -Verbose -Credential $Creds
#test-DscConfiguration -Force -Wait -Path "$DSCPath\FSRM"  -Verbose
