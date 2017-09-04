@echo off
Title SeleniumTest

pushd %~dp0
cls

PowerShell.exe -ExecutionPolicy Unrestricted -File "%CD%\Scripts\SeleniumTest.ps1"
