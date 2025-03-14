% This function is to load the xml pre defined location file, and extract
% the location information, and convert to a matlab format
% Haiyue@Apr 2015

function preLoc_data = parsePredefinedLocation(pathMap, date, time)
disp('Start to parse predefined location...');
flag1 = strfind(date, '-');
day = date(1:flag1(1)-1);
month = date(flag1(1)+1:flag1(2)-1);
year = date(flag1(2)+1:end);
datestamp = date2str(day,month,year);

flag2 = strfind(time,':');
hour = time(1:flag2(1)-1);
min = time(flag2(1)+1:flag2(1)+1);
timestamp = [hour min];

fileKey = [datestamp ' ' timestamp];
preLoc_data = {};
if isKey(pathMap, fileKey)
    file = pathMap(fileKey);
    filename = file.predefined;
    if exist(filename, 'file')
        preLoc_data = {};
        Node = xmlread(filename);
        p_count = 1;
        if Node.hasChildNodes
            tmpNodes = Node.getChildNodes;
            % This childNode is d2LogicalModel
            childNode = tmpNodes.item(0);
            numChildNode = childNode.getLength;
            for count=1:numChildNode
                theChild = childNode.item(count-1);
                name = regexprep(char(theChild.getNodeName),'[-:.]','_');
                if (~strcmp(name,'#text') && ~strcmp(name,'#comment'))
                    if strcmp(name, 'payloadPublication')
                        newNodes = theChild.getChildNodes;
                        lenNode = newNodes.getLength;
                        for id=1:lenNode
                            newChild = newNodes.item(id-1);
                            name = regexprep(char(newChild.getNodeName),'[-:.]','_');
                            if (~strcmp(name,'#text') && ~strcmp(name,'#comment'))
                                if strcmp(name, 'publicationTime')
                                    time = char(newChild.getTextContent);
                                end
                                if strcmp(name, 'predefinedLocationSet')
                                    if newChild.hasChildNodes
                                        nodes = newChild.getChildNodes;
                                        for index = 1:nodes.getLength
                                            newChild = nodes.item(index-1);
                                            name = regexprep(char(newChild.getNodeName),'[-:.]','_');
                                            if (~strcmp(name,'#text') && ~strcmp(name,'#comment'))
                                                if strcmp(name, 'predefinedLocation')
                                                    predefinedLocData = struct;
                                                    predefinedLocData.time = time;
                                                    if newChild.hasAttributes
                                                        ref = char(newChild.getAttributes.item(0).getValue);
                                                        predefinedLocData.id = ref;
                                                    end
                                                    Node = newChild;
                                                    [~, subNode1] = getNodeData(Node, 'predefinedLocationName','text');
                                                    [~, subNode2] = getNodeData(Node, 'predefinedLocation' , 'text');
                                                    Node1 = subNode1;
                                                    [value, ~] = getNodeData(Node1, 'value', 'text');
                                                    predefinedLocData.value = value;
                                                    Node2 = subNode2;
                                                    [~, subNode] = getNodeData(Node2, 'tpeglinearLocation','text');
                                                    Node = subNode;
                                                    [direction, ~] = getNodeData(Node, 'tpegDirection', 'text');
                                                    [type, ~] = getNodeData(Node, 'tpegLocationType', 'text');
                                                    predefinedLocData.direction = direction;
                                                    predefinedLocData.type = type;
                                                    
                                                    [~, toNode] = getNodeData(Node, 'to', 'text');
                                                    subToNodes = toNode.getChildNodes;
                                                    [~, fromNode] = getNodeData(Node, 'from', 'text');
                                                    subFromNodes = fromNode.getChildNodes;
                                                    
                                                    %%%%%%%%%%%%To%%%%%%%%%%%%%%%%%%
                                                    toCoordsNode = subToNodes.item(0);
                                                    dataInfo = struct;
                                                    if ~isempty(toCoordsNode)
                                                        [lat, ~] = getNodeData(toCoordsNode, 'latitude', 'text');
                                                        [lon, ~] = getNodeData(toCoordsNode, 'longitude', 'text');
                                                        dataInfo.Lat = lat;
                                                        dataInfo.Lon = lon;
                                                        %predefinedLocData.to_Lat = lat;
                                                        %predefinedLocData.to_Lon = lon;
                                                    end
                                                    
                                                    toNameNode = subToNodes.item(1);
                                                    if ~isempty(toNameNode)
                                                        [descriptorType, ~] = getNodeData(toNameNode, 'tpegDescriptorType', 'text');
                                                        dataInfo.name_descriptorType = descriptorType;
                                                        %predefinedLocData.to_name_descriptorType = descriptorType;
                                                        Node = toNameNode;
                                                        [~, subNode] = getNodeData(Node, 'descriptor', 'text');
                                                        Node = subNode;
                                                        [value,~] = getNodeData(Node, 'value', 'text');
                                                        dataInfo.name_descriptorValue = value;
                                                        %predefinedLocData.to_name_descriptorValue = value;
                                                    end
                                                    
                                                    toilcNode1 = subToNodes.item(2);
                                                    if ~isempty(toilcNode1)
                                                        [descriptorType, ~] = getNodeData(toilcNode1, 'tpegDescriptorType', 'text');
                                                        dataInfo.ilc1_descriptorType = descriptorType;
                                                        %predefinedLocData.to_ilc1_descriptorType = descriptorType;
                                                        Node = toilcNode1;
                                                        [~, subNode] = getNodeData(Node, 'descriptor', 'text');
                                                        Node = subNode;
                                                        [value,~] = getNodeData(Node, 'value', 'text');
                                                        dataInfo.ilc1_descriptorValue = value;
                                                        %predefinedLocData.to_ilc1_descriptorValue = value;
                                                    end
                                                    
                                                    toilcNode2 = subToNodes.item(3);
                                                    if ~isempty(toilcNode2)
                                                        [descriptorType, ~] = getNodeData(toilcNode2, 'tpegDescriptorType', 'text');
                                                        dataInfo.ilc2_descriptorType = descriptorType;
                                                        %predefinedLocData.to_ilc2_descriptorType = descriptorType;
                                                        Node = toilcNode2;
                                                        [~, subNode] = getNodeData(Node, 'descriptor', 'text');
                                                        Node = subNode;
                                                        [value,~] = getNodeData(Node, 'value', 'text');
                                                        dataInfo.ilc2_descriptorValue = value;
                                                        %predefinedLocData.to_ilc2_descriptorValue = value;
                                                    end
                                                    predefinedLocData.To = dataInfo;
                                                    
                                                    %%%%%%%%%%%%From%%%%%%%%%%%%%%%%
                                                    fromCoordsNode = subFromNodes.item(0);
                                                    dataInfo = struct;
                                                    if ~isempty(fromCoordsNode)
                                                        [lat, ~] = getNodeData(fromCoordsNode, 'latitude', 'text');
                                                        [lon, ~] = getNodeData(fromCoordsNode, 'longitude', 'text');
                                                        dataInfo.Lat = lat;
                                                        dataInfo.Lon = lon;
                                                        %predefinedLocData.to_Lat = lat;
                                                        %predefinedLocData.to_Lon = lon;
                                                    end
                                                    
                                                    fromNameNode = subFromNodes.item(1);
                                                    if ~isempty(fromNameNode)
                                                        [descriptorType, ~] = getNodeData(fromNameNode, 'tpegDescriptorType', 'text');
                                                        dataInfo.name_descriptorType = descriptorType;
                                                        %predefinedLocData.to_name_descriptorType = descriptorType;
                                                        Node = fromNameNode;
                                                        [~, subNode] = getNodeData(Node, 'descriptor', 'text');
                                                        Node = subNode;
                                                        [value,~] = getNodeData(Node, 'value', 'text');
                                                        dataInfo.name_descriptorValue = value;
                                                        %predefinedLocData.to_name_descriptorValue = value;
                                                    end
                                                    
                                                    fromilcNode1 = subFromNodes.item(2);
                                                    if ~isempty(fromilcNode1)
                                                        [descriptorType, ~] = getNodeData(fromilcNode1, 'tpegDescriptorType', 'text');
                                                        dataInfo.ilc1_descriptorType = descriptorType;
                                                        %predefinedLocData.to_ilc1_descriptorType = descriptorType;
                                                        Node = fromilcNode1;
                                                        [~, subNode] = getNodeData(Node, 'descriptor', 'text');
                                                        Node = subNode;
                                                        [value,~] = getNodeData(Node, 'value', 'text');
                                                        dataInfo.ilc1_descriptorValue = value;
                                                        %predefinedLocData.to_ilc1_descriptorValue = value;
                                                    end
                                                    
                                                    fromilcNode2 = subFromNodes.item(3);
                                                    if ~isempty(fromilcNode2)
                                                        [descriptorType, ~] = getNodeData(fromilcNode2, 'tpegDescriptorType', 'text');
                                                        dataInfo.ilc2_descriptorType = descriptorType;
                                                        %predefinedLocData.to_ilc2_descriptorType = descriptorType;
                                                        Node = fromilcNode2;
                                                        [~, subNode] = getNodeData(Node, 'descriptor', 'text');
                                                        Node = subNode;
                                                        [value,~] = getNodeData(Node, 'value', 'text');
                                                        dataInfo.ilc2_descriptorValue = value;
                                                        %predefinedLocData.to_ilc2_descriptorValue = value;
                                                    end
                                                    predefinedLocData.From = dataInfo;
                                                end
                                                if exist('predefinedLocData', 'var')
                                                    preLoc_data{p_count} = predefinedLocData;
                                                    p_count = p_count+1;
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
if ~isKey(pathMap, fileKey)
    disp('Can not find the relevant predefined location data');
end
disp('Done !');
end