function Get-MonzoBalance {
    <#
    .SYNOPSIS
        Get Monzo balance.
    
    .DESCRIPTION
        Get the balance information for a specific account from the Monzo bank API.
    
    .PARAMETER MonzoAccessToken
        A Monzo access token - retrieved using New-MonzoTokens.
    
    .PARAMETER AccountId
        The id of the account to get the balance information of.
    
    .EXAMPLE
        Get-MonzoBalance -MonzoAccessToken $MonzoAccessToken -AccountId "Account id here."
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType("MonzoAPI.Balance")]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $MonzoAccessToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $AccountId
    )
    
    process {
        
        try {
            $RequestBody = @{account_id = $AccountId}
            $Response = Invoke-RestMethod -Method "GET" -Uri "https://api.monzo.com/balance" -Headers @{Authorization = "Bearer $($MonzoAccessToken)" } -Body $RequestBody -Verbose:($PSBoundParameters["Verbose"] -eq $true)
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    
    end {
        
        # Populate PSCustom Object MonzoAPI.Balance.
        [PSCustomObject]@{
            PSTypeName      = "MonzoAPI.Balance"
            Accounts        = $Response
            RequestDateTime = (Get-Date)
        }
    }
}
