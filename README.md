Unpurple
========

Unpurple is a tool for removing purple fringes (axial chromatic aberration)
from digital photos using a heuristic of my own.

This is the original OCaml implementation which produces a standalone
executable with a simple command-line interface.
It is fast enough (~ one second per megapixel) but doesn't
preserve Exif data and the JPEG compression factor is fixed at 75%.

Unpurple was
[ported](https://github.com/dtschump/gmic-community/blob/master/include/stanislav_paskalev.gmic)
to [G'MIC](https://gmic.eu/)
by [Stanislav Paskalev](https://github.com/solarsea), allowing its use from
[GIMP](https://www.gimp.org/) and other image-manipulation software.
🎉

Example
-------

Before:

[<img src="https://mjambon.github.io/mjambon2016/purple-fringe/wikipedia-horsie.jpg" alt="Before"/>]()

After:

[<img src="https://mjambon.github.io/mjambon2016/purple-fringe/wikipedia-horsie-fixed.jpg" alt="After"/>]()

Difference:

[<img src="https://mjambon.github.io/mjambon2016/purple-fringe/wikipedia-horsie-diff.jpg" alt="Difference"/>]()

[More examples](https://mjambon.github.io/mjambon2016/purple-fringe/examples.html)

Algorithm outline
-----------------

1. Produce a blurred mask from the blue component in the original image.
2. Subtract from the original image some amount of blue and red based on the intensities found in the blurred mask, using the following constraints:
   * Blue level may not drop below green level.
   * Red level may not drop below green level.
   * Red:blue ratio may not drop below some constant.

Please refer to the implementation for details and default parameters.
