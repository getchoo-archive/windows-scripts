<#
.SYNOPSIS
	Disables most telemetry for Windows
.NOTES
	Sourced from https://learn.microsoft.com/en-us/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services
#>

$ErrorActionPreference = "Stop"


function Add-RegKey {
	param (
		[String]$Path,
		[String]$Name,
		[Microsoft.Win32.RegistryValueKind]$Type,
		[System.Object]$Value
	)

	Write-Verbose -Message "Adding registry key $Path\$Name"
	if (-not(Test-Path -Path $Path)) {
		Write-Verbose -Message "Creating registry path $Path"
		New-Item -Path $Path -Force
	}
	New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force
}

function Disable-Cortana {
	Write-Host -Message "Disabling Cortana"
	Add-RegKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name AllowCortana -Value 0 -Type DWord
	Add-RegKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name AllowSearchToUseLocation -Value 0 -Type DWord
	Add-RegKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name DisableWebSearch -Value 1 -Type DWord
	Add-RegKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name ConnectedSearchUseWeb -Value 0 -Type DWord
}

function Disable-DeviceMetadataRetrieval {
	Write-Host -Message "Disabling device metadata retrieval"
	Add-RegKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Name PreventDeviceMetadataFromNetwork -Value 1 -Type DWord
}

function Disable-FindMyDevice {
	Write-Host -Message "Disabling find my device"
	Add-RegKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\FindMyDevice" -Name AllowFindMyDevice -Value 0 -Type DWord
}

function Disable-InsiderBuilds {
	Write-Host -Message "Disabling Windows Insider builds"
	Add-RegKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" -Name AllowBuildPreview -Value 0 -Type DWord
}

function Disable-MailSynchronization {
	Write-Host -Message "Disabling mail synchronization"
	Add-RegKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Mail" -Name ManualLaunchAllowed -Value 0 -Type DWord
}

function Disable-OfflineMaps {
	Write-Host -Message "Disabling offline maps"
	Add-RegKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps" -Name AutoDownloadAndUpdateMapData -Value 0 -Type DWord
	Add-RegKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps" -Name AllowUntriggeredNetworkTrafficOnSettingsPage -Value 0 -Type DWord
}

function Disable-OneDrive {
	Write-Host -Message "Disabling OneDrive"
	Add-RegKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name DisableFileSyncNGSC -Value 1 -Type DWord
	Add-RegKey -Path "HKLM:\SOFTWARE\Microsoft\OneDrive" -Name PreventNetworkTrafficPreUserSignIn -Value 1 -Type DWord
}

function Harden-PrivacySettings {
	Write-Host -Message "Hardening privacy settings"
	Add-RegKey -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name Enabled -Value 0 -Type DWord
	Add-RegKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name DisabledByGroupPolicy -Value 1 -Type DWord
	Add-RegKey -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name Start_TrackProgs -Value 0 -Type DWord
	Add-RegKey -Path "HKLM:\Software\Policies\Microsoft\Windows\LocationAndSensors" -Name DisableLocation -Value 1 -Type DWord
	Add-RegKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" -Name NoCloudApplicationNotification -Value 1 -Type DWord
	Add-RegKey -Path "HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Name HasAccepted -Value 0 -Type DWord
	Add-RegKey -Path "HKLM:\Software\Policies\Microsoft\Speech" -Name AllowSpeechModelUpdate -Value 0 -Type DWord
	Add-RegKey -Path "HKLM:\Software\Policies\Microsoft\Windows\Messaging" -Name AllowMessageSync -Value 0 -Type DWord
	Add-RegKey -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Name DoNotShowFeedbackNotifications -Value 1 -Type DWord
	Add-RegKey -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Name AllowTelemetry -Value 0 -Type DWord
	Add-RegKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name DisableWindowsConsumerFeatures -Value 1 -Type DWord
	Add-RegKey -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name DisableTailoredExperiencesWithDiagnosticData -Value 1 -Type DWord
	Add-RegKey -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name RestrictImplicitTextCollection -Value 1 -Type DWord
	Add-RegKey -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name RestrictImplicitInkCollection -Value 1 -Type DWord
	Add-RegKey -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name EnableActivityFeed -Value 0 -Type DWord
	Add-RegKey -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name PublishUserActivities -Value 0 -Type DWord
	Add-RegKey -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name UploadUserActivities -Value 0 -Type DWord
	Add-RegKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name EnableFeeds -Value 0 -Type DWord

	$permissions = @(
		"LetAppsAccessLocation"
		# You might want these
		# "LetAppsAccessCamera"
		# "LetAppsAccessMicrophone"
		# "LetAppsAccessNotifications"
		# "LetAppsAccessAccountInfo"
		"LetAppsAccessContacts"
		"LetAppsAccessCalendar"
		"LetAppsAccessCallHistory"
		"LetAppsAccessEmail"
		"LetAppsAccessMessaging"
		"LetAppsAccessPhone"
		"LetAppsAccessRadios"
		"LetAppsSyncWithDevices"
		"LetAppsAccessTrustedDevices"
		# Ditto
		# "LetAppsRunInBackground"
		"LetAppsAccessMotion"
		"LetAppsAccessTasks"
		"LetAppsGetDiagnosticInfo"
		# Ditto
		# "LetAppsActivateWithVoice"
		# "LetAppsActivateWithVoiceAboveLock"
	)

	foreach ($permission in $permissions) {
		Add-RegKey -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name $permission -Value 2 -Type DWord
	}
}

function Disable-SettingsSync {
	Write-Host -Message "Disabling settings sync"
	Add-RegKey -Path "HKLM:\Software\Policies\Microsoft\Windows\SettingSync" -Name DisableSettingSync -Value 2 -Type DWord
	Add-RegKey -Path "HKLM:\Software\Policies\Microsoft\Windows\SettingSync" -Name DisableSettingSyncUserOverride -Value 1 -Type DWord
	Add-RegKey -Path "HKCU:\SOFTWARE\Microsoft\Messaging" -Name CloudServiceSyncEnabled -Value 0 -Type DWord
}

function Disable-AutomaticSampleSubmission {
	Write-Host -Message "Disabling Windows Defender automatic sample submission"
	Add-RegKey -Path "HKLM:\Software\Policies\Microsoft\Windows Defender\Spynet" -Name SubmitSamplesConsent -Value 2 -Type DWord
}

function Disable-PersonalizedExperiences {
	Write-Host -Message "Disabling Personalized Experiences"
	Add-RegKey -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name DisableWindowsSpotlightFeatures -Value 1 -Type DWord
	Add-RegKey -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name DisableCloudOptimizedContent -Value 1 -Type DWord
}

function Disable-MicrosoftStore {
	Write-Host -Message "Disabling Microsoft Store apps"
	Add-RegKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Name DisableStoreApps -Value 1 -Type DWord
	Add-RegKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Name AutoDownload -Value 2 -Type DWord
}

function Disable-Copilot {
	Write-Host -Message "Disabling Copilot"
	Add-RegKey -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord
}


Disable-Cortana
Disable-DeviceMetadataRetrieval
# Disable-FindMyDevice
# Disable-InsiderBuilds
Disable-MailSynchronization
Disable-OfflineMaps
Disable-OneDrive
Harden-PrivacySettings
Disable-SettingsSync
Disable-AutomaticSampleSubmission
Disable-PersonalizedExperiences
# Disable-MicrosoftStore
Disable-Copilot

Write-Host -Message "Done!"
