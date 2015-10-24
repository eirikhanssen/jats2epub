b2fslash (back to forward slash)

b2fslash is a small utility workaround for an issue I experienced with dos/windows style path names when running xmlcalabash.

As you know dos/windows uses backslash as a path separator, and if a path including a backslash is used as input to 
xmlcalabash, it fails because the backslash is considered an illegal character in the path.

Therefore, this utility is used just to convert backslashes to forward-slashes so that the parameter xmlcalabash receives
includes a proper unix-style path.
