<#
.SYNOPSIS
	Post-install script for "debloating" Windows
.DESCRIPTION
	Removes default apps, disables telemetry, services, and some other annoying things
.NOTES
	Inspired by https://gist.github.com/mikepruett3/7ca6518051383ee14f9cf8ae63ba18a7
#>

$VerbosePreference = "Continue"

function Add-Registry-Key {
	param (
		[String]$Name,
		[String]$Path,
		[Microsoft.Win32.RegistryValueKind]$Type,
		[System.Object]$Value
	)

	Write-Verbose -Message "Adding registry key $Path\$NAME"
	if (-not(Test-Path -Path $Path)) {
		Write-Verbose -Message "Creating registry path $Path"
		New-Item -Path $Path -Force
	}
	New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force
}

function Add-HKLM-Key {
	param (
		[String]$Name,
		[String]$Path,
		[Microsoft.Win32.RegistryValueKind]$Type,
		[System.Object]$Value
	)

	Add-Registry-Key -Path "HKLM:\$Path" -Name $Name -Value $Value -Type $Type
}

function Add-HKCU-Key {
	param (
		[String]$Name,
		[String]$Path,
		[Microsoft.Win32.RegistryValueKind]$Type,
		[System.Object]$Value
	)

	Add-Registry-Key -Path "HKCU:\$Path" -Name $Name -Value $Value -Type $Type
}

function Remove-Default-Package {
	param (
		[String]$Name
	)

	Write-Verbose -Message "Removing default package $Name"
	Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -Like $Name} | ForEach-Object { Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName}
	Write-Verbose -Message "Removing $Name from current user"
	Get-AppxPackage $Name | Remove-AppxPackage
}


# actual start of the script :p
Write-Host "Starting post-install script!"


# --- Privacy/Usability Settings ---
# see https://learn.microsoft.com/en-us/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services

## Disable Cortana and Web Search
Add-HKLM-Key -Path "SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0
Add-HKLM-Key -Path "SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowSearchToUseLocation" -Type DWord -Value 0
Add-HKLM-Key -Path "SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1
Add-HKLM-Key -Path "SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Type DWord -Value 0

## Disable OneDrive
Add-HKLM-Key -Path "SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1
Add-HKLM-Key -Path "SOFTWARE\Microsoft\OneDrive" -Name "PreventNetworkTrafficPreUserSignIn" -Type DWord -Value 1

## Disable Advertising ID 
Add-HKLM-Key -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
Add-HKLM-Key -Path "SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1
Add-HKLM-Key -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type DWord -Value 0

## Disable apps' access to some things
$app_access = @(
	"LetAppsAccessLocation"
	"LetAppsAccessContacts"
	"LetAppsAccessCalendar"
	"LetAppsAccessCallHistory"
	"LetAppsAccessEmail"
	"LetAppsAccessMessaging"
	"LetAppsAccessPhone"
	"LetAppsAccessMotion"
	"LetAppsAccessTasks"
	"LetAppsGetDiagnosticInfo"
	"LetAppsActivateWithVoice"
	"LetAppsActivateWithVoiceAboveLock"
)

foreach ($access in $app_access) {
	Add-HKLM-Key -Path "SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name $access -Type DWord -Value 2
}

Add-HKLM-Key -Path "SOFTWARE\Policies\Microsoft\Windows\Messaging" -Name "AllowMessageSync" -Type DWord -Value 0

## Disable Feedback & diagnostics
Add-HKLM-Key -Path "SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1
Add-HKLM-Key -Path "SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Add-HKLM-Key -Path "SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1
Add-HKCU-Key -Path "SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1

## Disable Inking & Typing data collection
Add-HKCU-Key -Path "SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
Add-HKCU-Key -Path "SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1

## Disable Activity History
Add-HKLM-Key -Path "SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWord -Value 0
Add-HKLM-Key -Path "SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0
Add-HKLM-Key -Path "SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWord -Value 0

## Disable Windows Defender sample submission
Add-HKLM-Key -Path "SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SubmitSamplesConsent" -Type DWord -Value 2

## Disable News and interests
Add-HKLM-Key -Path "SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Type DWord -Value 0

## Disable Personalized Experiences
Add-HKCU-Key -Path "SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsSpotlightFeatures" -Type DWord -Value 1
Add-HKCU-Key -Path "SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableCloudOptimizedContent" -Type DWord -Value 1


# --- Remove Default Packages ---
$packages = @(
	"Microsoft.BingNews"
	"Microsoft.BingWeather"
	"Microsoft.BingFinance"
	"Microsoft.BingSports"
	"*.Twitter"
	"Microsoft.Office.Sway"
	"Microsoft.Office.OneNote"
	"Microsoft.MicrosoftOfficeHub"
	"Microsoft.SkypeApp"
	"Microsoft.MicrosoftStickyNotes"
)

foreach ($pkg in $packages) {
	Remove-Default-Package -Name $pkg
}


# --- Disable Extra Services ---
## sourced from https://github.com/ChrisTitusTech/winutil
$services = @(
	"AJRouter"
	"Browser"
	"BthAvctpSvc"
	"diagnosticshub.standardcollector.service"
	"DiagTrack"
	"Fax"
	"fhsvc"
	"lmhosts"
	"PhoneSvc"
	"RemoteAccess"
	"RemoteRegistry"
	"RetailDemo"
	# "wisvc" # Windows Insider, uncomment if you'll never use it
	"WMPNetworkSvc"
	"WPDBusEnum"
)

foreach ($service in $services) {
	Write-Verbose -Message "Disabling $service"
	Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Manual -ErrorAction SilentlyContinue
}


# --- Disable Copilot ---
Add-HKCU-Key -Path "SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1


Write-Host "Done!"
