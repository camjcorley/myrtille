#Requires -RunAsAdministrator

[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True)]
    [string]$BinaryPath,
   [Parameter(Mandatory=$False)]
    [bool]$DebugMode
)

$host.UI.RawUI.WindowTitle = "Myrtille Configuration . . . PLEASE DO NOT CLOSE THIS WINDOW . . ."

function ExitWithCode { param($exitCode) $host.SetShouldExit($exitcode); exit }

$ExitCode = 0

# most of the commands below requires elevation
Set-ExecutionPolicy Bypass -Scope Process

Write-Output "Running Myrtille.Services.Install.ps1`r`n"

# check if the service exists
if (!(Get-Service "Myrtille.Services" -ErrorAction SilentlyContinue))
{
	try
	{
		# create the service
		New-Service -Name "Myrtille.Services" -Description "Myrtille HTTP(S) to RDP and SSH gateway" -BinaryPathName $BinaryPath -StartupType "Automatic"
		Write-Output "Created Myrtille.Services`r`n"
	}
	catch
	{
		Write-Output "Failed to create Myrtille.Services" $_.Exception.Message
		$ExitCode = 1
	}
}
else
{
	Write-Output "Myrtille.Services already exists"
}

# check if the service exists
if (Get-Service "Myrtille.Services" -ErrorAction SilentlyContinue)
{
	try
	{
		# start the service
		Start-Service -Name "Myrtille.Services"
		Write-Output "Started Myrtille.Services`r`n"
	}
	catch
	{
		Write-Output "Failed to start Myrtille.Services" $_.Exception.Message
		$ExitCode = 1
	}
}

# give time to read console
if ($DebugMode)
{
	Read-Host "`r`nPress ENTER to continue..."
}

ExitWithCode($ExitCode)