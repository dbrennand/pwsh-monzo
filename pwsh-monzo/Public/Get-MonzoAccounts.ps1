function Get-MonzoAccounts {
    <#
    .SYNOPSIS
        Get Monzo accounts.
    
    .DESCRIPTION
        Get a list of accounts owned by the currently authorised user.
    
    .PARAMETER MonzoAccessToken
        A Monzo access token - retrieved using New-MonzoTokens.
    
    .EXAMPLE
        Get-MonzoAccounts -MonzoAccessToken $MonzoAccessToken
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType("MonzoAPI.Accounts")]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $MonzoAccessToken
    )
    
    process {
        
        try {
            $Response = Invoke-RestMethod -Method "GET" -Uri "https://api.monzo.com/accounts" -Headers @{Authorization = "Bearer $($MonzoAccessToken)" }
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    
    end {
        
        # Populate PSCustom Object MonzoAPI.Accounts.
        [PSCustomObject]@{
            PSTypeName      = "MonzoAPI.Accounts"
            Accounts        = $Response.accounts
            RequestDateTime = (Get-Date)
        }
    }
}
