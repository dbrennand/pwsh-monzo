# pwsh-monzo
PowerShell cmdlets to interact programically interact with the Monzo API.

## Dependencies

* [Selenium-PowerShell](https://github.com/adamdriscoll/selenium-powershell)

## Installation

```powershell
Install-Module -Name "pwsh-monzo"
```
Or
```powershell
Import-Module "{FullPath}\pwsh-monzo\Public\pwsh-monzo.psm1"
```

## Usage

```powershell
$Credentials = Get-Credential
$MonzoApplication = New-MonzoApplication -Name "MyMonzoApp" -ClientCredential $Credentials -RedirectUri "https://foobar.com/oauth/callback"
$AuthorisationCode = New-MonzoAuthorisationCode -MonzoApplication $MonzoApplication -Email "foobar@somemail.com"
$MonzoTokens = New-MonzoTokens -MonzoAuthorisationCode $AuthorisationCode
$MonzoAccessToken = $MonzoTokens.AccessToken
Get-MonzoAccounts -MonzoAccessToken $MonzoAccessToken
```

## Authors -- Contributors

* **Dextroz** - *Author* - [Dextroz](https://github.com/Dextroz)

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) for details.
