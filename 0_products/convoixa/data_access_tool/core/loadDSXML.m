%% Read Descriptor
% This script is to load data descriptor (xml) file, and store key information for pre-processing purpose.
% The data descriptor records the format of the raw ANPR data.
%%
%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>filename</b></td><td>data source descriptor (xml file)</td></tr>
% </table>
% </html>
%
% * OUTPUT
% 
% <html>
% <table border=2>
% <tr><td><b>Output</b></td><td>datasource that contains key information from the data source</td></tr>
% </table>
% </html>
%
%% Code
function datasource = loadDSXML(filename)

try
    doc = xmlread(filename);
catch
    error('Failed to read XML %s. ', filename);
end


sheetList = doc.getElementsByTagName('Sheets');
sheetStatus = char(sheetList.item(0).getTextContent);

typeList = doc.getElementsByTagName('FileSuffix');
typeStatus = char(typeList.item(0).getTextContent);

headerList = doc.getElementsByTagName('Header');
headerStatus = char(headerList.item(0).getTextContent);

bofNameList = doc.getElementsByTagName('Name');
bofName = char(bofNameList.item(0).getTextContent);

bofSourceList = doc.getElementsByTagName('Source');
bofSource = char(bofSourceList.item(0).getTextContent);

vrmList = doc.getElementsByTagName('VRM');
vrmPos = getInteger(vrmList.item(0).getTextContent);

timeList = doc.getElementsByTagName('CaptureTime');
timePos = getInteger(timeList.item(0).getTextContent);
timeFormat = char(timeList.item(0).getAttribute('timeFormat'));

camList = doc.getElementsByTagName('CameraName');
camPos = getInteger(camList.item(0).getTextContent);

locList = doc.getElementsByTagName('Location');
geoFormat = char(locList.item(0).getAttribute('geoFormat'));

nameList = doc.getElementsByTagName('NameFormat');
nameFormat = char(nameList.item(0).getTextContent);

%%%%
makeList = doc.getElementsByTagName('Make');
makePos = getInteger(makeList.item(0).getTextContent);

modelList = doc.getElementsByTagName('Model');
modelPos = getInteger(modelList.item(0).getTextContent);

colorList = doc.getElementsByTagName('Color');
colorPos = getInteger(colorList.item(0).getTextContent);

taxList = doc.getElementsByTagName('Tax');
taxPos = getInteger(taxList.item(0).getTextContent);

switch geoFormat
    case 'Degree'
        locChildNode = locList.item(0).getChildNodes;
        locFormat = char(locChildNode.item(1).getNodeName);
        if (strcmp(locFormat, 'CompleteLocation'))
            coordsFormat = char(doc.getElementsByTagName('CompleteLocation').item(0).getAttribute('coordsFormat'));
            locPos = getInteger(doc.getElementsByTagName('CompleteLocation').item(0).getTextContent);
        end
        if(strcmp(locFormat, 'SeparateLocation'))
            %coordsFormat = char(doc.getElementsByTagName('SeparateLocation').item(0).getAttribute('coordsFormat'));
            northPos = getInteger(doc.getElementsByTagName('North').item(0).getTextContent);
            westPos = getInteger(doc.getElementsByTagName('West').item(0).getTextContent);
            northFormat = char(doc.getElementsByTagName('North').item(0).getAttribute('coordsFormat'));
            westFormat = char(doc.getElementsByTagName('North').item(0).getAttribute('coordsFormat'));
            locPos = {northPos, westPos};
            coordsFormat = {northFormat, westFormat};
        end
    case 'OS'
        locChildNode = locList.item(0).getChildNodes;
        locFormat = char(locChildNode.item(1).getNodeName);
        if (strcmp(locFormat, 'CompleteLocation'))
            coordsFormat = char(doc.getElementsByTagName('CompleteLocation').item(0).getAttribute('coordsFormat'));
            locPos = getInteger(doc.getElementsByTagName('CompleteLocation').item(0).getTextContent);
        end
        if(strcmp(locFormat, 'SeparateLocation'))
            %coordsFormat = char(doc.getElementsByTagName('SeparateLocation').item(0).getAttribute('coordsFormat'));
            eastingPos = getInteger(doc.getElementsByTagName('Easting').item(0).getTextContent);
            northingPos = getInteger(doc.getElementsByTagName('Northing').item(0).getTextContent);
            eastingFormat = char(doc.getElementsByTagName('Easting').item(0).getAttribute('coordsFormat'));
            northingFormat = char(doc.getElementsByTagName('Northing').item(0).getAttribute('coordsFormat'));
            locPos = {eastingPos, northingPos};
            coordsFormat = {eastingFormat, northingFormat};
        end
    case 'Standard'
        locChildNode = locList.item(0).getChildNodes;
        locFormat = char(locChildNode.item(1).getNodeName);
        if (strcmp(locFormat, 'CompleteLocation'))
            coordsFormat = char(doc.getElementsByTagName('CompleteLocation').item(0).getAttribute('coordsFormat'));
            locPos = getInteger(doc.getElementsByTagName('CompleteLocation').item(0).getTextContent);
        end
        if(strcmp(locFormat, 'SeparateLocation'))
            %coordsFormat = char(doc.getElementsByTagName('SeparateLocation').item(0).getAttribute('coordsFormat'));
            latPos = getInteger(doc.getElementsByTagName('Latitude').item(0).getTextContent);
            lonPos = getInteger(doc.getElementsByTagName('Longtitude').item(0).getTextContent);
            latFormat = char(doc.getElementsByTagName('Latitude').item(0).getAttribute('coordsFormat'));
            lonFormat = char(doc.getElementsByTagName('Longtitude').item(0).getAttribute('coordsFormat'));
            locPos = {latPos, lonPos};
            coordsFormat = {latFormat, lonFormat};
        end
end

datasource = {bofName, bofSource, typeStatus, sheetStatus, vrmPos, timePos, camPos, geoFormat, coordsFormat,locFormat, locPos, headerStatus, timeFormat, nameFormat, makePos, modelPos, colorPos, taxPos};

%% Navigation
% * Go to 
% <..\html\main.html main> 
% * Go to 
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 

%% Author
%  Haiyue Yuan, 02.2016, Depatment of Computer Science, University of Surrey

