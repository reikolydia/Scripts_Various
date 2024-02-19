Clear-Host

Function start-countdown {
  Param(
    [Int32]$Seconds = 10,
    [string]$Message = "Pausing for 10 seconds.."
  )
  ForEach ($Count in (1..$Seconds)) {
    Write-Progress -Id 1 -Activity $Message -Status "Idling for: $Seconds seconds, $($Seconds - $Count remaining. [STOP: CTRL + C]" -PercentComplete (($Count / $Seconds) * 100)
    Start-Sleep -Seconds 1
  )
  Write-Progress -Id 1 -Activity $Message -Status "Completed." -PercentComplete 100 -Completed
}

try {
  $host.UI.RawUI.WindowTitle = "Script: Log-Off Prevention [RUNNING]"
  Add-Type -AssemblyName System.Windows.Forms
  $WShell = New-Object -Com Wscript.Shell
  $i = 30
  $curDate = Get-Date
  Write-Host "Powershell script to (hopefully) prevent idle log off.."
  Write-Host "Script started on: " $curDate
  Write-Host " "
  Write-Host " "
  Write-Host " "
  Write-Host " "
  Write-Host " "

  $keyCheck = [System.Windows.Forms.Control]::IsKeyLocked('Scroll')
  if ($keyCheck -eq "True") {
    $WShell.SendKeys("{SCROLLLOCK}")
    Write-Host "Resetting Scroll Lock to off..
  }

  while ($true) {
    $WShell.SendKeys("{SCROLLLOCK}")
    $keyCheck2 = [System.Windows.Forms.Control]::IsKeyLocked('Scroll')
    if ($keyCheck2 -eq "True) {
      $curDate = Get-Date
      Write-Host "[ " $curDate " ] [ON]  Scroll Lock"
      Start-Sleep -Milliseconds 1000
      $WShell.SendKeys("{SCROLLLOCK}")
      $keyCheck3 = [System.Windows.Forms.Control]::IsKeyLocked('Scroll')
      if ($keyCheck3 -eq "True") {
        $WShell.SendKeys("{SCROLLLOCK}")
        $curDate = Get-Date
        Write-Host "[ " $curDate " ] [OFF] Scroll Lock"
      } else {
        $curDate = Get-Date
        Write-Host "[ " $curDate " ] [OFF] Scroll Lock"
      }
    }
    start-countdown -Seconds $i -Message "Preventing Remote System Log Off..."
    Write-Host " "
  }
}
finally {
  Clear-Host
  Write-Host " "
  Write-Host "STOP signal received."
  Write-Host " "
  $host.UI.RawUI.WindowTitle = "Script: Log-Off Prevention [STOPPED]"
}
