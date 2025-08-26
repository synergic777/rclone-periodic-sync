# Enhanced video file sync script with comprehensive feedback
$capturesPath = "$env:USERPROFILE\Videos\Captures"
$destination = "gdrive:PC-Videos"
$cycleCount = 0

Write-Host "=== Video File Sync Script Started ===" -ForegroundColor Green
Write-Host "Source: $capturesPath" -ForegroundColor Cyan
Write-Host "Destination: $destination" -ForegroundColor Cyan
Write-Host "Bandwidth limit: 1.25MB/s" -ForegroundColor Cyan
Write-Host "Check interval: 5 minutes" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Yellow

while ($true) {
    $cycleCount++
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    Write-Host "`n[$timestamp] Starting sync cycle #$cycleCount" -ForegroundColor Yellow
    
    # Check if source directory exists
    if (-not (Test-Path $capturesPath)) {
        Write-Host "ERROR: Source directory not found: $capturesPath" -ForegroundColor Red
        Write-Host "Waiting 5 minutes before retry..." -ForegroundColor Yellow
        Start-Sleep -Seconds 300
        continue
    }
    
    # Get list of files
    Write-Host "Scanning for files in: $capturesPath" -ForegroundColor Cyan
    $files = Get-ChildItem $capturesPath -File
    
    if ($files.Count -eq 0) {
        Write-Host "No files found to sync." -ForegroundColor Gray
    } else {
        Write-Host "Found $($files.Count) file(s) to process:" -ForegroundColor Green
        foreach ($file in $files) {
            Write-Host "  - $($file.Name) ($([math]::Round($file.Length/1MB, 2)) MB)" -ForegroundColor White
        }
        
        # Process each file
        $processedCount = 0
        $successCount = 0
        $failCount = 0
        
        foreach ($file in $files) {
            $processedCount++
            Write-Host "`n--- Processing file $processedCount/$($files.Count) ---" -ForegroundColor Magenta
            Write-Host "File: $($file.Name)" -ForegroundColor White
            Write-Host "Size: $([math]::Round($file.Length/1MB, 2)) MB" -ForegroundColor White
            Write-Host "Starting upload..." -ForegroundColor Yellow
            
            # Record start time for upload duration
            $uploadStart = Get-Date
            
            # Copy file with rclone
            rclone copy "$($file.FullName)" $destination --progress --bwlimit 1.25M
            
            $uploadEnd = Get-Date
            $uploadDuration = $uploadEnd - $uploadStart
            
            # Check if copy succeeded
            if ($LASTEXITCODE -eq 0) {
                $successCount++
                Write-Host "✓ Upload successful! (Duration: $($uploadDuration.ToString('mm\:ss')))" -ForegroundColor Green
                Write-Host "Deleting local file..." -ForegroundColor Yellow
                
                try {
                    Remove-Item "$($file.FullName)" -Force
                    Write-Host "✓ Local file deleted successfully" -ForegroundColor Green
                } catch {
                    Write-Host "✗ ERROR: Failed to delete local file: $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                $failCount++
                Write-Host "✗ Upload failed! (Exit code: $LASTEXITCODE)" -ForegroundColor Red
                Write-Host "Local file preserved for retry" -ForegroundColor Yellow
            }
        }
        
        # Cycle summary
        Write-Host "`n=== Cycle #$cycleCount Summary ===" -ForegroundColor Yellow
        Write-Host "Files processed: $processedCount" -ForegroundColor White
        Write-Host "Successful uploads: $successCount" -ForegroundColor Green
        Write-Host "Failed uploads: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Gray" })
    }
    
    # Wait for next cycle
    $nextCheck = (Get-Date).AddMinutes(5).ToString("HH:mm:ss")
    Write-Host "`nWaiting 5 minutes... (Next check at $nextCheck)" -ForegroundColor Gray
    Write-Host "Press Ctrl+C to stop the script" -ForegroundColor DarkGray
    
    Start-Sleep -Seconds 300
}
