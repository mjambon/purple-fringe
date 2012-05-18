Tool for removing purple fringes (axial chromatic aberration) 
from digital photos using a heuristic of my own.

There is an OCaml implementation which produces a standalone
executable. It is fast enough (~ one second per megapixel) but loses
Exif data and the JPEG compression factor is fixed at 75%.

Sample images before and after transformation are given in the
`examples` directory. Click on individual `.jpg` and `-fixed.jpg`
files, or `git clone git://github.com/mjambon/purple-fringe.git` and
open `examples.html` in a browser.

To do:

* integrate this algorithm into Gimp for easier installation and more
  usability

* test on more examples with natural blue and purple colors
