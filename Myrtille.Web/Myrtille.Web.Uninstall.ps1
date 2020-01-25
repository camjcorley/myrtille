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

Write-Output "Running Myrtille.Web.Uninstall.ps1`r`n"

# myrtille web application
if (Get-WebApplication -Site "Default Web Site" -Name "Myrtille")
{
    try
    {
	    Remove-WebApplication -Site "Default Web Site" -Name "Myrtille"
        Write-Output "Removed Myrtille web application"
    }
    catch
    {
        Write-Output "Failed to remove Myrtille web application" $_.Exception.Message
        $ExitCode = 1
    }
}
else
{
    Write-Output "Myrtille web application doesn't exists"
}

Import-Module WebAdministration

# myrtille application pool
if (Test-Path "IIS:\AppPools\MyrtilleAppPool")
{
    try
    {
	    Remove-WebAppPool -Name "MyrtilleAppPool"
        Write-Output "Removed Myrtille application pool"
    }
    catch
    {
        Write-Output "Failed to remove Myrtille application pool" $_.Exception.Message
        $ExitCode = 1
    }
}
else
{
    Write-Output "Myrtille application pool doesn't exists"
}

# myrtille self-signed certificate
$Cert = Get-ChildItem -Path "Cert:\LocalMachine\My" | Where-Object { $_.FriendlyName -eq "Myrtille self-signed certificate" }
if ($Cert)
{
    try
    {
		# the https binding (on the default web site) possibly existed before myrtille was installed (using another certificate); only remove the myrtille certificate
		$Cert | Remove-Item
		Write-Output "Removed Myrtille self-signed certificate"
    }
    catch
    {
        Write-Output "Failed to remove Myrtille self-signed certificate" $_.Exception.Message
        $ExitCode = 1
    }
}
else
{
	Write-Output "Myrtille self-signed certificate doesn't exists"
}

# give time to read console
if ($DebugMode)
{
	Read-Host "`r`nPress ENTER to continue..."
}

ExitWithCode($ExitCode)