# SeleniumTest
#$ScriptPath = $MyInvocation.MyCommand.Path;
#$FolderScripts = Split-Path -Path $ScriptPath;
$FolderScripts = $PSScriptRoot
$FolderMain = Split-Path -Path $FolderScripts
$FolderResources = $FolderMain + '\Resources'
$FolderOutput = $FolderMain + '\Output'

$SeleniumHome = "" #"C:\Windows\System32\WindowsPowerShell\v1.0\Modules\Selenium"

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

Function LoadAssembly([string]$HomeDir, [string]$FileExt) {
	If (!$FileExt) { [string]$FileExt = '*' }
	$files = Get-ChildItem -Recurse -Path (Join-Path $HomeDir \*.$FileExt)
	ForEach ($file in $files) {
		try {
			[System.Reflection.Assembly]::LoadFile($file) | Out-Null
		} catch {
			Write-Host ("Cannot load file: " + (Split-Path -Path $file -Leaf))
		}
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




# Import Libraries
$FolderClosedXml = $FolderResources + '\ClosedXML'
LoadAssembly -HomeDir $FolderClosedXml -FileExt dll
















##Get-ChildItem -Recurse -Path (Join-Path $SeleniumHome \*.dll) | % {
#	#$FilePath = $_
#	#$FilePath = 'C:\Windows\System32\WindowsPowerShell\v1.0\Modules\Selenium\WebDriver.dll'
#	$FilePath = 'C:\Data\BuildServer\Bamboo\SeleniumTest\Resources\ClosedXML\ClosedXML.dll'
#	[System.Reflection.Assembly]::LoadFile("C:\Data\BuildServer\Bamboo\SeleniumTest\Resources\ClosedXML\DocumentFormat.OpenXml.dll")
#	$Library = [System.Reflection.Assembly]::LoadFile($FilePath)
#	$LibraryName = ($Library.FullName -split ',')[0]
#	Write-Host ("$LibraryName" + "`n" + $('=' * $LibraryName.Length) + "`n")
#	
#	try {$Library.GetTypes()} catch {$err = $_} #| Select Name, Namespace | Sort Namespace | Format-Table -GroupBy Namespace
#	Write-Host ""
#	
#	
#	[Reflection.Assembly]::GetAssembly('ClosedXML')
#	$asm = [System.IO.StreamWriter]
#	$asm.GetMethods() | Select Name | Sort-Object name | Get-Unique -AsString
#	
#	Add-Type -LiteralPath 'C:\Data\BuildServer\Bamboo\SeleniumTest\Resources\ClosedXML\DocumentFormat.OpenXml.dll'
#	Add-Type -LiteralPath 'C:\Data\BuildServer\Bamboo\SeleniumTest\Resources\ClosedXML\ClosedXML.dll'
#	[ClosedXml] | Get-Member -MemberType Method
#	
#	$dllPath = 'C:\Data\BuildServer\Bamboo\SeleniumTest\Resources\ClosedXML\ClosedXML.dll'
#	[System.IO.File]::WriteAllLines(($FolderOutput + '\DllMethods.log'),[System.Reflection.Assembly]::LoadFile($dllPath).GetTypes())
#	
#	System.IO.File.WriteAllLines(myFileName,
#                System.Reflection.Assembly.LoadFile(myDllPath)
#                    .GetType(className)
#                    .GetMethods()
#                    .Select(m => m.Name)
#                    .ToArray());
#	
##}





