Clear-Host
Write-Host "----- Ollama Multi-Model Updater -----`r`n"
Write-Host "Listing Models..`r`n"
ollama list
(Invoke-RestMethod http://localhost:11434/api/tags).Models.Name.ForEach{ Write-Host "`r`nUpdating:" $_ ; ollama pull $_ }
