% 
% This script is used to load intermediate data format descriptor and
% extract key information
% Input Argument:
% filename: the path of intermediate data format descriptor
% Output Argument:
% intermediat_format: is an array contains key information such as VRM,
% Capture Time, Camera Name, geo location format...
% Haiyue@Dec 2014

function intermediate_format = loadInterFormat(filename)
try
    doc = xmlread(filename);
catch
    error('Failed to read XML %s. ', filename);
end

typeList = doc.getElementsByTagName('FileSuffix');
typeStatus = char(typeList.item(0).getTextContent);

vrmList = doc.getElementsByTagName('VRM');
vrmPos = getInteger(vrmList.item(0).getTextContent);

dateList = doc.getElementsByTagName('CaptureDate');
datePos = getInteger(dateList.item(0).getTextContent);

timeList = doc.getElementsByTagName('CaptureTime');
timePos = getInteger(timeList.item(0).getTextContent);

camList = doc.getElementsByTagName('CameraName');
camPos = getInteger(camList.item(0).getTextContent);

locList = doc.getElementsByTagName('Location');
locPos = getInteger(locList.item(0).getTextContent);

makeList = doc.getElementsByTagName('Make');
makePos = getInteger(makeList.item(0).getTextContent);

modelList = doc.getElementsByTagName('Model');
modelPos = getInteger(modelList.item(0).getTextContent);

colorList = doc.getElementsByTagName('Color');
colorPos = getInteger(colorList.item(0).getTextContent);

taxList = doc.getElementsByTagName('Tax');
taxPos = getInteger(taxList.item(0).getTextContent);

% locList = doc.getElementsByTagName('Location');
% geoFormat = char(locList.item(0).getAttribute('geoFormat'));
% 
% locChildNode = locList.item(0).getChildNodes;
% locFormat = char(locChildNode.item(1).getNodeName);
% if (strcmp(locFormat, 'CompleteLocation'))
%     coordsFormat = char(doc.getElementsByTagName('CompleteLocation').item(0).getAttribute('coordsFormat'));
%     locPos = getInteger(doc.getElementsByTagName('CompleteLocation').item(0).getTextContent);
% end
% if(strcmp(locFormat, 'SeparateLocation'))
%     coordsFormat = char(doc.getElementsByTagName('SeparateLocation').item(0).getAttribute('coordsFormat'));
%     latPos = getInteger(doc.getElementsByTagName('Latitude').item(0).getTextContent);
%     lonPos = getInteger(doc.getElementsByTagName('Longtitude').item(0).getTextContent);
%     locPos = {latPos, lonPos};
% end

intermediate_format = {typeStatus, vrmPos, datePos, timePos, camPos, locPos, makePos, modelPos, colorPos, taxPos};
end