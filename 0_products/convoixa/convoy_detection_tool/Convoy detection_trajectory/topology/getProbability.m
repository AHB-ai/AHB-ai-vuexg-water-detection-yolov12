function prob = getProbability(ANPR1, ANPR2, anprMap, topologyStats)
camLinkList{1} = [ANPR1 ' ' ANPR2];
ct = 2;
if isKey(anprMap, ANPR1)
    temp1 = anprMap(ANPR1);
    if isfield(temp1,'relatedCams')
        cams1 = temp1.relatedCams;
    else
        cams1 = {};
    end
else
    cams1 = {};
end
cams1{length(cams1)+1} = ANPR1;
if isKey(anprMap, ANPR2)
    temp2 = anprMap(ANPR2);
    if isfield(temp2,'relatedCams')
        cams2 = temp2.relatedCams;
    else
        cams2 = {};
    end
else
    cams2 = {};
end
cams2{length(cams2)+1} = ANPR2;
for i=1:length(cams1)
    camtmp1 = cams1{i};
    for j=1:length(cams2)
        camtmp2 = cams2{j};
        if ~strcmp(camtmp1, ANPR1) || ~strcmp(camtmp2,ANPR2)
            camLinkTemp = [camtmp1 ' ' camtmp2];
            camLinkList{ct} = camLinkTemp;
            ct = ct + 1;
        end
    end
end
count = 1;
for i=1:length(camLinkList)
    camLink = camLinkList{i};
    if isKey(topologyStats,camLink)
        probList(count) = topologyStats(camLink);
        count = count+1;
    end
end
if exist('probList', 'var')
    prob = mean(probList);
else
    prob = 0/0;
end