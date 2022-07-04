# Scroll Capture

This is an assistive script designed to help a user to archive multiple screens from a website as pages in a PDF file.  As distinct from a "scrolling screenshots", this script should work even if the page only loads images on demand or otherwise "recycles" images that have scrolled off the screen.

The shell script `scrollcapture.sh` will, for a given count of iterations (default 5):

* pause for a random delay (default 4-8 seconds)
* simulate a *Space* key press (this will scroll a browser down one page)
* take a screenshot image capture of the current window, saved to a `.png` file.
* crop the screenshot image by a specified amount.

Afterwards, the images will be collated as pages into a single `.pdf` file.


## Installation

1. Download: [`scrollcapture.sh`](https://raw.githubusercontent.com/danielgjackson/scrollcapture/main/scrollcapture.sh). On macOS you will also need [`activewindowid.js`](https://raw.githubusercontent.com/danielgjackson/scrollcapture/main/activewindowid.js).

2. Open a terminal (*Terminal.app* on macOS or a `wsl` command prompt on Windows).

3. Set the script as executable (adjust the path if not in the `Downloads` directory):

    ```bash
    chmod +x ~/Downloads/scrollcapture.sh
    ```

4. Install [`imagemagick`](https://imagemagick.org/script/download.php) and, on macOS, also install `cliclick` and, on Windows, install [MiniCap](https://www.donationcoder.com/software/mouser/popular-apps/minicap).  e.g. On macOS, first [install *Homebrew*](https://brew.sh/), then you can install the required programs with:

    ```bash
    brew install cliclick imagemagick
    ```

## Usage

1. Open your browser on the required page and adjust the size so that the Space key scrolls the desired amount.

2. Open the Terminal and run the script.  Change `5` to the desired number of screenshots to take.  Adjust the path if it is not in your *Downloads* directory.  On macOS, you will be prompted to allow `Terminal.app` to control your computer and capture screenshots, and may need to re-open the terminal and re-run the script:

    ```bash
    ~/Downloads/scrollcapture.sh 5
    ```

3. Quickly change the current focussed window back to your browser, and allow the screenshots to be taken.

4. Afterwards, the script should automatically open the PDF archive of the screenshots.

**IMPORTANT:** You will want to do an initial small test and verify the captured portion of the window, and the degree of scroll overlap.  You can calculate the cropping by running:

```bash
~/Downloads/scrollcapture.sh --calibrate
```

...you can tweak it by editing the generated file `crop-params.generated.sh` and changing the crop values at the start of the file, e.g.:

```bash
crop_top=182; crop_bottom=158; crop_left=115; crop_right=115;
```
