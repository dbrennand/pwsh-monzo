Write-Verbose "Importing functions"

$Public = Get-ChildItem "$PSScriptRoot\Public\*.ps1" -ErrorAction "Stop"

foreach ($Import in $Public) {
    
    try {
        Write-Verbose -Message "$($Import.FullName)"
        . $Import.FullName
    }
    catch {
        Write-Error "Failed to import function $($Import.FullName): $_"
    }
}
