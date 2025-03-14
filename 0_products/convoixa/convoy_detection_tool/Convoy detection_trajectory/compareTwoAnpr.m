function flag_cmp = compareTwoAnpr(ANPR1, ANPR2, anprMap)
flag_cmp = 0;
if strcmp(ANPR1, ANPR2)
    flag_cmp = 1;
else
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
            if strcmp(camtmp1, camtmp2)
                flag_cmp = 1;
            end
        end
    end
end
end