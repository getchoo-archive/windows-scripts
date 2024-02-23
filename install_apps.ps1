<#
.SYNOPSIS
	Post-install script for adding all my apps
#>

function Install-Winget-Package {
	param (
		[String]$Package
	)

	if (! (winget list --exact -q $Package --accept-source-agreements --accept-package-agreements) ) {
		Write-Verbose -Message "Installing $Package with winget"
		winget install --exact --silent $Package
	} else {
		Write-Verbose -Message "Winget package $Package is already installed! Skipping"
	}
}

# This script does a lot so a warning is good
if ( (Read-Host -Prompt "Do you want to install packages through winget and scoop? [y/n]?").toLower() -ne "y") {
	Write-Host "You didn't say yes! Bailing out..."
	Exit
}

# Install winget if it's not already
## https://gist.github.com/crutkas/6c2096eae387e544bd05cde246f23901
if (! (Get-AppxPackage -Name "Microsoft.DesktopAppInstaller") ) {
	Write-Verbose -Message "Installing winget"
	$releases_url = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	$releases = Invoke-RestMethod -uri "$($releases_url)"
	$latestRelease = $releases.assets | Where-Object { $_.browser_download_url.EndsWith("msixbundle") } | Select-Object -First 1

	Add-AppxPackage -Path $latestRelease.browser_download_url
}

$winget_packages = @(
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

foreach ($pkg in $winget_packages) {
	Install-Winget-Package -Package $pkg
}

Write-Host "Done!"
