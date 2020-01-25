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

Write-Output "Running Myrtille.Services.Uninstall.ps1`r`n"

# check if the service exists
if (Get-Service "Myrtille.Services" -ErrorAction SilentlyContinue)
{
	try
	{
		# stop the service
		Stop-Service -Name "Myrtille.Services"
		Write-Output "Stopped Myrtille.Services`r`n"

		try
		{
			# remove the service
			# the "Remove-Service" cmdlet was introduced in powershell 6.0 (so is only available on Windows server 2016 or greater); using sc instead
			#Remove-Service -Name "Myrtille.Services"
			sc.exe delete "Myrtille.Services"
			Write-Output "Removed Myrtille.Services`r`n"
		}
		catch
		{
			Write-Output "Failed to remove Myrtille.Services" $_.Exception.Message
			$ExitCode = 1
		}
	}
	catch
	{
		Write-Output "Failed to stop Myrtille.Services" $_.Exception.Message
		$ExitCode = 1
	}
}
else
{
	Write-Output "Myrtille.Services doesn't exists"
}

# give time to read console
if ($DebugMode)
{
	Read-Host "`r`nPress ENTER to continue..."
}

ExitWithCode($ExitCode)