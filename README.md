# pwsh-monzo
PowerShell cmdlets to programmatically interact with the Monzo API.

## Dependencies

* [Selenium-PowerShell](https://github.com/adamdriscoll/selenium-powershell)

## Installation

```powershell
Import-Module -Name "{Full path to project}\pwsh-monzo\pwsh-monzo.psm1" -Verbose
```

## Prerequisites

1. Head to the [Monzo API playground](https://developers.monzo.com/api/playground).

2. Enter your email address and **click** the link in the email Monzo sent to you.

    - If you are only going to use the API for a **few hours**, use the [playground access token](#Using-the-playground-access-token) and **skip all the following steps**. Accept the prompt in the Monzo app to grant permissions to the playground access token.

3. Once in the developers API playground, click **Clients**.

4. Click **New OAuth Client**.

5. Provide a **Name**, **Redirect URL**, **Description** and select **Confidential (You keep the client secret-server side and do not expose it)** from the drop down.

    - Ensure the **Redirect URL** you provide here is the same as when you initalise the Monzo application using **New-MonzoApplication**.

6. Click **Submit**.

7. You can now [begin using the cmdlets](#Initalisation).


## Usage

Provide the `-Verbose` parameter to all cmdlets to produce more output.

### Using the playground access token:

* Accept the prompt in the Monzo app (on your phone) to allow access to your account.

* **NOTE:** This access token only lasts a few hours.

```powershell
# You can now start using cmdlets straight away, passing in the playground access token.
$MonzoAccessToken = "Playground access token."
$MonzoAccountId = ((Get-MonzoAccounts -MonzoAccessToken $MonzoAccessToken).Accounts | Select-Object -First 1).id
Get-MonzoBalance -MonzoAccessToken $MonzoAccessToken -AccountId $MonzoAccountId
```

### Initalisation:

```powershell
$Credentials = Get-Credential
$MonzoApplication = New-MonzoApplication -Name "MyMonzoApp" -ClientCredential $Credentials -RedirectUri "https://localhost:8888/oauth/callback"
# NOTE: After running the cmdlet below, you will be prompted in the Monzo app to provide this app with account permissions.
# If you do not grant permissions to the app, all API calls WILL fail and you won't be able to retrieve an access token.
$AuthorisationCode = New-MonzoAuthorisationCode -MonzoApplication $MonzoApplication -Email "foobar@somemail.com"
$MonzoTokens = New-MonzoTokens -MonzoAuthorisationCode $AuthorisationCode
$MonzoAccessToken = $MonzoTokens.AccessToken
# You can now begin using the access token to make API calls.
Get-MonzoAccounts -MonzoAccessToken $MonzoAccessToken
```

### Obtaining a new access token using a refresh token:

```powershell
# Using previous variables.
$MonzoRefreshToken = $MonzoTokens.RefreshToken
$Credentials = $MonzoApplication.ClientCredentials
$MonzoTokens = New-MonzoTokens -ClientCredential $Credentials -MonzoRefreshToken $MonzoRefreshToken -RefreshToken
# From scratch.
$Credentials = Get-Credential
$MonzoTokens = New-MonzoTokens -ClientCredential $Credentials -MonzoRefreshToken $MonzoRefreshToken -RefreshToken
```

## Changelog

* V0.0.1 - Added coverage to Monzo pots.

## Authors -- Contributors

* **Dextroz** - *Author* - [Dextroz](https://github.com/Dextroz)

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) for details.
