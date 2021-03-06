# SeleniumTest
#$ScriptPath = $MyInvocation.MyCommand.Path;
#$FolderScripts = Split-Path -Path $ScriptPath;
$FolderScripts = $PSScriptRoot
$FolderMain = Split-Path -Path $FolderScripts
$FolderResources = $FolderMain + '\Resources'
$FolderOutput = $FolderMain + '\Output'

$SeleniumHome = "" #"C:\Windows\System32\WindowsPowerShell\v1.0\Modules\Selenium"

cls

# Prerequisites
try {
	Import-Module PSNuGet -ErrorAction Inquire
} catch {
	$err = $_
	Write-Host $err -ForegroundColor Red
	Start-Sleep -Seconds 5
	exit
}


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




#region iTextSharp
$PkgId = "iTextSharp"
#$NugetPkg = Find-LocalNuGetPackage -PackageId "$PkgId"
If ([string]::IsNullOrEmpty((Find-LocalNuGetPackage -PackageId "$PkgId").Id)) {
	Use-NuGetPackage -PackageId "$PkgId" #-Verbose
}
#Clear-NuGetPackage -PackageId "$PkgId"

Function Convert-Txt2Pdf([string]$SourceFile, [string]$DestFile, [switch]$OpenFileWhenDone) {
	#[System.Reflection.Assembly]::LoadFrom("C:\Data\BuildServer\Bamboo\SeleniumTest\Resources\iTextSharp\itextsharp.dll") | Out-Null
	If (Test-Path -Path $DestFile) {
		Write-Host "File Already Exists: $DestFile"
		$UsrInput = Read-Host "Replace? (Y|N)"
		If ($UsrInput -ieq "N") {
			return "Cancelled"
		} Else {
			Remove-Item -Path $DestFile -Force
		}
	}
	try {
		$doc = New-Object iTextSharp.Text.Document
		$stream = [IO.File]::OpenWrite("$DestFile")
		$writer = [iTextSharp.Text.pdf.PdfWriter]::GetInstance($doc, $stream)
		$doc.Open()
	
		[IO.File]::ReadAllLines("$SourceFile") | % {
			$line = New-Object iTextSharp.Text.Paragraph($_)
			$doc.Add($line) | Out-Null
		}
		$doc.Close()
		$stream.Close()
		If ($OpenFileWhenDone) { Invoke-Item -Path $DestFile }
		return $DestFile
	} catch {
		$err = $_
		return $err
	}
}

Convert-Txt2Pdf -SourceFile "C:\Temp\whitesource-fs-agent.config" -DestFile "$FolderOutput\Test.pdf" -OpenFileWhenDone



#endregion iTextSharp


exit

#region ClosedXml

#Check if package exists
$PkgId = "ClosedXML"
#$NugetPkg = Find-LocalNuGetPackage -PackageId "$PkgId"
If ([string]::IsNullOrEmpty((Find-LocalNuGetPackage -PackageId "$PkgId").Id)) {
	Use-NuGetPackage -PackageId "$PkgId" #-Verbose
}

#Clear-NuGetPackage -PackageId "$PkgId"
$DllDir = "C:\Data\BuildServer\Bamboo\SeleniumTest\Resources\ClosedXML"

pushd "C:\Data\BuildServer\Bamboo\SeleniumTest\Resources\ClosedXML"
try { Add-Type -Path "ClosedXML.dll" } catch { $err = $_ }
popd

#Set .Net current path
[IO.Directory]::SetCurrentDirectory("$DllDir")
[Reflection.Assembly]::LoadFrom("$DllDir\ClosedXML.dll") | Out-Null

#[ClosedXML.Excel.XLWorkbook]

#Output Excel file to current directory
$workbook = New-Object ClosedXML.Excel.XLWorkbook
$worksheet = $workbook.Worksheets.Add("Sample Sheet");
$worksheet.Cell("A1").Value = "Hello World!";
$workbook.SaveAs("HelloWorld.xlsx");
$worksheet.Dispose()

#Open Excel File
#explorer "HelloWorld.xlsx"





# Import Libraries
$FolderClosedXml = $FolderResources + '\ClosedXML'
LoadAssembly -HomeDir $FolderClosedXml -FileExt dll

[System.Reflection.Assembly]::LoadFile("C:\Data\BuildServer\Bamboo\SeleniumTest\Resources\ClosedXML\ClosedXML.dll")

$ProcExes = Get-WmiObject -Class CIM_ProcessExecutable -Namespace root\cimv2 | % { try { [Wmi]"$($_.Antecedent)" } catch {} }

$ProcExes | ? { $_.FileName -match ".*(Closed).*" } | % { $_.FileName }

[ClosedXML.Excel.XLColor]::AirForceBlue


([Wmi]"$($ProcExes[50].Antecedent)").Manufacturer|clip

ForEach ($proc in $ProcExes) {
	try {
		$curObj = [Wmi]"$($proc.Antecedent)"
		If (($curObj.Manufacturer -notmatch ".*((Microsoft Corporation)|(Intel)|(Google)|(Stardock)|(Logitech)).*") `
			-and ($curObj.Extension -eq "dll")) {
			$curObj | Select FileName,Manufacturer
		}
	} catch {}
}

$ProcExes | ? { $_.Manufacturer -ne "Microsoft Corporation" } | % { try { [Wmi]"$($_.Antecedent)" | Select FileName,Extension,Manufacturer,Version } catch {} }


#Create the excel workbook
$WB = New-Object ClosedXML.Excel.XLWorkbook
#Add a new sheet and some data
$WS = $WB.Worksheets.Add("Test")
$WS.Cell("A1").Value = "No Data";
#Save the workbook
$DestFile = $FolderOutput + '\Test.xlsx'
$WB.SaveAs("$DestFile")

If (Test-Path -Path $DestFile) {
	Write-Host "Workbook created successfuly"
	Invoke-Item "$FolderOutput"
} Else {
	Write-Host "Workbook was not created"
}


#endregion ClosedXml



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





