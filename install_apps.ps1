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

function Install-Scoop-Package {
	param (
		[String]$Package
	)

	if (! (scoop info $Package).Installed ) {
		Write-Verbose -Message "Installing $Package with scoop"
		scoop install $Package
	} else {
		Write-Verbose -Message "Scoop package $Package is already installed! Skipping"
	}
}

function Get-File {
	param (
		[String]$Output,
		[String]$URL
	)

	Write-Versboe -Message "Downloading file from $URL"
	Invoke-Webrequest -Uri $URL -OutFile $Output
}

function Install-From-File {
	param (
		[String]$Output,
		[String]$Path
	)

	Get-File -Output $Path -URL $URL
	if (Test-Path -Path $Path) {
		Start-Process -FilePath $Path
		Remove-Item -Path $Path
	} else {
		Write-Verbose -Message "$Path was not found! Skipping"
	}
}


# --- This script does a lot so a warning is good ---
if ( (Read-Host -Prompt "Do you want to install packages through winget and scoop? [y/n]?").toLower() -ne "y") {
	Write-Host "You didn't say yes! Bailing out..."
	Exit
}


# --- Setup WinGet Packages ---

## install winget if it's not already
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
	"Hibbiki.Chromium"
	"Ubisoft.Connect"
	"Discord.Discord"
	"ElectronicArts.EADesktop"
	"EpicGames.EpicGamesLauncher"
	"voidtools.Everything"
	"valinet.ExplorerPatcher"
	"Mozilla.Firefox"
	"Gajim.Gajim"
	"GOG.Galaxy"
	"RyanGregg.GCFScape"
	"GIMP.GIMP.Nightly"
	"LOOT.LOOT"
	"Mojang.MinecraftLauncher"
	"MullvadVPN.MullvadVPN"
	"M2Team.NanaZip"
	"Jaquadro.NBTExplorer"
	"nomacs.nomacs"
	"Notepad++.Notepad++"
	"TechPowerUp.NVCleanstall"
	"OBSProject.OBSStudio"
	"namazso.OpenHashTab"
	"Microsoft.PowerShell"
	"Microsoft.PowerToys"
	"PrismLauncher.PrismLauncher"
	"qBittorrent.qBittorrent"
	"Spotify.Spotify"
	"Valve.Steam"
    "tailscale.tailscale"
	"OneGal.Viper"
	"Microsoft.VisualStudio.2022.BuildTools"
	"Microsoft.VisualStudioCode"
	"VideoLAN.VLC"
	"RyanGregg.VTFEdit"
)

foreach ($pkg in $winget_packages) {
	Install-Winget-Package -Package $pkg
}


# --- Setup Scoop Packages ---

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
## install scoop if it isn't already
if ( !(Get-Command -Name "scoop" -CommandType Application -ErrorAction SilentlyContinue | Out-Null) ) {
    Write-Verbose -Message "Installing Scoop"
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh'))
}

$scoop_packages = @(
	"git"
	"7-zip"
	"cemu"
	"crispy-doom"
	"deno"
	"dog"
	"dolphin"
	"dust"
	"element"
	"fd"
	"ffmpeg"
	"filelight"
	"fnm"
	"gh"
	"gpg"
	"handbrake"
	"hwinfo"
	"just"
	"kdenlive"
	"magic-wormhole"
	"neovim"
	"nicotine-plus"
	"openrgb"
	"pnpm"
	"python"
	"rclone"
	"restic"
	"retroarch"
	"ripgrep"
	"rustup-msvc"
	"sccache"
	"smartmontools"
	"temurin17-jdk"
	"temurin8-jre"
	"yt-dlp"
	"yuzu"
	"zstd"
)

foreach ($pkg in $scoop_packages) {
	Install-Scoop-Package -Package $pkg
}

# --- Install external apps ---
$file = New-TemporaryFile
Remove-Item -Path $file -Force
$temp_folder = New-Item -ItemType Directory -Path "$($ENV:Temp)\$($file.Name)"

Install-From-File -Output "$temp_folder/OpenJDK16U-jdk_x64_windows_hotspot_16.0.2_7.msi" -URL "https://github.com/adoptium/temurin16-binaries/releases/download/jdk-16.0.2%2B7/OpenJDK16U-jdk_x64_windows_hotspot_16.0.2_7.msi"
Get-File -Output "$HOME/Downloads/rpcs3-v0.0.25-14495-8ac99680_win64.7z" -URL "https://github.com/RPCS3/rpcs3-binaries-win/releases/download/build-8ac99680962fc4c01dd561716f0b927d386bc7e8/rpcs3-v0.0.25-14495-8ac99680_win64.7z"
Install-From-File -Output "$temp_folder/Slippi-Launcher-Setup-2.7.0.exe" -URL "https://github.com/project-slippi/slippi-launcher/releases/download/v2.7.0/Slippi-Launcher-Setup-2.7.0.exe"


Write-Host "Done!"
