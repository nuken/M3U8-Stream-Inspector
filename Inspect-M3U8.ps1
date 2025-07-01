# M3U8 Stream Inspector - PowerShell Version
# This script prompts for an M3U8 URL, downloads the manifest,
# and checks for DRM protection and stream variant information.

# Set the output encoding to UTF-8 to correctly display special characters.
# This helps, but console font/settings can still cause issues.
$OutputEncoding = [System.Text.Encoding]::UTF8

# --- Main Script Loop ---
while ($true) {
    Clear-Host
    Write-Host "=======================================" -ForegroundColor Cyan
    Write-Host "=== M3U8 Stream Inspector (PowerShell) ===" -ForegroundColor Cyan
    Write-Host "=======================================" -ForegroundColor Cyan
    Write-Host

    # Prompt for the M3U8 URL
    $m3u8Url = Read-Host "Enter the M3U8 stream URL"

    if ([string]::IsNullOrWhiteSpace($m3u8Url)) {
        Write-Host "Error: No URL entered." -ForegroundColor Red
    }
    else {
        Write-Host "`nFetching and analyzing the M3U8 manifest..." -ForegroundColor Yellow

        try {
            # --- Download the M3U8 manifest content ---
            # Using System.Net.WebClient for better reliability with raw text.
            $webClient = New-Object System.Net.WebClient
            # Set a common user agent to mimic a browser and avoid being blocked.
            $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
            $manifestContent = $webClient.DownloadString($m3u8Url)

            # --- DRM Protection Check ---
            Write-Host "`n--- DRM Information ---" -ForegroundColor Cyan
            if ($manifestContent -match '#EXT-X-KEY') {
                Write-Host "> DRM Protection: Yes" -ForegroundColor Red
                $drmInfo = $manifestContent | Select-String -Pattern '#EXT-X-KEY'
                Write-Host "  Details: $($drmInfo.Line)"
            }
            else {
                Write-Host "> DRM Protection: No" -ForegroundColor Green
            }
            Write-Host

            # --- Stream Information ---
            Write-Host "--- Stream Variants ---" -ForegroundColor Cyan

            # Check if it's a master playlist
            if ($manifestContent -match '#EXT-X-STREAM-INF') {
                # Split the manifest into an array of lines for easier processing
                $lines = $manifestContent -split "`r`n|`n|`r"
                $streamInfoFound = $false

                # Loop through each line to find stream info and its corresponding URL
                for ($i = 0; $i -lt $lines.Length; $i++) {
                    if ($lines[$i] -match '#EXT-X-STREAM-INF') {
                        $streamInfoFound = $true
                        $infoLine = $lines[$i]
                        # The stream URL is typically the next line that isn't empty or another tag
                        $streamUrlLine = ""
                        for ($j = $i + 1; $j -lt $lines.Length; $j++) {
                            if (-not [string]::IsNullOrWhiteSpace($lines[$j]) -and $lines[$j] -notlike '#EXT*') {
                                $streamUrlLine = $lines[$j].Trim()
                                break
                            }
                        }


                        # Extract details using regex -match
                        $bandwidth = "N/A"
                        $resolution = "N/A"
                        $codecs = "N/A"

                        if ($infoLine -match 'BANDWIDTH=(\d+)') { $bandwidth = $matches[1] }
                        if ($infoLine -match 'RESOLUTION=([\d]+x[\d]+)') { $resolution = $matches[1] }
                        if ($infoLine -match 'CODECS="([^"]+)"') { $codecs = $matches[1] }

                        Write-Host "  > Variant Stream:"
                        Write-Host "    - Bandwidth:  $($bandwidth) bps"
                        Write-Host "    - Resolution: $resolution"
                        Write-Host "    - Codecs:     $codecs"
                        Write-Host "    - URL:        $streamUrlLine"
                    }
                }

                if (-not $streamInfoFound) {
                    Write-Host "No detailed stream variants found in the master playlist." -ForegroundColor Yellow
                }
            }
            else {
                # This is likely a media playlist (contains media segments)
                Write-Host "This appears to be a media playlist, not a master playlist." -ForegroundColor Yellow
                
                if($manifestContent -match '#EXT-X-TARGETDURATION:(\d+)') {
                    Write-Host "  > Target Duration: $($matches[1])s"
                }
                if($manifestContent -match '#EXT-X-MEDIA-SEQUENCE:(\d+)') {
                    Write-Host "  > Media Sequence: $($matches[1])"
                }
                
                $segmentCount = ($manifestContent | Select-String -Pattern '#EXTINF' -AllMatches).Matches.Count
                Write-Host "  > Number of Segments: $segmentCount"
            }
        }
        catch {
            # Catch errors from the web request (e.g., invalid URL, no connection)
            Write-Host "`nError: Failed to download or process the manifest." -ForegroundColor Red
            Write-Host "Please check the URL and your internet connection." -ForegroundColor Red
            Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Gray
        }
    }

    Write-Host "`n=======================================" -ForegroundColor Cyan
    
    # Prompt to continue or exit
    $choice = Read-Host "Press Enter to check another link, or type 'e' to exit"
    if ($choice -eq 'e') {
        break
    }
}

Clear-Host
Write-Host "Exiting script. Goodbye!" -ForegroundColor Green
