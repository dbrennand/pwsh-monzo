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
    
    .PARAMETER RedirectUri
        The redirect URI to use for the application.
    
    .PARAMETER StateToken
        The state token used to protect against cross-site request forgery. If one isn't provided, one is generated for you.
    
    .EXAMPLE
        $Credentials = Get-Credential
        $MonzoApplication = New-MonzoApplication -Name "MyMonzoApp" -ClientCredential $Credentials
    
    .EXAMPLE
        $Credentials = Get-Credential
        $StateToken = [Guid]::NewGuid()
        $MonzoApplication = New-MonzoApplication -Name "MyMonzoApp" -ClientCredential $Credentials -RedirectUri "https://foobar.com/oauth/callback" -StateToken $StateToken
    
    .EXAMPLE
        $ClientId = "ClientID"
        $ClientSecret = ConvertTo-SecureString -String "SuperSecretClientSecret" -AsPlainText -Force
        $Credentials = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $ClientId, $ClientSecret
        $StateToken = [Guid]::NewGuid()
        $MonzoApplication = New-MonzoApplication -Name "MyMonzoApp" -ClientCredential $Credentials -RedirectUri "https://foobar.com/oauth/callback" -StateToken $StateToken
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
        $RedirectUri = "https://localhost:8888/oauth/callback",

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Guid]
        $StateToken = [Guid]::NewGuid()
    )

    Process {

        [PSCustomObject]@{
            PSTypeName       = "MonzoAPI.Application"
            Name             = $Name
            ClientCredential = $ClientCredential
            RedirectUri      = $RedirectUri
            StateToken       = $StateToken
        }
    }
}
