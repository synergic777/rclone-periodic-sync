while ($true) {
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Checking for video files..." -ForegroundColor Cyan
    
    # Get all files recursively from the Captures folder and all subfolders
    $files = Get-ChildItem "$env:USERPROFILE\Videos\Captures" -File -Recurse
    
    if ($files.Count -eq 0) {
        Write-Host "No files found in Captures folder or subfolders. Waiting 5 minutes..." -ForegroundColor Yellow
    } else {
        Write-Host "Found $($files.Count) file(s) to process:" -ForegroundColor Green
        foreach ($file in $files) {
            $relativePath = $file.FullName.Replace("$env:USERPROFILE\Videos\Captures\", "")
            Write-Host "  - $relativePath ($([math]::Round($file.Length / 1MB, 2)) MB)" -ForegroundColor Gray
        }
        
        foreach ($file in $files) {
            # Calculate relative path from Captures folder
            $relativePath = $file.FullName.Replace("$env:USERPROFILE\Videos\Captures\", "")
            $relativeDir = Split-Path $relativePath -Parent
            
            Write-Host "`nProcessing: $relativePath" -ForegroundColor White
            Write-Host "Uploading to Google Drive..." -ForegroundColor Blue
            
            # All files go to the same destination folder regardless of source subfolder
            $gdrivePath = "gdrive:Captures"
            Write-Host "Destination: Captures" -ForegroundColor Gray
            
            # Copy single file to preserve folder structure
            rclone copy "$($file.FullName)" "$gdrivePath" --progress --bwlimit 1.25M
            
            # Delete local file only if copy succeeded
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Upload successful! Deleting local file..." -ForegroundColor Green
                Remove-Item "$($file.FullName)" -Force
                Write-Host "Local file deleted: $relativePath" -ForegroundColor Green
                
                # Check if parent directory is empty and remove it if so
                $parentDir = Split-Path $file.FullName -Parent
                if ($parentDir -ne "$env:USERPROFILE\Videos\Captures") {
                    try {
                        $remainingFiles = Get-ChildItem $parentDir -Force -ErrorAction SilentlyContinue
                        if ($remainingFiles.Count -eq 0) {
                            Remove-Item $parentDir -Force -Recurse -ErrorAction SilentlyContinue
                            Write-Host "Removed empty directory: $(Split-Path $relativePath -Parent)" -ForegroundColor Yellow
                        }
                    } catch {
                        # Silently ignore errors when checking/removing empty directories
                    }
                }
            } else {
                Write-Host "Upload failed (Exit code: $LASTEXITCODE). Keeping local file." -ForegroundColor Red
            }
        }
        
        Write-Host "`nBatch complete. Processed $($files.Count) file(s)." -ForegroundColor Magenta
    }
    
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Waiting before next check...`n" -ForegroundColor Cyan
    Start-Sleep -Seconds 10
}
