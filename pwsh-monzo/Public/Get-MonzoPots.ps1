function Get-MonzoPots {
    <#
    .SYNOPSIS
        Get Monzo pots.
    
    .DESCRIPTION
        Get a JSON response of pots owned by the currently authorised user.
    
    .PARAMETER MonzoAccessToken
        A Monzo access token - retrieved using New-MonzoTokens.
    
    .EXAMPLE
        Get-MonzoPots -MonzoAccessToken $MonzoAccessToken
    
    .NOTES
        https://docs.monzo.com/#list-pots
    #>
    [CmdletBinding()]
    [OutputType("MonzoAPI.Pots")]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $MonzoAccessToken
    )
    
    process {
        
        try {
            $Response = Invoke-RestMethod -Method "GET" -Uri "https://api.monzo.com/pots" -Headers @{Authorization = "Bearer $($MonzoAccessToken)" } -Verbose:($PSBoundParameters["Verbose"] -eq $true)
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    
    end {
        
        # Populate PSCustomObject MonzoAPI.Pots.
        return [PSCustomObject]@{
            PSTypeName      = "MonzoAPI.Pots"
            Pots            = $Response.pots
            RequestDateTime = (Get-Date)
        }
    }
}
