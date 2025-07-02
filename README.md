# M3U8 Stream Inspector

A pair of simple, interactive command-line scripts for quickly analyzing HLS (`.m3u8`) streams. These tools allow you to check if a stream is protected by DRM and view its variant stream information, such as resolution and bandwidth.

The scripts are available for both Linux/macOS (Bash) and Windows (PowerShell).

## Features

-   **DRM Detection**: Instantly checks if a stream is encrypted by looking for the `#EXT-X-KEY` tag in the manifest.
-   **Stream Analysis**: Parses master playlists to display available stream variants, including bandwidth, resolution, and codecs.
-   **Interactive Loop**: After analyzing a link, the script prompts you to either enter another URL or exit, allowing for continuous use.
-   **Cross-Platform**: Separate, native scripts are provided for both Unix-like systems (Linux, macOS) and Windows.
-   **No Dependencies**: The scripts use standard, built-in command-line tools (`curl`, `awk` on Linux; `Invoke-WebRequest` on Windows) and require no external libraries.

---

## Installation and Usage

Choose the method that best fits your operating system and workflow.

### Option 1: Native Installation (Recommended for Quick Use)

#### For Linux and macOS (`inspect_m3u8.sh`)

1.  **Download the Script**
    Save the `inspect_m3u8.sh` file to your computer.

2.  **Open Your Terminal**
    Open a terminal window and navigate to the directory where you saved the file.
    ```bash
    cd ~/Downloads
    ```

3.  **Make the Script Executable**
    You need to give the file permission to be executed. This is a one-time security step required by Linux and macOS.
    ```bash
    chmod +x inspect_m3u8.sh
    ```

4.  **Run the Script**
    Now you can run the script from your terminal.
    ```bash
    ./inspect_m3u8.sh
    ```
    The script will then prompt you to enter an M3U8 stream URL.

#### For Windows (`Inspect-M3U8.ps1`)

1.  **Download the Script**
    Save the `Inspect-M3U8.ps1` file to your computer.

2.  **Open PowerShell**
    You can open PowerShell by searching for it in the Start Menu.

3.  **Navigate to the Script's Location**
    Use the `cd` command to navigate to the directory where you saved the file.
    ```powershell
    cd C:\Users\YourUser\Downloads
    ```

4.  **Set the Execution Policy (If Needed)**
    By default, Windows may prevent you from running PowerShell scripts downloaded from the internet. If you see an error, run the following command. This command changes the policy only for the current PowerShell session and is very safe.
    ```powershell
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    ```

5.  **Run the Script**
    Execute the script by typing its name.
    ```powershell
    .\Inspect-M3U8.ps1
    ```
    The script will then prompt you to enter an M3U8 stream URL.

---

### Option 2: Using Docker (Universal Method)

This method allows you to run the `inspect_m3u8.sh` script on any system with Docker installed (Windows, macOS, or Linux), guaranteeing a consistent environment.

1.  **Prerequisites**
    -   Ensure you have [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running on your system.

2.  **Download the Files**
    Download both the `inspect_m3u8.sh` and the `Dockerfile` from the repository. Make sure you place them in the same directory on your computer.

3.  **Build the Docker Image**
    Open a terminal or PowerShell window, navigate to the directory containing your `Dockerfile` and script, and run the build command. This creates a reusable image named `m3u8-inspector`. You only need to do this once.
    ```bash
    docker build -t m3u8-inspector .
    ```

4.  **Run the Script in a Container**
    Now, any time you want to run the script, use the `docker run` command. The `-it` flag makes the session interactive, and `--rm` cleans up the container after you exit.
    ```bash
    docker run -it --rm m3u8-inspector
    ```
    The container will start, and you will be prompted to enter the M3U8 URL directly in your terminal. Remember, the `docker build` command is a one-time setup. You can use `docker run` to execute the script anytime without rebuilding.

## How It Works

The primary method for DRM detection is to download the M3U8 manifest file and scan its contents for the `#EXT-X-KEY` tag. According to the HLS specification, this tag specifies how to decrypt media segments. If the tag is present, the script reports that the stream is DRM protected. It then uses regular expressions and text-parsing tools to extract other metadata for a high-level analysis of the stream's properties.
