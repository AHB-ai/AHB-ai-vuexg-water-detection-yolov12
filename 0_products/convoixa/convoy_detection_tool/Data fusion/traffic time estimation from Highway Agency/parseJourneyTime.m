% This function is to load the xml journey file, and extract the travel
% time, and convert to a matlab format
% Haiyue@Apr 2015
function journey_data = parseJourneyTime(pathMap, date, time)
disp('Start to parse journey time...');
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
journey_data={};
if isKey(pathMap, fileKey)
    file = pathMap(fileKey);
    filename = file.journey;
    if exist(filename, 'file')
        journey_data={};
        Node = xmlread(filename);
        j_count=1;
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
                                if strcmp(name, 'elaboratedData')
                                    elaboratedData = struct;
                                    if newChild.hasAttributes
                                        ref = char(newChild.getAttributes.item(0).getValue);
                                    end
                                    if exist('ref','var')
                                        elaboratedData.ref = ref;
                                    end
                                    Node = newChild;
                                    [~, subNode] = getNodeData(Node, 'basicDataValue', 'text');
                                    Node = subNode;
                                    [time, ~] = getNodeData(Node, 'time', 'text');
                                    [travelTime, ~] = getNodeData(Node, 'travelTime', 'text');
                                    [freeFlowTravelTime, ~] = getNodeData(Node, 'freeFlowTravelTime', 'text');
                                    [expectedTravelTime, ~] = getNodeData(Node, 'normallyExpectedTravelTime', 'text');
                                    elaboratedData.time = time;
                                    elaboratedData.travelTime = travelTime;
                                    elaboratedData.freeFlowTravelTime = freeFlowTravelTime;
                                    elaboratedData.expectedTravelTime = expectedTravelTime;
                                    [~, subNode] = getNodeData(Node, 'affectedLocation', 'text');
                                    Node = subNode;
                                    [~, subNode] = getNodeData(Node, 'locationContainedInGroup', 'text');
                                    Node = subNode;
                                    [preDefinedLoc, ~] = getNodeData(Node, 'predefinedLocationReference', 'text');
                                    elaboratedData.preDefinedLoc = preDefinedLoc;
                                end
                                if exist('elaboratedData','var')
                                    journey_data{j_count}=elaboratedData;
                                    j_count=j_count+1;
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
    disp('Can not find the relevant journey data');
end
disp('Done !');
end