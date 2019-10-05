function New-MonzoAuthorisationCode {
    <#
    .SYNOPSIS
        Obtain a new authorisation code from the Monzo API.
    
    .DESCRIPTION
        Obtain a new authorisation code from the Monzo API which can be exchanged for an access token.
    
    .PARAMETER MonzoApplication
        A Monzo application - created using New-MonzoApplication.
    
    .PARAMETER Email
        The email address used during the authentication process to retrieve the authorisation code.
    
    .EXAMPLE
        $MonzoApplication = New-MonzoApplication -Name "MyMonzoApp" -ClientCredential $Credentials -RedirectUri "https://foobar.com/oauth/callback" -StateToken $StateToken
        $AuthorisationCode = $MonzoApplication | New-MonzoAuthorisationCode -Email "foobar@somemail.com"
    
    .EXAMPLE
        $MonzoApplication = New-MonzoApplication -Name "MyMonzoApp" -ClientCredential $Credentials -RedirectUri "https://foobar.com/oauth/callback" -StateToken $StateToken
        $AuthorisationCode = New-MonzoAuthorisationCode -MonzoApplication $MonzoApplication -Email "foobar@somemail.com"
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType("MonzoAPI.OAuth.AuthorisationCode")]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("MonzoApp")]
        [PSTypeName("MonzoAPI.Application")]
        $MonzoApplication,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                try {
                    $null = [MailAddress]$_
                }
                catch {
                    Write-Error -Message "The email string: $_ is not a valid email address." -ErrorAction "Stop"
                }
            })]
        [String]
        $Email
    )
    
    begin {

        # Before doing anything, check that the PSCustomObject contains clientID and clientSecret.
        if (-not ($MonzoApplication.ClientCredential.UserName -and $MonzoApplication.ClientCredential.Password)) {
            Write-Error -Message "ClientId and clientsecret weren't present in MonzoAPI.Application." -ErrorAction "Stop"
        }

        # Check if Selenium is installed on the host.
        if (Get-Module -ListAvailable -Name "Selenium") {
            Import-Module -Name "Selenium"
        }
        else {
            Write-Error -Message "Selenium isn't installed, attempting to install..."
            try {
                Install-Module -Name "Selenium" -RequiredVersion "2.0.0" -Force -AllowClobber -Verbose
            }
            catch {
                Write-Error -Message "Selenium failed to install. Terminating..." -ErrorAction "Stop"
            }
        }
    }
    
    process {
        
        try {
            # Build url.
            $Url = "https://auth.monzo.com/?
            client_id=$($MonzoApplication.ClientCredential.UserName)
            &redirect_uri=$($MonzoApplication.RedirectUri)
            &response_type=code
            &state=$($MonzoApplication.StateToken.Guid)"
            Write-Verbose -Message "The url is: $($Url)"
            
            # Automate browser using Selenium to accept the application.
            $Driver = Start-SeFirefox
            # Navigate to the url.
            Enter-SeUrl -Url $Url -Driver $Driver

            # Find and wait for the button element.
            $Button = Find-SeElement -Driver $Driver -Wait -Timeout 5 -TagName "button"
            # Click the element.
            Invoke-SeClick -Element $Button
            # Enter the email into the input field.
            $EmailField = Find-SeElement -Driver $Driver -TagName "input"
            Send-SeKeys -Element $EmailField -Keys $Email
            # Find the new button element.
            $Button = Find-SeElement -Driver $Driver -Wait -Timeout 5 -TagName "button"
            # Click the new button element.
            Invoke-SeClick -Element $Button
            
            # Prompt user to login to their email account. As Monzo sends them a "magic link".
            # This "magic link" redirects them back to their chosen RedirectUri.
            Write-Output -InputObject "Monzo has emailed you a 'magic link'.`nHead to your email account in the Selenium browser and click the magic link!"
            # Fetch the URL if it matches.
            do {
                Write-Verbose -Message "Sleeping until redirect uri is detected..."
                Start-Sleep -Seconds 1
            } until ($Driver.Url -match "code=[^&]*")
            
            # Store the callback url.
            [System.Uri]$CallbackUrl = $Driver.Url
        }
        catch {
            # Stop the driver if an error occurs.
            Stop-SeDriver -Driver $Driver
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }

    end {

        try {
            # $CallbackUrl matched successfully. Stop the driver.
            Stop-SeDriver -Driver $Driver            
            # Fetch authorisation code and state token from $CallbackUrl.
            $CallbackUrlList = $CallbackUrl.Query.Trim("?code=").Split("&state=")
            $AuthorisationCode = $CallbackUrlList[0]
            $StateToken = $CallbackUrlList[1]

            # Check if state token differs from original state token (GUID).
            # If so, abort the authorisation process.
            if ($StateToken -notlike $MonzoApplication.StateToken.Guid) {
                Write-Error -Message "The state token recieved from the redirect uri: $($StateToken) doesn't match the original state token: $($MonzoApplication.StateToken.Guid)" -ErrorAction "Stop"
            }

            # Populate PSCustom Object MonzoAPI.OAuth.AuthorisationCode.
            [PSCustomObject]@{
                PSTypeName           = "MonzoAPI.OAuth.AuthorisationCode"
                AuthorisationCode    = $AuthorisationCode
                MonzoApplication     = $MonzoApplication
                FullCallbackUrl      = $CallbackUrl
                AuthorisationBaseUrl = "https://auth.monzo.com/"
                IssueDateTime        = (Get-Date)
            }
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}
