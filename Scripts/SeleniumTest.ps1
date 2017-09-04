# SeleniumTest
$ScriptPath = $MyInvocation.MyCommand.Path;
$MainFolder = Split-Path -Path $ScriptPath;
#$MainFolder = $PSScriptRoot

$SeleniumHome = "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\Selenium"
If (!(Test-Path -Path $SeleniumHome)) {
	$SeleniumHome = Resolve-Path (Read-Host "Selenium Home")
}

#Import-Module
cls

Function RunAsAdmin([string]$Command, [string]$File) {
	[Security.Principal.WindowsPrincipal]$CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
	If (!($CurrentIdentity.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
		#$PSOptions = "-NoProfile -NoLogo -ExecutionPolicy Bypass " #-WindowStyle Hidden
		If ($File) {
			$args = "& '" + $File + "'"
		} ElseIf ($Command) {
			#$args = '"' + "-Command `"" + $Command + "`"" + '"'
			$args = "-Command `"" + $Command + "`""
		} Else { return }
		#Start-Process PowerShell.exe -Verb runAs -ArgumentList $args
		Start-Process PowerShell.exe -Verb RunAs -ArgumentList $args
	}
}

##Install NuGet PackageProvider
#If (!(Get-PackageProvider -Name NuGett -ErrorAction SilentlyContinue)) {
#	RunAsAdmin -Command "Install-PackageProvider -Name NuGet -Force"
#}

ForEach ($Directory in ($env:PSModulePath -split ';')) {
	$PSModulesSelenium = (Join-Path $Directory Selenium)
	If (Test-Path -Path $PSModulesSelenium) {
		$SeleniumHome = $PSModulesSelenium
		break
	}
}
If ($SeleniumHome -ne "") {
	Get-ChildItem -Recurse -Path (Join-Path $SeleniumHome \*.dll) | % {
		[System.Reflection.Assembly]::LoadFile($_) | Out-Null
	}
} Else {
	cls; Write-Host "Selenium not found under PSModulesPath"; Start-Sleep -Seconds 3; exit
}





#Get-ChildItem -Recurse -Path (Join-Path $SeleniumHome \*.dll) | % {
	#$FilePath = $_
	$FilePath = 'C:\Windows\System32\WindowsPowerShell\v1.0\Modules\Selenium\WebDriver.dll'
	$Library = [System.Reflection.Assembly]::LoadFile($FilePath)
	$LibraryName = ($Library.FullName -split ',')[0]
	Write-Host ("$LibraryName" + "`n" + $('=' * $LibraryName.Length) + "`n")
	$Library.GetTypes() | Select Name, Namespace | Sort Namespace | Format-Table -GroupBy Namespace
	Write-Host ""
	
#}





