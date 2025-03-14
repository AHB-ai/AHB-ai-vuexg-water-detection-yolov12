%% File Converter Java
% This script calls a Java function to convert xlsx file to csv file
% The Java fucntion is based on Apache POI API http://poi.apache.org/. The
% version used is stable version of poi 3.10.1. In order to make it
% working, the following jar need to be added to dynamic java path:
%
%   * javaaddpath('.\poi-3.10.1-20140818.jar');
%   * javaaddpath('.\poi-examples-3.10.1-20140818.jar');
%   * javaaddpath('.\poi-excelant-3.10.1-20140818.jar');
%   * javaaddpath('.\poi-ooxml-3.10.1-20140818.jar');
%   * javaaddpath('.\poi-ooxml-schemas-3.10.1-20140818.jar');
%   * javaaddpath('.\poi-scratchpad-3.10.1-20140818.jar');
%   * javaaddpath('.\commons-codec-1.5.jar');
%   * javaaddpath('.\commons-logging-1.1.jar');
%   * javaaddpath('.\junit-4.11.jar');
%   * javaaddpath('.\log4j-1.2.13.jar');
%   * javaaddpath('.\dom4j-1.6.1.jar');
%   * javaaddpath('.\stax-api-1.0.1.jar');
%   * javaaddpath('.\xmlbeans-2.6.0.jar');
%
% <html>
% The native function is written in java, and exported as a JAR to used in
% matlab. In order to use it, 
% <font color="red"><b>Convert2CSV.jar</b></font>
% has to be added as a java dynamic path: javaaddpath('.\Convert2CSV.jar')
% </html>
%
%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>inputfile</b></td><td>is a xlsx file with path</td></tr>
% <tr><td><b>outputfile</b></td><td>is a csv file with path</td></tr>
% <tr><td><b>column_list</b></td><td>is an array that contains column numbers that need to be converted, if it is an empty array, each column will be converted.</td></tr>
% <tr><td><b>format_list</b></td><td>is an array that contains the corresponding format of the column numbers that need to be converted.</td></tr>
% </table>
% </html>
%
% * OUTPUT
% 
% <html>
% <table border=2>
% <tr><td><b>Output</b></td><td>a csv file</td></tr>
% </table>
% </html>
%
%% Code
function xlsx2csv(inputfile, outputfile, column_list, format_list, date)

import java.io.File
import uos.xlsxconverter.csv.xlsx2csv

xlsxFile = java.io.File(inputfile);
%minColumns = -1;
fout = java.io.FileOutputStream(outputfile);
fCSV = java.io.PrintStream(fout);
p = org.apache.poi.openxml4j.opc.OPCPackage.open(xlsxFile.getPath(),org.apache.poi.openxml4j.opc.PackageAccess.READ);
minColumns = -1;
converter = uos.xlsxconverter.csv.xlsx2csv(p,fCSV,minColumns);
converter.process(column_list, format_list, date);
fCSV.close();
fout.close();
%% Navigation
% * Go to 
% <..\html\main.html main> 
% * Go to 
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 

%% Author
%  Haiyue Yuan, 02.2016, Depatment of Computer Science, University of Surrey

