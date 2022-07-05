#!/bin/bash
set -e

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "PLATFORM: macOS"
    
    if [[ ! -f "$(dirname "$0")/activewindowid.js" ]]
    then
        echo "ERROR: The companion script is missing:    activewindowid.js"
        exit 1
    fi

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
        info=$(/usr/bin/osascript -l JavaScript "$(dirname "$0")/activewindowid.js" 2>&1)
        id=$(echo ${info} | cut -d ' ' -f 1)
        screencapture -x -l$id "$1"
    }

    keypress () {
        cliclick kd:shift ku:shift kp:space
    }

    open_file () {
        open "$1"
    }

    resize () {
        info=$(/usr/bin/osascript -l JavaScript "$(dirname "$0")/activewindowid.js" $1 $2 2>&1)
        w=$(echo ${info} | cut -d ' ' -f 4)
        h=$(echo ${info} | cut -d ' ' -f 5)
        echo "RESIZED: ($w, $h) to ($1 $2)"
    }

elif [[ ! -z "$WINDOW_ID" ]]; then
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
        xdg-open "$1" &
    }

    resize () {
        echo "NOTE: Resize not yet implemented on X11: $1 $2"
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

    resize () {
        echo "NOTE: Resize not yet implemented on WSL: $1 $2"
    }

else
    # Unrecognized
    echo "ERROR: Platform not recognized."
    exit 1
fi


# Cropping coordinate calibration
if [ "$1" == "--calibrate" ]; then
    echo "CAPTURE: Running calibrate mode."
    [ -d calibrate ] || mkdir calibrate
    pngBase=calibrate/calibrate-$(date '+%Y%m%d%H%M%S')

    # Plain magenta in window client area
    color=magenta
    #open_file "data:text/html,%3Chtml/style=background:$color%3E"
    open_file "$(dirname "$0")/calibrate.html"

    echo "CAPTURE: Waiting for calibration screen..."
    sleep 10

    echo "CAPTURE: Capturing calibration screen..."
    capture "${pngBase}.0.png"

    echo "CAPTURE: Creating rotations..."
    convert "${pngBase}.0.png" -rotate 90 "${pngBase}.90.png"
    convert "${pngBase}.90.png" -rotate 90 "${pngBase}.180.png"
    convert "${pngBase}.180.png" -rotate 90 "${pngBase}.270.png"

    echo "CAPTURE: Checking calibration..."
    test=$(compare -metric AE -subimage-search "${pngBase}.0.png" \( -size 1x1 xc:"$color" \) null: 2>&1 | tr -cs ".0-9\n" " "  | cut -d\  -f1)
    if [[ "$test" != "0" ]]; then
        echo "CAPTURE: Error, calibration value cound not be found: $color"
        exit 1
    fi

    echo "CAPTURE: Calculating calibration values: left..."
    crop_left=$(compare -metric AE -subimage-search "${pngBase}.0.png" \( -size 1x1 xc:"$color" \) null: 2>&1 | tr -cs ".0-9\n" " "  | cut -d\  -f2)
    echo "CAPTURE: Calculating calibration values: bottom..."
    crop_bottom=$(compare -metric AE -subimage-search "${pngBase}.90.png" \( -size 1x1 xc:"$color" \) null: 2>&1 | tr -cs ".0-9\n" " "  | cut -d\  -f2)
    echo "CAPTURE: Calculating calibration values: right..."
    crop_right=$(compare -metric AE -subimage-search "${pngBase}.180.png" \( -size 1x1 xc:"$color" \) null: 2>&1 | tr -cs ".0-9\n" " "  | cut -d\  -f2)
    echo "CAPTURE: Calculating calibration values: top..."
    crop_top=$(compare -metric AE -subimage-search "${pngBase}.270.png" \( -size 1x1 xc:"$color" \) null: 2>&1 | tr -cs ".0-9\n" " "  | cut -d\  -f2)

    echo "CAPTURE: Cropping calibration screen..."
    pngCropped=${pngBase}.cropped.png
    convert "${pngBase}.0.png" -gravity North -chop x${crop_top} -gravity South -chop x${crop_bottom} -gravity West -chop ${crop_left}x -gravity East -chop ${crop_right}x "$pngCropped"

    echo "CAPTURE: Resize/cropping parameters calculated:"
    echo "resize_width=${resize_width}; resize_height=${resize_height}; crop_top=${crop_top}; crop_bottom=${crop_bottom}; crop_left=${crop_left}; crop_right=${crop_right};"
    echo "resize_width=${resize_width}; resize_height=${resize_height}; crop_top=${crop_top}; crop_bottom=${crop_bottom}; crop_left=${crop_left}; crop_right=${crop_right};" > "$(dirname "$0")/crop-params.generated.txt"
    
    exit 0
fi


# Window resize and crop parameters
resize_width=0; resize_height=0; 
crop_top=0; crop_bottom=0; crop_left=0; crop_right=0;
if [[ -f "$(dirname "$0")/crop-params.generated.txt" ]]; then
    echo "CAPTURE: Loading generated crop parameters..."
    source "$(dirname "$0")/crop-params.generated.txt"
fi
echo "CAPTURE: Resize/cropping parameters used:"
echo "resize_width=${resize_width}; resize_height=${resize_height}; crop_top=${crop_top}; crop_bottom=${crop_bottom}; crop_left=${crop_left}; crop_right=${crop_right};"

# Number of screenshots passed as first argument (5 by default)
num_screenshots=${1:-5}

# Capture loop
prefix=capture-$(date '+%Y%m%d%H%M%S')
echo "CAPTURE: Session identifier: $prefix"
echo "...long wait before initial capture (10 s) -- please focus window to be captured..."
sleep 10
# Resize window
if [ $resize_width -gt 0 -a $resize_height -gt 0 ]; then
    resize $resize_width $resize_height
fi
mkdir ${prefix}
echo "CAPTURE: Session identifier: $prefix"

for ((i=1;i<=num_screenshots;i++)); do
    # Random delay between 4-8 seconds
    delay=$(printf "%d.%03d" $((RANDOM % 3 + 4)) $((RANDOM % 1000)))
    echo "CAPTURE: $i of $num_screenshots (delay $delay s)..."
    sleep $delay
    pngBase=${prefix}/${prefix}-$(printf '%04d' $i)

    # Capture defined area of the screen
    pngOriginal=${pngBase}.original.png
    capture "$pngOriginal"

    # Crop image
    pngCropped=${pngBase}.cropped.png
    convert "$pngOriginal" -gravity North -chop x${crop_top} -gravity South -chop x${crop_bottom} -gravity West -chop ${crop_left}x -gravity East -chop ${crop_right}x "$pngCropped"

    # Press space (scroll browser down a page, page-down appears to have intermittent issues, dummy shift down/up appears to fix an issue with only sending a single space)
    keypress
done

# Convert to PDF (dash suffix to rise to top of default sort order)
echo CAPTURE: Converting to PDF...
convert "${prefix}/${prefix}-*.cropped.png" "${prefix}/${prefix}-.pdf"

echo CAPTURE: Done.
open_file "${prefix}/${prefix}-.pdf"
