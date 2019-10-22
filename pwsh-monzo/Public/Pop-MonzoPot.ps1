function Pop-MonzoPot {
    <#
    .SYNOPSIS
        Withdraw from a Monzo pot.
    
    .DESCRIPTION
        Withdraw money from the currently authorised users pot to a account.
    
    .PARAMETER MonzoAccessToken
        A Monzo access token - retrieved using New-MonzoTokens.
    
    .PARAMETER PotId
        The id of the pot to withdraw money from.
    
    .PARAMETER AccountId
        The id of the account to move money to.
    
    .PARAMETER Amount
        The amount of money to withdraw into the pot as 64bit integer in minor units of the currency, eg. pennies for GBP, or cents for EUR and USD.
    
    .PARAMETER DedupeId
        A unique string used to de-duplicate withdrawals. Ensure this remains static between retries to ensure only one withdraw is created.
    
    .EXAMPLE
        Pop-MonzoPot -MonzoAccessToken $MonzoAccessToken -PotId "pot_00009exampleP0tOxWb" -AccountId "AccountId here." -Amount 100
    
    .EXAMPLE
        $DedupeId = [Guid]::NewGuid()
        Pop-MonzoPot -MonzoAccessToken $MonzoAccessToken -PotId "pot_00009exampleP0tOxWb" -AccountId "AccountId here." -Amount 100 -DedupeId $DedupeId.Guid
    
    .NOTES
        https://docs.monzo.com/#withdraw-from-a-pot
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType("MonzoAPI.Pot")]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $MonzoAccessToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $PotId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $AccountId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Uint64]
        $Amount,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Guid]
        $DedupeId = ([Guid]::NewGuid()).Guid
    )
    
    process {
        
        try {
            $RequestBody = @{
                source_account_id = $AccountId 
                amount            = $Amount 
                dedupe_id         = $DedupeId
            }
            $Response = Invoke-RestMethod -Method "PUT" -Uri "https://api.monzo.com/pots/$PodId/withdraw" -Headers @{Authorization = "Bearer $($MonzoAccessToken)" } -Body $RequestBody -Verbose:($PSBoundParameters["Verbose"] -eq $true)
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    
    end {
        
        # Populate PSCustom Object MonzoAPI.Pot.
        [PSCustomObject]@{
            PSTypeName      = "MonzoAPI.Pot"
            Pot             = $Response
            DedupeId        = $DedupeId
            RequestDateTime = (Get-Date)
        }
    }
}
