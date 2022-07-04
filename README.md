# Scroll Capture

This is an assistive script designed to help a user to archive multiple screens from a website as pages in a PDF file.  As distinct from "scrolling screenshots", this script should work even if the page only loads images on demand or otherwise "recycles" images that have scrolled off the screen.

The shell script `scrollcapture.sh` will, for a given count of iterations (default 5):

* pause for a random delay (default 4-8 seconds)
* simulate a *Space* key press (this will scroll a browser down one page)
* take a screenshot image capture of the current window, saved to a `.png` file.
* crop the screenshot image by a specified amount.

Afterwards, the images will be collated as pages into a single `.pdf` file.

The script will work on macOS, Linux and Windows under WSL.


## Installation

1. Open a terminal (e.g. *Terminal.app* on macOS, or a `wsl` command prompt on Windows).

2. Copy and paste the following commands to fetch and unzip the archive of the source code in this repository:

    ```bash
    cd ~
    curl -LOJ https://github.com/danielgjackson/scrollcapture/archive/refs/heads/main.zip
    unzip scrollcapture-main.zip
    rm scrollcapture-main.zip
    mv scrollcapture-main scrollcapture
    ```

3. Install required components:

  * On macOS, if you don't already have it, first [install Homebrew](https://brew.sh/), then install *ImageMagick* and *cliclick*:

     ```bash
     brew install imagemagick cliclick
     ```

  * On Linux and under WSL on Windows, use your package manager to install *ImageMagick*.  For example, Ubuntu/Debian:

    ```bash
    sudo apt install imagemagick
    ```

  * On Windows, install [*MiniCap*](https://www.donationcoder.com/software/mouser/popular-apps/minicap).


## Calibration (Optional)

If you are using a new browser configuration, or have changed the display resolution, you may want to calibrate the crop region.  This determines how to crop the screenshot so that only the content is visible.  

You can automatically determine the cropping values by running the following:

```bash
~/scrollcapture/scrollcapture.sh 5 --calibrate
```

This will launch the default browser with a magenta page, determine the cropping region, and save this to a generated file `crop-params.generated.sh`.  You can manually adjust the crop values at the start of the file, e.g.:

```bash
crop_top=182; crop_bottom=158; crop_left=115; crop_right=115;
```

If you are using a non-default browser, open a tab with the URL `data:text/html,%3Chtml/style=background:magenta%3E` and switch focus to it as soon as the calibration program starts.

Setting every value to `0`, or deleting the calibration file `crop-params.generated.sh`, means the original image will effectively remain uncropped.


## Usage

**Recommended:** You should do an initial small test to verify the captured portion of the window, and the degree of scroll overlap.  When you run a longer capture session, minimize the risk of anything interrupting the capture (e.g. other programs taking the focus, or screen blanking or automatic shutdowns).  

1. Open your browser on the required page and adjust the size so that the *space* key scrolls the desired amount.

2. Open the Terminal and run the script.  Change `5` to the desired number of screenshots to take.  Adjust the path if it is not in your *Downloads* directory.  On macOS, you will be prompted to allow `Terminal.app` to control your computer and capture screenshots, and may need to re-open the terminal and re-run the script:

    ```bash
    ~/scrollcapture/scrollcapture.sh 5
    ```

3. Immediately change the current focussed window back to your browser, and allow the screenshots to be taken.

4. Afterwards, the script should automatically open the PDF archive of the screenshots.
