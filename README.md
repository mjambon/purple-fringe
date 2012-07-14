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
http://mjambon.com/purple-fringe/examples.html

To do
-----

* implement this algorithm as a Gimp script or plugin

