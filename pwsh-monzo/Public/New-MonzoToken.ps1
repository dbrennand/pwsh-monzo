function New-MonzoTokens {
    <#
    .SYNOPSIS
        Obtain a new Monzo access token and refresh token.
    
    .DESCRIPTION
        Obtain a new Monzo access token and refresh token from the Monzo bank API.
    
    .PARAMETER MonzoAuthorisationCode
        A MonzoAPI.OAuth.AuthorisationCode PSCustomObject. Obtained from Get-MonzoAuthorisationCode.
    
    .EXAMPLE
        $AuthorisationCode = $MonzoApplication | New-MonzoAuthorisationCode -Email "foobar@somemail.com"
        $MonzoTokens = $AuthorisationCode | New-MonzoTokens
        
    .EXAMPLE
        $AuthorisationCode = New-MonzoAuthorisationCode -MonzoApplication $MonzoApplication -Email "foobar@somemail.com"
        $MonzoTokens = New-MonzoTokens -MonzoAuthorisationCode $AuthorisationCode
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType("MonzoAPI.OAuth.Tokens")]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("MonzoAuth")]
        [PSTypeName("MonzoAPI.OAuth.AuthorisationCode")]
        $MonzoAuthorisationCode
    )

    begin {

        # Before doing anything, check that the PSCustomObject contains clientID, clientsecret and an auththorisation code.
        if (-not ($MonzoAuthorisationCode.MonzoApplication.ClientCredential.UserName -and $MonzoAuthorisationCode.MonzoApplication.ClientCredential.Password -and $MonzoAuthorisationCode.AuthorisationCode)) {
            Write-Error -Message "ClientId, clientsecret and authorisation code weren't present in MonzoAPI.Oauth.AuthorisationCode." -ErrorAction "Stop"
        }
    
    }

    process {

        # Make POST request to Monzo API to retrieve an access and refresh token.
        $RequestBody = @{
            grant_type = "authorization_code" 
            client_id = $MonzoAuthorisationCode.MonzoApplication.ClientCredential.UserName
            client_secret = $MonzoAuthorisationCode.MonzoApplication.ClientCredential.Password
            redirect_uri = $MonzoAuthorisationCode.MonzoApplication.RedirectUri
        }
        Invoke-RestMethod -Method "POST" 
    }

}