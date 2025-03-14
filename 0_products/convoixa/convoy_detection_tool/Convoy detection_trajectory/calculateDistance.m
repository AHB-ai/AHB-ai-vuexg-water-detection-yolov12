function dist = calculateDistance(ANPR1, ANPR2, anprMap)

if isKey(anprMap, ANPR1)
    val = anprMap(ANPR1);
    lat1 = val.latitude;
    lont1 = val.longitude;
else
    lat1 = 0;
    lont1 = 0;
end
clear val;
if isKey(anprMap, ANPR2)
    val = anprMap(ANPR2);
    lat2 = val.latitude;
    lont2 = val.longitude;
else
    lat2 = 0;
    lont2 = 0;
end

if lat1~=0 && lont1~=0 && lat2~=0 && lont2~=0
    % Reference: http://stackoverflow.com/questions/4000886/gps-coordinates-1km-square-around-a-point
    lat_dis = 69.1*(lat2-lat1);
    lont_dis = 53.0*(lont2 - lont1);
    % The unit is mile
    dist = sqrt((lat_dis)^2+(lont_dis)^2);
else
    dist = 0/0;
end

