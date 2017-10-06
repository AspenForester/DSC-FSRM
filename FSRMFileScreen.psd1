@{
    AllNodes =
    @(
        #All Nodes 
        @{
            NodeName = "*"
            # Anything all the nodes would have in common
            # Not used if a node explicitly defines this property
            Paths = @("T:\")
        },
        @{
            NodeName = 'ServerA'
        },
        @{
            NodeName = 'ServerB'
        },
        @{
            NodeName = 'ServerC'
        },
        @{
            NodeName = 'ServerD'
        },
        @{
            NodeName = 'ServerE'
            Paths = @("T:")
        },
        @{
            NodeName = 'ServerF'
        },
        @{
            NodeName = 'ServerG'
            paths = @('T:\CIEx\Home','T:\CIEx\Team','T:\COMM\Home','T:\COMM\Team')
        },
        @{
            NodeName = 'ServerH'
        },
        @{
            NodeName = 'ServerI'
        },
        @{
            NodeName = 'ServerJ'
           # paths = @('T:','D:')
        }
    );
}