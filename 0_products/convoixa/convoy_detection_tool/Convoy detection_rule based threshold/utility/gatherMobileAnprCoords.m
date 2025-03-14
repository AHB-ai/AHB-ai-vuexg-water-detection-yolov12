function gatherMobileAnprCoords(rawFile, mobile_path)
map = containers.Map('KeyType','char','ValueType','any');
load(rawFile);
data = output.data;
date = data{1,2};
[height,~] = size(data);
for i=1:height
    camId = data{i,4};
    tmp = strfind(camId, 'ANPR');    
    if isempty(tmp)
       camId(camId==' ')='';
       coords = data{i,5};
       time_str = data{i,3};
       vrm = data{i,1};
       if ~isempty(coords)
           flag = strfind(coords, ' ');
           lat = coords(1:flag(1)-1);
           lon = coords(flag(1)+1:end);
           info.latitude = lat;
           info.longtitude = lon;
           key = [vrm ' ' time_str ' ' camId];
           map(key)=info;
       end
    end
end
save([mobile_path '\' date '.mat'],'map');
clear map;