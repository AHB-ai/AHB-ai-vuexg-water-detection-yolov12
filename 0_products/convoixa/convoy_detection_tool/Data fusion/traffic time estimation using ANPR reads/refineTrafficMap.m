function trafficMap = refineTrafficMap(inputFile)
t0 = 734139;
[~,name,~] = fileparts(inputFile);
tmp = strfind(name, '_');
date = name(1:tmp(1)-1);
dateNum = (datenum(date, 'dd-mm-yyyy')-t0)*24*3600;
load(inputFile);
keySet = keys(trafficMap);
for i=1:length(keySet)
    key = keySet{i};
    val = trafficMap(key);
    temp = val(:,1)-dateNum;
    val(:,1) = temp;
    trafficMap(key) = val;
end
end