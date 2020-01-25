#Requires -RunAsAdministrator

[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True)]
    [string]$InstallPath,
   [Parameter(Mandatory=$False)]
    [bool]$SslCert,
   [Parameter(Mandatory=$False)]
    [bool]$DebugMode
)

$host.UI.RawUI.WindowTitle = "Myrtille Configuration . . . PLEASE DO NOT CLOSE THIS WINDOW . . ."

function ExitWithCode { param($exitCode) $host.SetShouldExit($exitcode); exit }

$ExitCode = 0

# most of the commands below requires elevation
Set-ExecutionPolicy Bypass -Scope Process

Write-Output "Running Myrtille.Web.Install.ps1`r`n"

# myrtille prerequisites
try
{
    # enable IIS, WebSocket protocol, management console and tools
	Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole, IIS-WebServer, IIS-CommonHttpFeatures, IIS-DefaultDocument, IIS-DirectoryBrowsing, IIS-HttpErrors, IIS-StaticContent, IIS-HttpRedirect, IIS-HealthAndDiagnostics, IIS-HttpLogging, IIS-Performance, IIS-HttpCompressionStatic, IIS-Security, IIS-RequestFiltering, IIS-ApplicationDevelopment, IIS-ISAPIExtensions, IIS-ISAPIFilter, IIS-WebSockets, IIS-ManagementConsole, IIS-ManagementScriptingTools
	Write-Output "Enabled IIS, WebSocket protocol, management console and tools`r`n"

	# enable .NET extensibility
	Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45, IIS-ASPNET45 -All
	Write-Output "Enabled .NET extensibility`r`n"

    # enable WCF/HTTP activation
    Enable-WindowsOptionalFeature -Online -FeatureName WAS-WindowsActivationService, WAS-ProcessModel, WAS-ConfigurationAPI, WCF-HTTP-Activation45
	Write-Output "Enabled WCF/HTTP activation`r`n"
}
catch
{
    Write-Output "Failed to enable Myrtille prerequisites" $_.Exception.Message
    $ExitCode = 1
}

# myrtille self-signed certificate
if ($SslCert)
{
	$Cert = Get-ChildItem -Path "Cert:\LocalMachine\My" | Where-Object { $_.FriendlyName -eq "Myrtille self-signed certificate" }
	if (!($Cert))
	{
        try
        {
		    $Name = ([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname
		    $Cert = New-SelfSignedCertificate -CertStoreLocation "Cert:\LocalMachine\My" -FriendlyName "Myrtille self-signed certificate" -DnsName $Name
		    Write-Output "Created Myrtille self-signed certificate"
            try
            {
		        # bind the certificate
		        # this script configures myrtille for the default web site, change it as needed
		        $Bind = Get-WebBinding -Name "Default Web Site" -Protocol "https"
		        if (!($Bind))
		        {
			        New-WebBinding -Name "Default Web Site" -IPAddress * -Port 443 -Protocol "https"
                    Write-Output "Created https binding on default web site"
                    $Bind = Get-WebBinding -Name "Default Web Site" -Protocol "https"
		        }
		        $Bind.AddSslCertificate($Cert.GetCertHashString(), "my")
                Write-Output "Bound Myrtille self-signed certificate"
            }
            catch
            {
                Write-Output "Failed to bind Myrtille self-signed certificate" $_.Exception.Message
                $ExitCode = 1
            }
        }
        catch
        {
            Write-Output "Failed to create Myrtille self-signed certificate" $_.Exception.Message
            $ExitCode = 1
        }
	}
	else
	{
		Write-Output "Myrtille self-signed certificate already exists"
	}
}
else
{
    Write-Output "Skipped creation of Myrtille self-signed certificate"
}

Import-Module WebAdministration

# myrtille application pool
if (!(Test-Path "IIS:\AppPools\MyrtilleAppPool"))
{
    try
    {
	    New-WebAppPool -Name "MyrtilleAppPool"
	    Set-ItemProperty -Path "IIS:\AppPools\MyrtilleAppPool" -Name "managedRuntimeVersion" -Value "v4.0"
	    Set-ItemProperty -Path "IIS:\AppPools\MyrtilleAppPool" -Name "managedPipelineMode" -Value $False
	    Set-ItemProperty -Path "IIS:\AppPools\MyrtilleAppPool" -Name "enable32BitAppOnWin64" -Value $False
	    Set-ItemProperty -Path "IIS:\AppPools\MyrtilleAppPool" -Name "processModel.loadUserProfile" -Value $True
	    Set-ItemProperty -Path "IIS:\AppPools\MyrtilleAppPool" -Name "recycling.periodicRestart.time" -Value 0.00:00:00
        Write-Output "Created Myrtille application pool"
    }
    catch
    {
        Write-Output "Failed to create Myrtille application pool" $_.Exception.Message
        $ExitCode = 1
    }
}
else
{
    Write-Output "Myrtille application pool already exists"
}

# myrtille web application
if (!(Get-WebApplication -Site "Default Web Site" -Name "Myrtille"))
{
    try
    {
	    New-WebApplication -Site "Default Web Site" -Name "Myrtille" -PhysicalPath $InstallPath -ApplicationPool "MyrtilleAppPool"
        Set-ItemProperty -Path "IIS:\Sites\Default Web Site\Myrtille" -Name "enabledProtocols" -Value "http,https"
        Write-Output "Created Myrtille web application, protocols enabled: http,https"
    }
    catch
    {
        Write-Output "Failed to create Myrtille web application" $_.Exception.Message
        $ExitCode = 1
    }
}
else
{
    Write-Output "Myrtille web application already exists"
}

# give time to read console
if ($DebugMode)
{
	Read-Host "`r`nPress ENTER to continue..."
}

ExitWithCode($ExitCode)