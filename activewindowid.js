#!/usr/bin/osascript -l JavaScript

//  screencapture -x -l$(./activewindowid.js 2>&1) test.png

ObjC.import('CoreGraphics');
ObjC.import('Quartz');
$.unwrap = ObjC.deepUnwrap.bind(ObjC),
$.bind   = ObjC.bindFunction.bind($);
$.bind('CFMakeCollectable', [ 'id', [ 'void *' ] ]);
Ref.prototype._nsObject = function () {
	return $.unwrap($.CFMakeCollectable(this));
}

const kCGWindows = $.CGWindowListCopyWindowInfo($.kCGWindowListOptionOnScreenOnly | $.kCGWindowListExcludeDesktopElements, $.kCGWindowNull)._nsObject();
const frontmost = kCGWindows.filter(w => w.kCGWindowIsOnscreen && w.kCGWindowLayer == 0);

let window = {
	id: null,
	pid: null,
	name: null,
	x: null,
	y: null,
	w: null,
	h: null,
}

if (frontmost.length > 0) {
	const app = frontmost[0];
	window = {
		id: app.kCGWindowNumber,
		pid: app.kCGWindowOwnerPID,
		name: app.kCGWindowOwnerName,
		x: app.kCGWindowBounds.X,
		y: app.kCGWindowBounds.Y,
		w: app.kCGWindowBounds.Width,
		h: app.kCGWindowBounds.Height,
	}
}

if (window.id !== null) {
	console.log(window.id);
}
