Configuration TestFileGroupAndTemplate
{
    
    Import-DscResource -ModuleName FSRMDsc

    Node $AllNodes.NodeName
    {
        
        $Filters = @((Invoke-WebRequest -Uri "https://fsrm.experiant.ca/api/v1/combined" -UseBasicParsing).content `
            | convertfrom-json `
            | ForEach-Object {$_.filters}) 
        
        FSRMFileGroup FSRMFileGroupRansomwareFiles
        {
            Name = 'Ransomware Files'
            Description = 'files and extenstions associated with Ransomware attacks'
            Ensure = 'Present'
            IncludePattern = $Filters
        } 

        FSRMFileGroup FSRMFileGroupExceptions
        {
            Name = 'Hennepin Exceptions'
            Description = 'Files and extensions that we agree should not trigger an alert'
            Ensure = 'Present'
            IncludePattern = '*.key','readme.txt'
        }

        FSRMFileScreenTemplate FileScreenRansomware
        {
            Name = "Block Ransomware Files"
            Description = "File Screen to block Ransomware files and extenstions"
            Ensure = 'Present'
            Active = $true
            IncludeGroup = 'Test - Ransomware Files'
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
                DependsOn = "[FSRMFileScreenTemplate]FileScreenRansomware","[FSRMFileScreenTemplateAction]FileScreenRansomwareEvent"
            }

            # add an exception item here
            FSRMFileScreenException FileScreenRansomwareExceptions
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

$Webdata = $Filters = @((Invoke-WebRequest -Uri "https://fsrm.experiant.ca/api/v1/combined" -UseBasicParsing).content `
            | convertfrom-json `
            | ForEach-Object {$_.filters}) 

$myData =
@{
    AllNodes =
    @(
        #All Nodes 
        @{
            NodeName = "*"
            # Anything all the nodes would have in common
            Paths = @("T:\")
            Filters = $Webdata
        },

        @{
            NodeName = "hhfsrpw001"
            #Paths = @("T:\hhxx\Home","T:\hhxx\Team")
        },
        @{
            NodeName = 'bffsrpw001'
            #Paths = @("\\bffsrpw001\t$\APEX\Team","\\bffsrpw001\t$\APEX\ViewDirect","\\bffsrpw001\t$\BFAS\Home","\\bffsrpw001\t$\BFAS\Team","\\bffsrpw001\t$\BFAT\Team","\\bffsrpw001\t$\PTCS\Team")
        },
        @{
            NodeName = 'ccfsrpw001'
        },
        @{
            NodeName = 'esfsrpw001'
        },
        @{
            NodeName = 'esinfpw001'
        },
        @{
            NodeName = 'hsfsrpw001'
        },
        @{
            NodeName = 'itfsrpw001'
        },
        @{
            NodeName = 'itinfpw022'
        }
    );
}


$DSCPath = "\\hcgg\lobroot\itxx\home\jole001\WindowsPowerShell\DSC"

TestFileGroupAndTemplate -OutputPath "$DSCPath\FSRM" -ConfigurationData "$DSCPath\FSRM\FSRMFileScreen-dsc.psd1" -verbose

$computername = 'itinfdw002'
Start-DscConfiguration -Force -Wait -Path "$DSCPath\FSRM"  -Verbose -ComputerName itinfdw002

test-DscConfiguration -Force -Wait -Path "$DSCPath\FSRM"  -Verbose
