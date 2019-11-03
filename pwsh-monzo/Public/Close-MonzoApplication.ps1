function Close-MonzoApplication {
    <#
    .SYNOPSIS
        Close the Monzo application.
    
    .DESCRIPTION
        Closes the Monzo application. By invoking the "/logout" endpoint from the Monzo bank API.
    
    .PARAMETER MonzoAccessToken
        A Monzo access token.
    
    .EXAMPLE
        Close-MonzoApplication -MonzoAccessToken "Access token here."
    
    .NOTES
        While access tokens do expire after a number of hours, you may wish to invalidate the token instantly at a specific time such as when a user chooses to log out of your application.
        Once invalidated, the user must go through the authentication process again. You will not be able to refresh the access token.
        https://docs.monzo.com/#log-out
    #>
    [CmdletBinding()]
    [OutputType("MonzoAPI.Application.Closed")]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $MonzoAccessToken
    )

    process {

        try {
            Invoke-RestMethod -Method "POST" -Uri "https://api.monzo.com/oauth2/logout" -Headers @{Authorization = "Bearer $($MonzoAccessToken)" } -Verbose:($PSBoundParameters["Verbose"] -eq $true)
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }

    end {

        # Populate PSCustom Object MonzoAPI.Application.Closed.
        [PSCustomObject]@{
            PSTypeName     = "MonzoAPI.Application.Closed"
            Message        = "The application was successfully logged out."
            ClosedDateTime = (Get-Date)
        }
    }
    
}