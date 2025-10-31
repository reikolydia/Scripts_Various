function venv_activate {
    $currentDir = (Get-Location).Path
    $files = Get-ChildItem -Path . -Filter Activate.ps1 -Recurse -Depth 3 | Select-Object -ExpandProperty FullName
    $relFolders = $files | ForEach-Object {
        $relPath = $_.Substring($currentDir.Length).TrimStart('\','/')
        $parts = $relPath -split '[\\/]'
        $scriptIndex = $parts.IndexOf('Scripts')
        if ($scriptIndex -gt 0) {
            $parts[$scriptIndex - 1]
        } else {
            $parts[0]
        }
    }
    $uniqFolders = $relFolders | Sort-Object -Unique
    if ($files.Count -eq 0) {
        Write-Host "NO VIRTUAL ENVIRONMENT DETECTED!"
        return
    } elseif ($files.Count -eq 1) {
        Write-Host "Activating: $($uniqFolders)"
        & "$($files)"
    } else {
        for ($i=0; $i -lt $uniqFolders.Count; $i++) {
            $displayIndex = $i + 1
            Write-Host "$displayIndex. $($uniqFolders[$i])"
        }
        $choice = Read-Host "Select virtual environment"
        if ([int]::TryParse($choice, [ref]$null) -and $choice -ge 1 -and $choice -le $uniqFolders.Count) {
            $selFolder = $uniqFolders[$choice - 1]
            $selFile = $files | Where-Object { $_ -match "\\$selFolder\\Scripts\\Activate.ps1$" } | Select-Object -First 1
            if ($selFile) {
                Write-Host "Activating: $selFolder"
                & "$selFile"
            } else {
                Write-Host "No Activate.ps1 found in selected folder!"
            }
        } else {
            Write-Host " Invalid selection!"
        }
    }
    #$file = Get-ChildItem Activate.ps1 -Recurse -Depth 2 | ForEach-Object{$_.FullName} | Select-Object -First 1
    #Write-Host "Activating: $file" 
    #& "$($file)"
    # for compatibility with oh-my-posh and venv:
    # search for, and add $env:VIRTUAL_ENV_DISABLE_PROMPT = 1
    # $env:VIRTUAL_ENV = $VenvDir
    #>>>>>>> $env:VIRTUAL_ENV_DISABLE_PROMPT = 1
    # if (-not $Env:VIRTUAL_ENV_DISABLE_PROMPT) {
}

Set-Alias activate venv_activate
