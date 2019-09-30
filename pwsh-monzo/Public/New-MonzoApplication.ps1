function New-MonzoApplication {
    <#
    .SYNOPSIS
        Create a Monzo API application.
    
    .DESCRIPTION
        Creates a Monzo API application to authenticate with the Monzo Bank API.
    
    .PARAMETER Name
        The name of the Monzo application.
    
    .PARAMETER ClientCredential
        A Get-Credentials object containing the apps client ID and secret as user and password.
    
    .PARAMETER RedirectURI
        The redirect URI to use for the application.
    
    .EXAMPLE
        New-MonzoApplication -Name "MyMonzoApp"
    
    .EXAMPLE
        $Credentials = Get-Credential
        New-MonzoApplication -Name "MyMonzoApp" -ClientCredential $Credentials -RedirectURI "https://foobar.com"
    
    #>
    [OutputType("MonzoAPI.Application")]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $ClientCredential,

        [Parameter(AttributeValues)]
        [ParameterType]
        $ParameterName
    )
    
    begin {
        
    }
    
    process {
        
    }
    
    end {
        
    }
}