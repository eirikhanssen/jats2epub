Install instructions - jats2epub on Gnu/Linux for all users
===========================================================
This guide will explain how you can install jats2epub along with the required utilities system wide,
so that all users on the system can use jats2epub, as well as xmlcalabash, epubcheck and kindlegen.

The specific folders mentioned here are suggestions. You may deviate if you know what you're doing.

**Note 1 - to follow this guide, you need to have root access to your system.**

**Note 2 - even if it says Gnu/Linux, you should be able to do the same steps for MacOSX and Unix etc.**

If you haven't already, open a terminal.

Contents:

1. Jats2epub (required)
2. Java (required)
3. XMLCalabash (required)
4. Epubcheck (required)
5. Kindlegen (optional)
6. First run

## 1. Jats2epub
There are two options in getting jats2epub on windows:

    1) using git (preferred)
    2) download a zip archive
    
### Get jats2epub using git
If you don't have git you can get it using the following command (or with another package manager): 

```sudo apt-get install git```

```cd /usr/local```

```sudo git clone https://github.com/eirikhanssen/jats2epub.git```

### Get jats2epub from a zip-archive
(If you didn't get it using git clone).

```cd /usr/local```

```sudo wget path-to-zip-archive```

```sudo unzip zip-archive```

### Important step! Make a symlink to jats2epub in /usr/local/bin

``` sudo ln -s /usr/local/jats2epub/jats2epub /usr/local/bin/jats2epub ```

## 2. Java
A java runtime environment is required by xmlcalabash, epubcheck.

**Check if you have java runtime environment installed:**

``` java ```

If it is a recognized command, you're good to go.

## 3. XMLCalabash
XMLCalabash is a XProc processor written in java. It needs JRE to run.
XProc is an XML pipeline language, and XMLCalabash can run the source article.xml file against jats2epub.xpl.
This file contains instructions on how the document should be prosessed to create most of the files needed for the epub archive.

### 3.1 Getting XMLCalabash
- XMLCalabash can be freely downloaded from: http://xmlcalabash.com/download/
- Latest version: https://github.com/ndw/xmlcalabash1/releases/latest
- Direct link (may be outdated in the future): https://github.com/ndw/xmlcalabash1/releases/download/1.1.9-96/xmlcalabash-1.1.9-96.zip

### 3.2 Installing XMLCalabash

```cd /usr/local```

```sudo wget https://github.com/ndw/xmlcalabash1/releases/download/1.1.9-96/xmlcalabash-1.1.9-96.zip```

```sudo unzip xmlcalabash-1.1.9-96.zip```

```sudo ln -s /usr/local/xmlcalabash-1.1.9-96 /usr/local/xmlcalabash```

```cd /usr/local/xmlcalabash```

```sudo ln -s xmlcalabash-1.1.9-96.jar xmlcalabash.jar```

```cd /usr/local/bin```

**Now create a shellscript called calabash with the following contents:**

```
#!/bin/sh
java -Xmx1024m -jar /usr/local/xmlcalabash/xmlcalabash.jar "$@"
```

**Make it executable:**

``` sudo chmod +x /usr/local/bin/calabash ```

**Now it should be possible to run XML Calabash using the command:**

``` calabash ```

## 4. Epubcheck
Epubcheck is a utility to validate .epub files and expanded EPUB archives as well as packaging expanded EPUB archives to .epub files.
Epubcheck is written in java and distributed as a executable jar file.

### 4.1 Getting Epubcheck
- Download from: https://github.com/idpf/epubcheck
- Latest release: https://github.com/IDPF/epubcheck/releases/latest
- Direct link (may be outdated in the future): https://github.com/IDPF/epubcheck/releases/download/v4.0.0/epubcheck-4.0.0.zip

### 4.2 Installing Epubcheck

``` cd /usr/local ```

``` sudo wget https://github.com/IDPF/epubcheck/releases/download/v4.0.0/epubcheck-4.0.0.zip ```

``` sudo unzip epubcheck-4.0.0.zip ```

**Symlink to the folder:**

``` sudo ln -s epubcheck-4.0.0 epubcheck ```

``` cd /usr/local/bin ```

**Create a shellscript called epubcheck with these two lines:**

```
#!/bin/sh
java -Xmx1024m -jar /usr/local/epubcheck/epubcheck.jar "$@"
```

Make executable:
``` sudo chmod +x /usr/local/bin/epubcheck ```

**Now it should be possible to run epubcheck with the command:**

``` epubcheck ```

## 5. Kindlegen
Amazon kindlegen is a utility used to convert .epub files to .mobi files so that they can be read on kindle devices.
If you're not interested in generating .mobi files, you don't need to install kindlegen, then .mobi generation will simply be skipped.

### 5.1 Getting kindlegen
- Search google for amazon kindlegen
- Download page (might be outdated in the future): http://www.amazon.com/gp/feature.html?docId=1000765211
- Direct link (might be outdated in the future): http://kindlegen.s3.amazonaws.com/kindlegen_linux_2.6_i386_v2_9.tar.gz

### 5.2 Installing kindlegen
**Warning: the kindlegen archive does not have a top level folder, extracting it will dump all the files in the folder you're in **
So it is better to make a folder for it and extract it in that folder.

``` cd /usr/local ```

``` sudo mkdir kindlegen && cd kindlegen ```

**If you're a Gnu/Linux, Unix etc user:**

``` sudo wget http://kindlegen.s3.amazonaws.com/kindlegen_linux_2.6_i386_v2_9.tar.gz ```

``` sudo tar -xvzf kindlegen_linux_2.6_i386_v2_9.tar.gz ```

**Or if you are a MacOSX user:**

``` sudo wget http://kindlegen.s3.amazonaws.com/KindleGen_Mac_i386_v2_9.zip ```

``` sudo unzip KindleGen_Mac_i386_v2_9.zip ```

**On my system kindlegen had wrong ownership after extracting. Let's fix that:**

``` sudo chown -R root.root /usr/local/kindlegen ```

**Make a symlink:**

``` sudo ln -s /usr/local/kindlegen/kindlegen /usr/local/bin/kindlegen ```

**Now it should be possible to run kindlegen with the command:**

``` kindlegen ```

## 6. First run
If you made it this far, you're ready to start using jats2epub

Don't be scared of all the text that flows on the screen, 
but if you're used to linux, that's nothing to be afraid of ;)

It can be helpful for troubleshooting

First get the sample xml-files somewhere in your home folder.

**Go to your home:**

``` cd ```

``` mkdir ~/jats2epub-test && cp -R /usr/local/jats2epub/source-xml ~/jats2epub-test ```

``` cd ~/jats2epub-test ```

### 6.1 Convert an article with no figures
**Try this command to convert an article with no figures to epub:**

``` jats2epub source-xml/saks.xml ```

### 6.2 Convert an article with figures
**Try this command to convert an article with figures to epub:**

``` jats2epub source-xml/spehar.xml source-xml/spehar ```

### 6.3 Converted files
- The converted files will be in saved in two places:
    - the folder where you run jats2epub from 
    - backup in ~/.jats2epub/converted
- Temporary files will be in ~/.jats2epub/latest-run
