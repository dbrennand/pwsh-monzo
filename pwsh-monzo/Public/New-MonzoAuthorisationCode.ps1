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
        $AuthorisationCode = New-MonzoAuthorisationCode -MonzoApplication $MonzoApplication -Email "foobar@somemail.com"
    
    .NOTES
        https://docs.monzo.com/#acquire-an-access-token
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType("MonzoAPI.OAuth.AuthorisationCode")]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("MonzoApp")]
        [PSTypeName("MonzoAPI.Application")]
        $MonzoApplication,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                try {
                    [MailAddress]$_
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
                Install-Module -Name "Selenium" -Force -AllowClobber -Verbose
            }
            catch {
                Write-Error -Message "Failed to install the Selenium module. Terminating..." -ErrorAction "Stop"
            }
        }
    }
    
    process {
        
        try {
            # Construct url.
            $Url = "https://auth.monzo.com/?client_id=$($MonzoApplication.ClientCredential.UserName)&redirect_uri=$($MonzoApplication.RedirectUri)&response_type=code&state=$($MonzoApplication.StateToken.Guid)"
            Write-Verbose -Message "The url is: $($Url)"
            
            # Automate browser using Selenium to accept the application.
            $Firefox_Options = New-Object -TypeName "OpenQA.Selenium.Firefox.FirefoxOptions"
            # Suppress logging.
            $Firefox_Options.LogLevel = 6
            $Driver = New-Object -TypeName "OpenQA.Selenium.Firefox.FirefoxDriver" -ArgumentList $Firefox_Options
            Enter-SeUrl -Driver $Driver -Url $Url
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
            Read-Host -Prompt "Press ENTER once the redirect uri tab is loaded and selected"

            # Fetch the last tab id. Most likely the last tab.
            $NewWindowId = $Driver.WindowHandles | Select-Object -Last 1
            # Switch to the new tab, containing the redirect Uri.
            $Driver.SwitchTo().Window($NewWindowId) | Out-Null
            
            if ($Driver.Url -match "code=[^&]*") {
                # Store the callback url.
                [System.Uri]$CallbackUrl = $Driver.Url
            }
            else {
                # Stop the driver if an error occurs.
                Stop-SeDriver -Driver $Driver
                Write-Error "Failed to obtain redirect Uri; Terminating..." -ErrorAction "Stop"
            }
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
            $CallbackUrlList = (($CallbackUrl.Query -split "code=") -split "&state=")
            $AuthorisationCode = $CallbackUrlList[1]
            $StateToken = $CallbackUrlList[2]
            Write-Verbose -Message "Authorisation code: $($AuthorisationCode) State token: $($StateToken)"

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
