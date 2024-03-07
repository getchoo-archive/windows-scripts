<#
.SYNOPSIS
	Automatically remove preinstalled apps on Windows 10/11
.NOTES
	Sourced from https://learn.microsoft.com/en-us/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services#bkmk-preinstalledapps
#>

$ErrorActionPreference = "Stop"


function Remove-DefaultPackage {
	param (
		[String]$Package
	)

	Write-Host -Message "Removing default package $Package..."
	Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -Like $Package} | ForEach-Object { Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName}
	Write-Host -Message "Removing $Package from current user..."
	Get-AppxPackage $Package | Remove-AppxPackage
}

$packages = @(
	"Microsoft.BingNews"
	"Microsoft.BingWeather"
	"Microsoft.BingFinance"
	"Microsoft.BingSports"
	"Microsoft.GetHelp"
	"Microsoft.Getstarted"
	"Microsoft.MicrosoftOfficeHub"
	"Microsoft.MicrosoftSolitaireCollection"
	"Microsoft.MicrosoftStickyNotes"
	"Microsoft.Office.Sway"
	"Microsoft.Office.OneNote"
	"Microsoft.People"
	"Microsoft.PowerAutomateDesktop"
	"Microsoft.SkypeApp"
	"Microsoft.Todos"
	"Microsoft.WindowsAlarms"
	"Microsoft.WindowsFeedbackHub"
	"Microsoft.WindowsMaps"
	"Microsoft.WindowsSoundRecorder"
	# This won't break much
	# "Microsoft.GamingApp"
	# "Microsoft.XboxApp"
	# These will, though
	# "Microsoft.Xbox.TCUI"
	# "Microsoft.XboxGameCallableUI"
	# "Microsoft.XboxGamingOverlay"
	# "Microsoft.XboxIdentityProvider"
	"Microsoft.YourPhone"
	"Microsoft.ZuneMusic"
	"Microsoft.ZuneVideo"
	"MicrosoftCorporationII.QuickAssist"
	"ClipChamp.ClipChamp"
	"*.Twitter"
)

foreach ($package in $packages) {
	Remove-DefaultPackage -Name $package
}

Write-Host -Message "Done"
