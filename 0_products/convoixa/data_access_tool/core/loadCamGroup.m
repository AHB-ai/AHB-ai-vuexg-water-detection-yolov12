
% This script is to load the xml descriptor of camera groups
% Haiyue @Feb 2015

function camGroups = loadCamGroup(filename)
%[path, name] = fileparts(filename);
camGroups = containers.Map('KeyType','char','ValueType','any');
try
    doc = xmlread(filename);
catch
    error('Failed to read XML %s. ', filename);
end;
camList = doc.getElementsByTagName('CameraGroup');

for i=0:camList.getLength-1;    
    camChildNode = camList.item(i).getChildNodes;
    camName = char(camChildNode.item(1).getTextContent);
    %townLat = str2double(char(townChildNode.item(3).getTextContent));
    %townLot = str2double(char(townChildNode.item(5).getTextContent));
    if isKey(camGroups,camName)==0
        %coords = {townLat, townLot};
        camGroups(camName) = '';
    end
end
%save(fullfile(path, [name '.mat']),'mapTowns');
