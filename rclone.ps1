while ($true) {
    $files = Get-ChildItem "$env:USERPROFILE\Videos\Captures" -File

    foreach ($file in $files) {
        # Copy single file
        rclone copy "$($file.FullName)" gdrive:PC-Videos --progress --bwlimit 1.25M

        # Delete local file only if copy succeeded
        if ($LASTEXITCODE -eq 0) {
            Remove-Item "$($file.FullName)" -Force
        }
    }

    Start-Sleep -Seconds 300
}
