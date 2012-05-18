#! /bin/sh -e

print () {
    echo "\
<html>
<head>
<title>Purple fringing removal examples</title>
</head>
<body>
<table>
"
    for x in $*; do
        echo "\
<tr><td style=\"text-align:right\"><img src=\"$x.jpg\"/></td>
    <td><img src=\"$x-fixed.jpg\"/></td></tr>
"
    done
    echo "\
</table>
</body>
</html>
"
}

print $* > examples.html
