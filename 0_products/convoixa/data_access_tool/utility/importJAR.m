
% This is used to configure the MATLAB enviroment in order to enable Apache
% POI libarary, and a Convert2CSV JAR
% Input Argument:
% path: is the relative path that contains the below JARs
% Haiyue@Nov 2014

function importJAR(path)

javaaddpath([path 'poi-3.10.1\poi-3.10.1-20140818.jar']);
javaaddpath([path 'poi-3.10.1\poi-examples-3.10.1-20140818.jar']);
javaaddpath([path 'poi-3.10.1\poi-excelant-3.10.1-20140818.jar']);
javaaddpath([path 'poi-3.10.1\poi-ooxml-3.10.1-20140818.jar']);
javaaddpath([path 'poi-3.10.1\poi-ooxml-schemas-3.10.1-20140818.jar']);
javaaddpath([path 'poi-3.10.1\poi-scratchpad-3.10.1-20140818.jar']);
javaaddpath([path 'poi-3.10.1\lib\commons-codec-1.5.jar']);
javaaddpath([path 'poi-3.10.1\lib\commons-logging-1.1.jar']);
javaaddpath([path 'poi-3.10.1\lib\junit-4.11.jar']);
javaaddpath([path 'poi-3.10.1\lib\log4j-1.2.13.jar']);
javaaddpath([path 'poi-3.10.1\ooxml-lib\dom4j-1.6.1.jar']);
javaaddpath([path 'poi-3.10.1\ooxml-lib\stax-api-1.0.1.jar']);
javaaddpath([path 'poi-3.10.1\ooxml-lib\xmlbeans-2.6.0.jar']);
javaaddpath([path 'Convert2CSV.jar']);
javaaddpath([path 'jcoord-1.0.jar']);