while ($true) {
    rclone sync "$env:USERPROFILE\Videos" gdrive:PC-Videos --progress
    Start-Sleep -Seconds 300  # Wait 5 minutes
}