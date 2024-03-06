<#
.SYNOPSIS
	Disables automatic startup of unneeded services
.NOTES
	Sourced from https://learn.microsoft.com/en-us/windows/iot/iot-enterprise/optimize/services
#>

$ErrorActionPreference = "Stop"


$manualServices = @(
	"CDPSvc"
	"DiagTrack"
	"MapsBroker"
	"OneSyncSvc"
	"RemoteRegistry"
	"RetailDemo"
)

foreach ($service in $manualServices) {
	Write-Host -Message "Disabling $service"
	Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Manual -ErrorAction SilentlyContinue
}

$disabledServices = @(
	"XboxGipSvc"
	"XblAuthManager"
	"XblGameSave"
	"XboxNetApiSvc"
)

# You probably don't want to do this, as it will break any and all xbox games :/
# foreach ($service in $disabledServices) {
# 	Write-Host -Message "Disabling $service"
# 	Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
# }


Write-Host "Done!"
