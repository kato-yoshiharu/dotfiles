use framework "AppKit"

set displayNumber to 1

set allFrames to (current application's NSScreen's screens()'s valueForKey:"frame") as list

set sourceDisplay to item 1 of allFrames
set { { sourceX, sourceY }, { sourceWidth, sourceHeight } } to sourceDisplay

set targetDisplay to item displayNumber of allFrames
set { { targetX, targetY }, { targetWidth, targetHeight } } to targetDisplay

set newX to targetX + targetWidth / 2
set newY to sourceHeight - targetY - targetHeight / 2

set pt to current application's CGPointZero
set x of pt to newX
set y of pt to newY
current application's CGPostMouseEvent(pt, 1, 1, 0)
