#!/bin/bash

# Function to display colored output
print_color() {
    COLOR=$1
    TEXT=$2
    NC='\033[0m' # No Color
    case $COLOR in
        "red")
            echo -e "\033[0;31m${TEXT}${NC}"
            ;;
        "green")
            echo -e "\033[0;32m${TEXT}${NC}"
            ;;
        "yellow")
            echo -e "\033[1;33m${TEXT}${NC}"
            ;;
        "blue")
            echo -e "\033[0;34m${TEXT}${NC}"
            ;;
        *)
            echo "$TEXT"
            ;;
    esac
}

# --- Main Script Loop ---
while true; do
    clear
    print_color "blue" "======================================="
    print_color "blue" "=== M3U8 Stream Inspector ==="
    print_color "blue" "======================================="
    echo

    # Prompt for the M3U8 URL
    read -p "Enter the M3U8 stream URL: " m3u8_url

    if [ -z "$m3u8_url" ]; then
        print_color "red" "Error: No URL entered."
    else
        echo
        print_color "yellow" "Fetching and analyzing the M3U8 manifest..."
        echo

        # Download the M3U8 manifest content
        manifest_content=$(curl -s "$m3u8_url")

        # Check if the download was successful
        if [ -z "$manifest_content" ]; then
            print_color "red" "Error: Failed to download the manifest. Please check the URL and your internet connection."
        else
            # --- DRM Protection Check ---
            print_color "blue" "--- DRM Information ---"
            if echo "$manifest_content" | grep -q 'EXT-X-KEY'; then
                print_color "red" "▶ DRM Protection: Yes"
                drm_info=$(echo "$manifest_content" | grep 'EXT-X-KEY')
                echo "  Details: $drm_info"
            else
                print_color "green" "▶ DRM Protection: No"
            fi
            echo

            # --- Stream Information ---
            print_color "blue" "--- Stream Variants ---"

            # Check if it's a master playlist
            if echo "$manifest_content" | grep -q 'EXT-X-STREAM-INF'; then
                # Use awk to parse stream information (MORE COMPATIBLE VERSION)
                stream_info=$(echo "$manifest_content" | awk '
                /#EXT-X-STREAM-INF:/ {
                    info = $0

                    bandwidth="N/A"
                    resolution="N/A"
                    codecs="N/A"

                    if (match(info, /BANDWIDTH=([0-9]+)/)) {
                        start = RSTART + length("BANDWIDTH=")
                        end = RSTART + RLENGTH - 1
                        bandwidth = substr(info, start, end - start + 1)
                    }
                    if (match(info, /RESOLUTION=([0-9]+x[0-9]+)/)) {
                        start = RSTART + length("RESOLUTION=")
                        end = RSTART + RLENGTH - 1
                        resolution = substr(info, start, end - start + 1)
                    }
                    if (match(info, /CODECS="([^"]+)"/)) {
                        start = RSTART + length("CODECS=\"")
                        end = RSTART + RLENGTH - 2
                        codecs = substr(info, start, end - start + 1)
                    }

                    # Get the stream URL which is the line after the stream info
                    getline stream_url

                    printf "  ▶ Variant Stream:\n"
                    printf "    - Bandwidth: %s bps\n", bandwidth
                    printf "    - Resolution: %s\n", resolution
                    printf "    - Codecs: %s\n", codecs
                    printf "    - URL: %s\n", stream_url
                }')

                if [ -n "$stream_info" ]; then
                    echo "$stream_info"
                else
                    print_color "yellow" "No detailed stream variants found in the master playlist."
                fi
            else
                # This is likely a media playlist (contains media segments)
                print_color "yellow" "This appears to be a media playlist, not a master playlist."

                target_duration=$(echo "$manifest_content" | grep '#EXT-X-TARGETDURATION' | cut -d: -f2)
                media_sequence=$(echo "$manifest_content" | grep '#EXT-X-MEDIA-SEQUENCE' | cut -d: -f2)

                if [ -n "$target_duration" ]; then
                    echo "  ▶ Target Duration: ${target_duration}s"
                fi
                if [ -n "$media_sequence" ]; then
                    echo "  ▶ Media Sequence: $media_sequence"
                fi

                segment_count=$(echo "$manifest_content" | grep -c '#EXTINF')
                echo "  ▶ Number of Segments: $segment_count"
            fi
        fi
    fi

    echo
    print_color "blue" "======================================="

    # Prompt to continue or exit
    read -p "Press Enter to check another link, or type 'e' to exit: " choice
    if [[ "$choice" == "e" || "$choice" == "E" ]]; then
        break
    fi
done

clear
print_color "green" "Exiting script. Goodbye! 👋"
