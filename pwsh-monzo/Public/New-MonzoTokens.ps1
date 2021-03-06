function New-MonzoTokens {
    <#
    .SYNOPSIS
        Obtain a new Monzo access token or refresh token.
    
    .DESCRIPTION
        Obtain a new Monzo access token or refresh token from the Monzo bank API.
    
    .PARAMETER MonzoAuthorisationCode
        A MonzoAPI.OAuth.AuthorisationCode PSCustomObject. Obtained from New-MonzoAuthorisationCode.
    
    .PARAMETER ClientCredential
        A System.Management.Automation.PSCredential object containing the apps client ID and client secret as username and password.
    
    .PARAMETER MonzoRefreshToken
        A Monzo refresh token.
    
    .PARAMETER RefreshToken
        A switch which redirects code flow for obtaining a new access and refresh token with a previous refresh token.
    
    .EXAMPLE
        # Usage when getting tokens for the first time.
        $AuthorisationCode = New-MonzoAuthorisationCode -MonzoApplication $MonzoApplication -Email "foobar@somemail.com"
        $MonzoTokens = New-MonzoTokens -MonzoAuthorisationCode $AuthorisationCode 
    
    .EXAMPLE
        # Usage when refreshing.
        $Credentials = Get-Credentials
        # Or
        $ClientId = "ClientID"
        $ClientSecret = ConvertTo-SecureString -String "SuperSecretClientSecret" -AsPlainText -Force
        $Credentials = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $ClientId, $ClientSecret
        $MonzoRefreshToken = "Previous refresh token here."
        $MonzoTokens = New-MonzoTokens -ClientCredential $Credentials -MonzoRefreshToken $MonzoRefreshToken -RefreshToken
    
    .NOTES
        Use both MonzoAuthorisationCode and MonzoRefreshToken parameters when obtaining an access and refresh token for the first time.
        For refreshing, ensure you provide the -RefreshToken switch.
        https://docs.monzo.com/#acquire-an-access-token
    #>
    [CmdletBinding()]
    [OutputType("MonzoAPI.OAuth.Tokens")]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Alias("MonzoAuth")]
        [PSTypeName("MonzoAPI.OAuth.AuthorisationCode")]
        $MonzoAuthorisationCode,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $ClientCredential,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $MonzoRefreshToken,

        [Parameter(Mandatory = $false)]
        [Switch]
        $RefreshToken
    )

    begin {

        if ($MonzoAuthorisationCode) {
            # Before doing anything, check that the PSCustomObject contains clientID, client secret and an auththorisation code.
            if (-not ($MonzoAuthorisationCode.MonzoApplication.ClientCredential.UserName -and $MonzoAuthorisationCode.MonzoApplication.ClientCredential.Password -and $MonzoAuthorisationCode.AuthorisationCode)) {
                Write-Error -Message "ClientId, client secret and authorisation code weren't present in MonzoAPI.Oauth.AuthorisationCode." -ErrorAction "Stop"
            }
        }
    
    }

    process {

        try {
            # Initalise request parameters.
            # If switch is or isn't supplied, set $RequestBody accordingly.
            $RequestBody = switch ($RefreshToken) {
                $true {
                    Write-Verbose -Message "Refresh token flow."
                    @{
                        grant_type    = "refresh_token" 
                        client_id     = $ClientCredential.UserName
                        client_secret = $ClientCredential.GetNetworkCredential().Password
                        refresh_token = $MonzoRefreshToken
                    }
                }
                $false {
                    Write-Verbose -Message "Authorisation code flow."
                    @{
                        grant_type    = "authorization_code" 
                        client_id     = $MonzoAuthorisationCode.MonzoApplication.ClientCredential.UserName
                        client_secret = $MonzoAuthorisationCode.MonzoApplication.ClientCredential.GetNetworkCredential().Password
                        redirect_uri  = $MonzoAuthorisationCode.MonzoApplication.RedirectUri
                        code          = $MonzoAuthorisationCode.AuthorisationCode
                    }
                }
            }
            # Make POST request to Monzo API to retrieve an access and refresh token.
            $Response = Invoke-RestMethod -Method "POST" -Uri "https://api.monzo.com/oauth2/token" -Body $RequestBody -ContentType "application/x-www-form-urlencoded" -Verbose:($PSBoundParameters["Verbose"] -eq $true) -ErrorAction "Stop"
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }

    end {

        # Populate PSCustomObject MonzoAPI.OAuth.Tokens.
        return [PSCustomObject]@{
            PSTypeName    = "MonzoAPI.OAuth.Tokens"
            AccessToken   = $Response.access_token
            RefreshToken  = $Response.refresh_token
            UserId        = $Response.user_id
            ExpiresIn     = $Response.expires_in
            TokenType     = $Response.token_type
            IssueDateTime = (Get-Date)
        }
    }
}
