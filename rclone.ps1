while ($true) {
    rclone sync "$env:USERPROFILE\Videos" gdrive:PC-Videos --progress --bwlimit 1.25M
    Start-Sleep -Seconds 300  # Wait 5 minutes
}
