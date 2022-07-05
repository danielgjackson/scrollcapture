#!/usr/bin/osascript -l JavaScript

// Returns information from the frontmost window (including the window id).
// Optionally, resizes the window to the specified width/height.

ObjC.import('CoreGraphics');
ObjC.import('Quartz');
$.unwrap = ObjC.deepUnwrap.bind(ObjC),
$.bind   = ObjC.bindFunction.bind($);
$.bind('CFMakeCollectable', [ 'id', [ 'void *' ] ]);
Ref.prototype._nsObject = function () {
	return $.unwrap($.CFMakeCollectable(this));
}

function run(args){

	const kCGWindows = $.CGWindowListCopyWindowInfo($.kCGWindowListOptionOnScreenOnly | $.kCGWindowListExcludeDesktopElements, $.kCGWindowNull)._nsObject();
	const frontmost = kCGWindows.find(w => w.kCGWindowIsOnscreen && w.kCGWindowLayer == 0);

	let window = {
		id: null,
		pid: null,
		name: null,
		x: null,
		y: null,
		w: null,
		h: null,
	}

	if (frontmost) {
		window = {
			id: frontmost.kCGWindowNumber,
			pid: frontmost.kCGWindowOwnerPID,
			name: frontmost.kCGWindowOwnerName,
			x: frontmost.kCGWindowBounds.X,
			y: frontmost.kCGWindowBounds.Y,
			w: frontmost.kCGWindowBounds.Width,
			h: frontmost.kCGWindowBounds.Height,
		};
		
		// id x y w h pid name
		console.log("" + window.id + " " + window.x + " " + window.y + " " + window.w + " " + window.h + " " + window.pid + " " + window.name);

		if (args.length >= 2) {
			const width = parseInt(args[0]);
			const height = parseInt(args[1]);
			const app = Application(frontmost.kCGWindowOwnerPID);  // kCGWindowOwnerName
			if (app.windows.length == 0) {
				console.log("ERROR: Cannot find application to resize window.")
			} else {
				const win = app.windows[0];
				win.bounds = {
					x: window.x,
					y: window.y,
					width: width,
					height: height,
				};
				//app.activate();
			}
		}
	}

}
