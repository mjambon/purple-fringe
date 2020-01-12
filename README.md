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

Intuition and future prospects
------------------------------

The original motivation for this work was to remove purple fringing
from my own photos that I took with a relatively cheap lens. Coming up
with an algorithm required:

1. Notions about optics, and in particular understanding why chromatic
   aberration happens.
2. Notions about image manipulation and RGB color encoding.
3. Notions about the visible spectrum (rainbow) and how wavelengths
   map to certain perceived colors.
4. Notions about the perception of colors in humans and why computers
   encode colors as 3 components (excluding brightness or transparency) and
   not another number.

It is useful, or perhaps critical, to understand why mixing blue and
red dots produces a perception of purple, even though none of the
light emitted from blue and red dots needs to have the wavelength of
the purple band of the rainbow. School and Wikipedia are your friends.

Here's my mental model of purple fringing, which may be inacurrate but
turned out to be good enough. It may not work as well or at all for
other types of chromatic aberration:

A camera "lens" is made of several simple lenses, which help not
only with zooming in, but also correcting for certain problems. My
understanding is that they allow multiple regions of the visible
spectrum to remain in focus, but this has the opposite effect on the
short wavelengths (purple and ultraviolet) which end up very blurred out.
It is also possible that UV light is captured as purple by the sensor
of a digital camera. As a result, black objects on a white background
will exhibit a purple fringe all around. Note that this is different
then some other types of chromatic aberration, where some objects have a red
margin on one side and a blue margin on the other side.

Now for the method. The problem of removing the purple fringe is
tackled by observing that the bright parts of the image still contain
most of the purple that they should contain. We don't need to take the
purple from the purple fringes and put it back into the bright
areas. They're still plenty bright and their colors look natural. We
assume that they still contain most of the indigo-purple color
corresponding to the short wavelengths, in the correct location. So
instead of trying to locate a purple fringe in the hope of removing
it, we create a purple fringe from the image which already has a
purple fringe.
This involves selecting the blue-purple component of the image, which
is a combination of blue and red within some acceptable ratio and
blurring it. The result is a mask that if added to the original image
would produce a purple fringe roughly like the one we want to remove.
What remains to do is somehow subtract this approximate artificial
purple fringe mask from the original. The first problem is that our
artificial fringe is most likely wider and more intense that the
actual fringe we want to remove, and we don't want to remove too much
so as to not introduce new colors. The second problem is that we don't
want to remove the blue-purple component from the bright areas of the
image. These problems are solved by:

1. Subtracting the purple mask only where it's brighter than the
   original purple component.
2. Subtracting purple only from regions that are somewhat purple, and
   at most until they look grey. For example, from
   a dark purplish pixel like (red = 0.3, green = 0.1, blue = 0.3), we
   may consider a purple fringe mask of (0.25, 0, 0.25). If we
   subtracted this mask directly, we would get (0.05, 0.1, 0.05) and
   now the pixel would be greenish! We avoid this by ensuring that at
   worst we turn a pixel grey. In this case, our resulting pixel would
   be (0.1, 0.1, 0.1), which is a dark grey rather than an undesirable
   dark green.

This is what the current transformations try to do, and it works
often well, which is sometimes surprising. Some areas where a purple
fringe was removed look greyer than they probably should, but the grey
color has the advantage of being discreet.

Some people have asked about removing green fringing. The current
algorithm won't remove it. However, it's possible that a similar
algorithm would work. I estimate it would take at least a couple of
days to obtain a proof of concept, if it is feasible. I hope the
explanations above may help whoever is interested in adding support
for green-fringe removal.
