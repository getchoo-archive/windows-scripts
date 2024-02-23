<#
.SYNOPSIS
	Post-install script for adding all my apps
#>

$ErrorActionPreference = "Stop"


function Install-Winget-Package {
	param (
		[String]$Package
	)

	winget list --exact --query $Package | Out-Null
	$alreadyInstalled = $?
	if (!$alreadyInstalled) {
		Write-Host -Message "Installing $Package"
		winget install --source winget --silent --exact $Package
	} else {
		Write-Host -Message "Package $Package is already installed! Skipping"
	}
}

# This script does a lot so a warning is good
if ( (Read-Host -Prompt "Do you want to install all packages? [y/n]?").toLower() -ne "y" ) {
	Write-Host "You didn't say yes! Bailing out..."
	Exit
}

# Install winget if it's not already
## https://gist.github.com/crutkas/6c2096eae387e544bd05cde246f23901
if (! (Get-AppxPackage -Name "Microsoft.DesktopAppInstaller") ) {
	Write-Host -Message "Installing winget"
	$releasesUrl = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"

	Write-Verbose -Message "Querying $releasesUrl"
	$releases = Invoke-RestMethod -Uri $releasesUrl
	$latestRelease = $releases.assets | Where-Object { $_.browser_download_url.EndsWith("msixbundle") } | Select-Object -First 1

	Write-Verbose -Message "Installing latest release from $($latestRelease.browser_download_url))"
	Add-AppxPackage -Path $latestRelease.browser_download_url
	Write-Host -Message "Done!"
}

$wingetPackages = @(
	# apps
	"Cemu.Cemu"
	"Hibbiki.Chromium"
	"Ubisoft.Connect"
	"Discord.Discord"
	"DolphinEmulator.Dolphin"
	"ElectronicArts.EADesktop"
	"Element.Element"
	"EpicGames.EpicGamesLauncher"
	"Mozilla.Firefox"
	"GOG.Galaxy"
	"Mojang.MinecraftLauncher"
	"OBSProject.OBSStudio"
	"dotPDNLLC.paintdotnet"
	"PrismLauncher.PrismLauncher"
	"Libretro.RetroArch"
	"Spotify.Spotify"
	"Valve.Steam"
	"tailscale.tailscale"
	"OneGal.Viper"
	"YuzuEmu.Yuzu.Mainline"

	# utils
	"bootandy.dust"
	"voidtools.Everything"
	"valinet.ExplorerPatcher"
	"sharkdp.fd"
	"RyanGregg.GCFScape"
	"HandBrake.HandBrake"
	"REALiX.HWiNFO"
	"KDE.Kdenlive"
	"M2Team.NanaZip"
	"Jaquadro.NBTExplorer"
	"nomacs.nomacs"
	"Notepad++.Notepad++"
	"Neovim.Neovim"
	"TechPowerUp.NVCleanstall"
	"namazso.OpenHashTab"
	"CalcProgrammer1.OpenRGB"
	"Microsoft.PowerShell"
	"Microsoft.PowerToys"
	"qBittorrent.qBittorrent"
	"BurntSushi.ripgrep.MSVC"
	"Rclone.Rclone"
	"restic.restic"
	"smartmontools.smartmontools"
	"VideoLAN.VLC"
	"RyanGregg.VTFEdit"
	"AntibodySoftware.WizTree"
	"yt-dlp.yt-dlp"

	# dev tools
	"Git.Git"
	"GitHub.cli"
	"GnuPG.Gpg4win"
	"Casey.Just"
	"EclipseAdoptium.Temurin.17.JDK"
	"EclipseAdoptium.Temurin.8.JRE"
	"Microsoft.VisualStudio.2022.BuildTools"
	"Microsoft.VisualStudioCode"
	"Python.Python.3.12"
	"Rustlang.Rustup"
)

foreach ($package in $wingetPackages) {
	Install-Winget-Package -Package $package
}

Write-Host "Done!"
