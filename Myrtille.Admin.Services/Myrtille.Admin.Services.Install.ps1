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

Write-Output "Running Myrtille.Admin.Services.Install.ps1`r`n"

# check if the service exists
if (!(Get-Service "Myrtille.Admin.Services" -ErrorAction SilentlyContinue))
{
	try
	{
		# create the service
		New-Service -Name "Myrtille.Admin.Services" -Description "Myrtille Admin API" -BinaryPathName $BinaryPath -StartupType "Automatic"
		Write-Output "Created Myrtille.Admin.Services`r`n"
	}
	catch
	{
		Write-Output "Failed to create Myrtille.Admin.Services" $_.Exception.Message
		$ExitCode = 1
	}
}
else
{
	Write-Output "Myrtille.Admin.Services already exists"
}

# check if the service exists
if (Get-Service "Myrtille.Admin.Services" -ErrorAction SilentlyContinue)
{
	try
	{
		# start the service
		Start-Service -Name "Myrtille.Admin.Services"
		Write-Output "Started Myrtille.Admin.Services`r`n"
	}
	catch
	{
		Write-Output "Failed to start Myrtille.Admin.Services" $_.Exception.Message
		$ExitCode = 1
	}
}

# give time to read console
if ($DebugMode)
{
	Read-Host "`r`nPress ENTER to continue..."
}

ExitWithCode($ExitCode)