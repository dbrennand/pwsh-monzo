function New-MonzoApplication {
    <#
    .SYNOPSIS
        Create a Monzo API application.
    
    .DESCRIPTION
        Creates a Monzo API application, used to authenticate with the Monzo Bank API.
    
    .PARAMETER Name
        The name of the Monzo application.
    
    .PARAMETER ClientCredential
        A System.Management.Automation.PSCredential object containing the apps client ID and client secret as username and password.
    
    .PARAMETER RedirectURI
        The redirect URI to use for the application.
    
    .PARAMETER Guid
        The GUID (state token) used to protect against cross-site request forgery. If one isn't provided, one is generated for you.
    
    .EXAMPLE
        $Credentials = Get-Credential
        $MonzoApplication = New-MonzoApplication -Name "MyMonzoApp" -ClientCredential $Credentials
    
    .EXAMPLE
        $Credentials = Get-Credential
        $MyGuid = [Guid]::NewGuid()
        $MonzoApplication = New-MonzoApplication -Name "MyMonzoApp" -ClientCredential $Credentials -RedirectURI "https://foobar.com/oauth/callback" -Guid $MyGuid
    
    .EXAMPLE
        $ClientId = "ClientID"
        $ClientSecret = ConvertTo-SecureString -String "SuperSecretClientSecret" -AsPlainText -Force
        $Credentials = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $ClientId, $ClientSecret
        $MyGuid = [Guid]::NewGuid()
        $MonzoApplication = New-MonzoApplication -Name "MyMonzoApp" -ClientCredential $Credentials -RedirectURI "https://foobar.com/oauth/callback" -Guid $MyGuid
    #>
    [OutputType("MonzoAPI.Application")]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $ClientCredential,

        [Parameter(Mandatory = $false)]
        # https://docs.microsoft.com/en-us/dotnet/api/system.urikind?view=netframework-4.8#fields
        [ValidateScript( { [System.Uri]::IsWellFormedUriString($_, [System.UriKind]::Absolute) })]
        [String]
        $RedirectURI = "https://localhost:8888/oauth/callback",

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Guid]
        $Guid = [Guid]::NewGuid()
    )

    Process {

        [PSCustomObject]@{
            PSTypeName       = "MonzoAPI.Application"
            Name             = $Name
            ClientCredential = $ClientCredential
            RedirectURI      = $RedirectURI
            Guid             = $Guid
        }
    }
}