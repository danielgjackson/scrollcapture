# Scroll Capture

This contains a script `scrollcapture.sh`, designed to be run on *macOS* that will, for a given count of iterations (default 5):

* a random delay (default 4-8 seconds)
* a *Space* key press (this will scroll the browser down one page)
* a capture of a specified screen region

Each screen capture will be saved to a `.png` file.

Afterwards, the images will be collated as pages into a single `.pdf` file.


## Installation

1. Download: [`scrollcapture.sh`](https://raw.githubusercontent.com/danielgjackson/scrollcapture/main/scrollcapture.sh)

2. Open: `Terminal.app`

3. If you do not already have it, [install *Homebrew*](https://brew.sh/)

4. Install `imagemagick` and `cliclick`:

    ```bash
    brew install cliclick imagemagick
    ```

5. Change to your `Downloads` directory:

    ```bash
    cd ~/Downloads
    ```

6. Run (you will be prompted to allow `Terminal.app` to control your computer and capture screenshots, and may need to re-run it):

     ```bash
     ./scrollcapture.sh
     ```
