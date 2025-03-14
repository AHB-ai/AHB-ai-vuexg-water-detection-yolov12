function dist = calculateDistance(lat1, lont1, lat2, lont2)

%lat1 = 51.1697;		
%lont1 = -0.17389;
%lat2 = 51.02498;	
%lont2 = -0.17389;

% Reference: http://stackoverflow.com/questions/4000886/gps-coordinates-1km-square-around-a-point
lat_dis = 69.1*(lat2-lat1);
lont_dis = 53.0*(lont2 - lont1);
% The unit is mile
dist = sqrt((lat_dis)^2+(lont_dis)^2);

