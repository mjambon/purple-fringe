#! /bin/sh -e

print () {
    echo "\
<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\"
    \"http://www.w3.org/TR/html4/strict.dtd\">
<html>
<head>
<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\">
<title>Purple fringe removal examples</title>
</head>
<body>
<h1>Purple fringe removal examples</h1>
<p>These images were processed with
<a href=\"https://github.com/mjambon/purple-fringe\"><code>unpurple</code></a>,
a command-line program that tries to remove
<a href=\"http://en.wikipedia.org/wiki/Purple_fringing\">purple fringing</a>
from digital photos.
</p>
<table>
<tr><th>Input</th><th>Output</th></tr>
"
    for x in $*; do
        echo "\
<tr><td style=\"text-align:right\">
       <img src=\"$x.jpg\" alt=\"input\"
            title=\"Original photo\"></td>
    <td><img src=\"$x-fixed.jpg\" alt=\"output\"
             title=\"Final photo\"></td></tr>
<tr><td style=\"text-align:right\">
    <img src=\"$x-pred.jpg\" alt=\"blur\"
         title=\"Predicted purple fringing\"></td>
    <td><img src=\"$x-diff.jpg\" alt=\"difference\"
             title=\"Difference between original and final photo\"></td></tr>
"
    done
    echo "\
</table>
</body>
</html>
"
}

print $* > examples.html
