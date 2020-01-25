#Requires -RunAsAdministrator

[CmdletBinding()]
Param(
   [Parameter(Mandatory=$False)]
    [bool]$DebugMode
)

$host.UI.RawUI.WindowTitle = "Myrtille Configuration . . . PLEASE DO NOT CLOSE THIS WINDOW . . ."

function ExitWithCode { param($exitCode) $host.SetShouldExit($exitcode); exit }

$ExitCode = 0

# most of the commands below requires elevation
Set-ExecutionPolicy Bypass -Scope Process

Write-Output "Running Myrtille.Admin.Services.Uninstall.ps1`r`n"

# check if the service exists
if (Get-Service "Myrtille.Admin.Services" -ErrorAction SilentlyContinue)
{
	try
	{
		# stop the service
		Stop-Service -Name "Myrtille.Admin.Services"
		Write-Output "Stopped Myrtille.Admin.Services`r`n"

		try
		{
			# remove the service
			# the "Remove-Service" cmdlet was introduced in powershell 6.0 (so is only available on Windows server 2016 or greater); using sc instead
			#Remove-Service -Name "Myrtille.Admin.Services"
			sc.exe delete "Myrtille.Admin.Services"
			Write-Output "Removed Myrtille.Admin.Services`r`n"
		}
		catch
		{
			Write-Output "Failed to remove Myrtille.Admin.Services" $_.Exception.Message
			$ExitCode = 1
		}
	}
	catch
	{
		Write-Output "Failed to stop Myrtille.Admin.Services" $_.Exception.Message
		$ExitCode = 1
	}
}
else
{
	Write-Output "Myrtille.Admin.Services doesn't exists"
}

# give time to read console
if ($DebugMode)
{
	Read-Host "`r`nPress ENTER to continue..."
}

ExitWithCode($ExitCode)