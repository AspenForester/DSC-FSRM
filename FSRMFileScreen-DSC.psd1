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