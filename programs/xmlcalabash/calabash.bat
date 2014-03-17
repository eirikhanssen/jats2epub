@ehco off
rem To be able to to use the calabash command from any folder,
rem change this path to reflect the absolute path of calabash.jar and put it in a folder that 
rem is located in the path environment variable, such as C:\Windows\System32 or any other folder in the path
@java -Xmx1024m -jar "C:\Users\username\jats2epub\programs\xmlcalabash\calabash.jar" %*
    
