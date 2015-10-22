j2etimestamp

Copyright: Eirik Hanssen 2015
Licence: GNU GPL 3
See gpl.txt

j2etimestamp simply generates a timestamp that is used when creating the filenames.
It is needed on windows because there is no sane standard date.exe on that OS.
I tried to use date.exe from UnixUtils, which worked great, except it got blocked by group policies
set by the administrator in my work environment.

How to create an executable jar to generate a timestamp.
These notes are for myself to remember in the future and for anyone interested.
As this jar-file is already built, you don't need to do this.

1) create a manifest file: j2etimestamp.txt:
Main-Class: j2etimestamp

(needs blank line in the end)

2) create a .java source file: j2etimestamp.java:
import java.text.SimpleDateFormat;
import java.util.Date;
public class j2etimestamp {
	public static void main(String[] args) {
		String timeStamp = new SimpleDateFormat("yyyyMMdd-hhmmss").format(new Date());
        System.out.println(timeStamp); // Display the string.
	}
}

3) compile .java file to .class:
javac -classpath j2etimestamp.jar j2etimestamp.java

4) create jar:
jar cfm j2etimestamp.jar j2etimestamp.txt j2etimestamp.class

5) delete unneeded class file:
rm j2etimestamp.class

6) run:
java -jar j2etimestamp.jar
