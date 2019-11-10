function Get-MonzoAccounts {
    <#
    .SYNOPSIS
        Get Monzo accounts.
    
    .DESCRIPTION
        Get a JSON representation of accounts owned by the currently authorised user.
    
    .PARAMETER MonzoAccessToken
        A Monzo access token - retrieved using New-MonzoTokens.
    
    .EXAMPLE
        Get-MonzoAccounts -MonzoAccessToken $MonzoAccessToken
    
    .NOTES
        https://docs.monzo.com/#list-accounts
    #>
    [CmdletBinding()]
    [OutputType("MonzoAPI.Accounts")]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $MonzoAccessToken
    )
    
    process {
        
        try {
            $Response = Invoke-RestMethod -Method "GET" -Uri "https://api.monzo.com/accounts" -Headers @{ Authorization = "Bearer $($MonzoAccessToken)" } -Verbose:($PSBoundParameters["Verbose"] -eq $true) -ErrorAction "Stop"
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    
    end {
        
        # Populate PSCustomObject MonzoAPI.Accounts.
        return [PSCustomObject]@{
            PSTypeName      = "MonzoAPI.Accounts"
            Accounts        = $Response.accounts
            RequestDateTime = (Get-Date)
        }
    }
}
