Configuration TestFileGroupAndTemplate
{
    
    Import-DscResource -ModuleName FSRMDsc

    # I should provide an attribution for this 
    $Filters = @((Invoke-WebRequest -Uri "https://fsrm.experiant.ca/api/v1/combined" -UseBasicParsing).content `
            | convertfrom-json `
            | ForEach-Object {$_.filters}) 

    Node $AllNodes.NodeName
    {
        FSRMFileGroup FSRMFileGroupRansomwareFiles
        {
            Name = 'Experiant Ransomware Files'
            Description = 'files and extenstions associated with Ransomware attacks'
            Ensure = 'Present'
            IncludePattern = $Filters
        } 

        FSRMFileGroup FSRMFileGroupExceptions
        {
            Name = 'Hennepin Exceptions'
            Description = 'Files and extensions that we agree should not trigger an alert'
            Ensure = 'Present'
            IncludePattern = '*.key', 'readme.txt'
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
                DependsOn = "[FSRMFileScreenTemplate]FileScreenRansomware", "[FSRMFileScreenTemplateAction]FileScreenRansomwareEvent"
            }

            # add an exception item here
            $Name = "FileScreenExceptions_$($path.split('\')[1,2] -join(''))"
            FSRMFileScreenException $Name
            {
                Path = $path
                Description = "Exceptions to the downloaded File Group"
                Ensure = 'Present'
                IncludeGroup = 'Hennepin Exceptions'
                DependsOn = '[FSRMFileGroup]FSRMFileGroupExceptions'
            }
        }
    }
}

$DSCPath = "\\hcgg.fr.co.hennepin.mn.us\lobroot\itxx\home\jole001\WindowsPowerShell\DSC"

TestFileGroupAndTemplate -OutputPath "$DSCPath\FSRM" -ConfigurationData "$DSCPath\FSRM\FSRMFileScreen-DSC.psd1" -verbose


Start-DscConfiguration -Force -Wait -Path "$DSCPath\FSRM"  -Verbose -ComputerName itinfpw022
