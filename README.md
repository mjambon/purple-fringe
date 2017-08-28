Unpurple
========

Unpurple is a tool for removing purple fringes (axial chromatic aberration)
from digital photos using a heuristic of my own.

Currently there is an OCaml implementation which produces a standalone
executable with a simple command-line interface.
It is fast enough (~ one second per megapixel) but doesn't
preserve Exif data and the JPEG compression factor is fixed at 75%.

I would like to make a Gimp extension script or plugin for
everyone to use.

Examples
--------

Sample images before and after transformation:
https://mjambon.github.io/mjambon2016/purple-fringe/examples.html

Before:

[<img src="https://mjambon.github.io/mjambon2016/purple-fringe/wikipedia-horsie.jpg" alt="Before"/>]()

After:

[<img src="https://mjambon.github.io/mjambon2016/purple-fringe/wikipedia-horsie-fixed.jpg" alt="After"/>]()
