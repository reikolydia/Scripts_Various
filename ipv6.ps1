if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}
Clear-Host
Write-Host "IPv6 Status"
Get-NetAdapterBinding -ComponentID ms_tcpip6 | Format-Table -Property Name,Enabled -AutoSize
$options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Disable IPv6", "&Enable IPv6", "&Quit")
[int]$defaultchoice = 2
$opt = $host.UI.PromptForChoice($Title , $Info , $Options, $defaultchoice)
switch ($opt) {
	0 {
		Write-Host "`nDisabling IPv6" -ForegroundColor Green
		Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
		Get-NetAdapterBinding -ComponentID ms_tcpip6 | Format-Table -Property Name,Enabled -AutoSize
		pause
	}
	1 {
		Write-Host "`nEnabling IPv6" -ForegroundColor Green
		Enable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
		Get-NetAdapterBinding -ComponentID ms_tcpip6 | Format-Table -Property Name,Enabled -AutoSize
		pause
	}
	2 {
		Write-Host "`nExit" -ForegroundColor Green
		exit
	}
}