#! /bin/sh -e

sample () {
    x="$1"
    shift

    ../src/unpurple $x.jpg $x-fixed.jpg "$@"
    ../src/unpurple $x.jpg $x-diff.jpg -diff "$@"

    if [ -n "$*" ]; then
        options="<tr><td></td><td>Options: <code>$@</code></td></tr>"
    else
        options=""
    fi

    echo "\
<tr><td style=\"text-align:right\">
       <img src=\"$x.jpg\" alt=\"input\"
            title=\"Original photo\"></td>
    <td><img src=\"$x-fixed.jpg\" alt=\"output\"
             title=\"Final photo\"></td></tr>
$options
<tr><td></td>
    <td><img src=\"$x-diff.jpg\" alt=\"difference\"
             title=\"Difference between original and final photo\"></td></tr>
"
}

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
<p>
In each example the default options are used unless otherwise indicated.
</p>
<table>
<tr><th>Input</th><th>Output</th></tr>
"
    sample wikipedia-horsie
    sample butterfly -minred 0.15
    sample eye
    sample tree
    sample snake
    sample purple-sky
    sample purple-sky-gentle -minred 0.15
    sample purple0
    sample purple2
    sample purple3
    sample difficult -m 0.8 -i 2.0
    sample worst-case -m 0.5 -r 1.0

    echo "\
</table>
</body>
</html>
"
}

print $* > examples.html
