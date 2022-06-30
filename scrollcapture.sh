#!/bin/bash

# Settings
num_screenshots=5
capture_region=400,200,1400,1000

# Check required commands exist
if ! command -v cliclick &> /dev/null
then
    if ! command -v brew &> /dev/null
    then
        echo "ERROR: The cliclick command could not be found -- install homebrew first:    https://brew.sh/"
    else
        echo "ERROR: The cliclick command needs to be installed with:    brew install cliclick"
    fi
    exit
fi

if ! command -v convert &> /dev/null
then
    if ! command -v brew &> /dev/null
    then
        echo "ERROR: The convert command could not be found -- install homebrew first:    https://brew.sh/"
    else
        echo "ERROR: The convert command needs to be installed with:    brew install imagemagick"
    fi
    exit
fi

if ! command -v screencapture &> /dev/null
then
    echo "ERROR: The screencapture command could not be found, this script is expected to be run on macOS, which should include that command."
    exit
fi

# Capture loop
prefix=capture-$(date '+%Y%m%d%H%M%S')
echo CAPTURE: Session identifier: $prefix
mkdir ${prefix}
for ((i=1;i<=num_screenshots;i++)); do
    echo CAPTURE: $i of $num_screenshots...

    # Sleep between 4-8 seconds
    sleep $(printf "%d.%03d" $((RANDOM % 3 + 4)) $((RANDOM % 1000)))

    # Capture defined area of the screen
    screencapture -m -x -R${capture_region} ${prefix}/${prefix}-$(printf '%04d' $i).png

    # Press page-down
    cliclick kd:shift ku:shift kp:space
done

# Convert to PDF (dash suffix to rise to top of default sort order)
echo CAPTURE: Converting to PDF...
convert ${prefix}/${prefix}-*.png ${prefix}/${prefix}-.pdf

echo CAPTURE: Done.
open ${prefix}/${prefix}-.pdf
