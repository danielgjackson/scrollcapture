#!/bin/bash
set -e

# Settings
num_screenshots=5

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "PLATFORM: macOS"

    if ! command -v cliclick &> /dev/null
    then
        if ! command -v brew &> /dev/null
        then
            echo "ERROR: The cliclick command could not be found -- recommend installing homebrew first:    https://brew.sh/"
        else
            echo "ERROR: The cliclick command needs to be installed with:    brew install cliclick"
        fi
        exit 1
    fi

    if ! command -v convert &> /dev/null
    then
        if ! command -v brew &> /dev/null
        then
            echo "ERROR: The convert command could not be found -- recommend installing homebrew first:    https://brew.sh/"
        else
            echo "ERROR: The convert command needs to be installed with:    brew install imagemagick"
        fi
        exit 1
    fi

    if ! command -v screencapture &> /dev/null
    then
        echo "ERROR: The screencapture command could not be found, even though it was expected to exist on macOS."
        exit 1
    fi

    capture () {
        screencapture -x -l$(./activewindowid.js 2>&1) "$1"
    }

    keypress () {
        cliclick kd:shift ku:shift kp:space
    }

    open_file () {
        open "$1"
    }

elif [[ -v $WINDOW_ID ]]; then
    # X11
    echo "PLATFORM: X11"

    if ! command -v convert &> /dev/null
    then
        echo "ERROR: The convert command needs to be installed, e.g.:    sudo apt install imagemagick"
        exit 1
    fi

    if ! command -v xdotool &> /dev/null
    then
        echo "ERROR: The xdotool command needs to be installed, e.g.:    sudo apt install xdotool"
        exit 1
    fi

    if ! command -v xdg-open &> /dev/null
    then
        echo "ERROR: The xdg-open command could not be found, even though it was expected to exist on X11."
        exit 1
    fi

    capture () {
        convert x:$(xdotool getactivewindow) "$1"
    }

    keypress () {
        xdotool key space
    }

    open_file () {
        xdg-open "$1"
    }

elif grep -qi microsoft /proc/version; then
    # WSL
    echo "PLATFORM: WSL"

    minicap=$(wslpath "$(cmd.exe /C "echo %ProgramFiles(x86)%\MiniCap\MiniCap.exe" 2>/dev/null)" | tr -d '\r' | tr -d '\n')

    if ! command -v convert &> /dev/null
    then
        echo "ERROR: The convert command needs to be installed, e.g.:    sudo apt install imagemagick"
        exit 1
    fi

    if ! command -v "${minicap}" &> /dev/null
    then
        echo "ERROR: The MiniCap program was not found, installation at:    https://www.donationcoder.com/software/mouser/popular-apps/minicap"
        echo Checked: $minicap
        exit 1
    fi

    capture () {
        output="$(wslpath -w .)/$(echo $1 | tr '/' '\\')"
        # cmd.exe /c "$(wslpath -w "$(dirname "$0")/screenCapture.bat") "$output" "-""
        "$minicap" -captureactivewin -save "$output" -exit
    }

    keypress () {
        cscript.exe /nologo "$(wslpath -w "$(dirname "$0")/send.vbs")"
    }

    open_file () {
        cmd.exe /c "start "" "$(wslpath -w .)/$1""
    }

else
    # Unrecognized
    echo "ERROR: Platform not recognized."
    exit 1
fi


# Capture loop
prefix=capture-$(date '+%Y%m%d%H%M%S')
echo CAPTURE: Session identifier: $prefix
mkdir ${prefix}
for ((i=1;i<=num_screenshots;i++)); do
    # Random delay between 4-8 seconds
    delay=$(printf "%d.%03d" $((RANDOM % 3 + 4)) $((RANDOM % 1000)))
    echo "CAPTURE: $i of $num_screenshots (delay $delay s)..."
    sleep $delay

    # Capture defined area of the screen
    png=${prefix}/${prefix}-$(printf '%04d' $i).png
    capture "$png"
 
    # Press space (scroll browser down a page, page-down appears to have intermittent issues, dummy shift down/up appears to fix an issue with only sending a single space)
    keypress
done

# Convert to PDF (dash suffix to rise to top of default sort order)
echo CAPTURE: Converting to PDF...
convert ${prefix}/${prefix}-*.png ${prefix}/${prefix}-.pdf

echo CAPTURE: Done.
open_file "${prefix}/${prefix}-.pdf"
