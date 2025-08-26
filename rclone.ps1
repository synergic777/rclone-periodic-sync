while ($true) {
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Checking for video files..." -ForegroundColor Cyan
    
    $files = Get-ChildItem "$env:USERPROFILE\Videos\Captures" -File
    
    if ($files.Count -eq 0) {
        Write-Host "No files found in Captures folder. Waiting 5 minutes..." -ForegroundColor Yellow
    } else {
        Write-Host "Found $($files.Count) file(s) to process:" -ForegroundColor Green
        foreach ($file in $files) {
            Write-Host "  - $($file.Name) ($([math]::Round($file.Length / 1MB, 2)) MB)" -ForegroundColor Gray
        }
        
        foreach ($file in $files) {
            Write-Host "`nProcessing: $($file.Name)" -ForegroundColor White
            Write-Host "Uploading to Google Drive..." -ForegroundColor Blue
            
            # Copy single file
            rclone copy "$($file.FullName)" gdrive:PC-Videos --progress --bwlimit 1.25M
            
            # Delete local file only if copy succeeded
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Upload successful! Deleting local file..." -ForegroundColor Green
                Remove-Item "$($file.FullName)" -Force
                Write-Host "Local file deleted: $($file.Name)" -ForegroundColor Green
            } else {
                Write-Host "Upload failed (Exit code: $LASTEXITCODE). Keeping local file." -ForegroundColor Red
            }
        }
        
        Write-Host "`nBatch complete. Processed $($files.Count) file(s)." -ForegroundColor Magenta
    }
    
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Waiting 5 minutes before next check...`n" -ForegroundColor Cyan
    Start-Sleep -Seconds 300
}
