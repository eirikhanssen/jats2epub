/*
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program (gpl.txt), If not, see <http://www.gnu.org/licenses/>

Copyright: Eirik Hanssen, october 23, 2015
*/

// convert backslashes to forward slashes of input string
// this is to convert windows style path separators to unix style
// it is important that the input string has single quotes around if it 
// contains backslashes, this will be the responsibility of the 
// script that calls this jar.

public class b2fslash {
	public static void main(String[] args) {
		if (args.length > 0) {
			String inputPath=args[0];
			// replace backslash with forward slash
			inputPath=inputPath.replaceAll("\\\\","/");
        	System.out.println(inputPath); // Display the string.
		} else {
			System.out.println("Use b2fslash to convert windows/dos style paths to unix style paths");
			System.out.println("b2fslash will convert \"\\\" to \"/\" for the first string argument given");
			System.out.println("Surround the string to be converted in single quotes");			
			System.out.println("No string received. Exiting.");
		}
	}
}