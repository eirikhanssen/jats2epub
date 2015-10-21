Because of licencing restrictions, we can't include Amazon kindlegen in this package.
You can however, download it yourself legally and for free.

If you wish to automatically create .mobi format for use with kindle devices aswell do the following steps:

1)  Download kindlegen from amazon.
	- Search google: amazon kindlegen
	At time of writing:
	- http://www.amazon.com/gp/feature.html?docId=1000765211
	Direct download (at time of writing):
	- Win32: http://kindlegen.s3.amazonaws.com/kindlegen_win32_v2_9.zip
	- Mac OS 10.5 and above i386: http://kindlegen.s3.amazonaws.com/KindleGen_Mac_i386_v2_9.zip
	- Gnu/Linux 2.6 i386: http://kindlegen.s3.amazonaws.com/kindlegen_linux_2.6_i386_v2_9.tar.gz

2a) Windows users: unpack the kindlegen executable to the folder containing this readme

2b) MacOSX/Unix/Gnu/Linux users: put kindlegen in a folder in path, or create a symlink to it there:
    popular suggestion:

    if you have root access: sudo ln -s path/to/kindlegen-executable /usr/local/bin/kindlegen

    if you don't have root access: ln -s path/to/kindlegen-executable ~/bin/kindlegen
    this assumes that the folder ~/bin is in PATH, if unsure, do a google search on adding folder to path

Now when you run jats2epub, a .mobi file of the article will also be created
