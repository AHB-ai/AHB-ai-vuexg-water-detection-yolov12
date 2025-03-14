% This function is to find estimated travel time, given two camera
% name. As there is no accurate mapping between camera coordinates and
% public journey time coordinates, the output is only approximately
% estimated value for reference.
% INPUT:
% -dir_path: is the directory where store all journey time and predefined
% location.
% -date: date ('dd-mm-yyyy')
% -time: time ('hh:mm:ss')
% -anprMap: is included in the package
% -ANPR1: the starting ANPR camera name
% -ANPR2: the ending ANPR camera name
% -output_dir: is the directory where store all output report
% OUTPUT:
% -min_dist: is the average value of distance between starting point of a
% journey and ANPR1, and distance between ending point of a journey and
% ANPR2, this provides the confidence of the results
% -journeyValue: is the description of the journey
% -journeyDir: is the direction of the journey
% -travelTime: is current average travel times
% -freeFlowTravelTime: is the theoretical ideal travel times assuming free
% flowing traffic
% -expectedTravelTime: is the expected travel times baed on historic
% profiles
% All output is also generated in a csv format.The first row is min_dist,
% second row is journeyValue, third row is journeyDir, fourth row is
% travelTime, fifth row is freeFlowTravelTime, sixth row is
% expectedTravelTime.
% Haiyue@Jun 2015

function [min_dist,journeyValue,journeyDir, travelTime,freeFlowTravelTime,expectedTravelTime] = getPublicTravelTime(dir_path, date, time, anprMap, ANPR1, ANPR2, output_dir)
if ~exist(output_dir, 'file')
    mkdir(output_dir);
end
pathMap = build_path_map(dir_path);
journey_data = parseJourneyTime(pathMap, date, time);
preLoc_data = parsePredefinedLocation(pathMap, date, time);
journey_data = getJourneyTime(journey_data, preLoc_data);
disp('Start to search related public journey...');
if isempty(journey_data)
    min_dist = '';
    journeyValue = '';
    journeyDir = '';
    travelTime = '';
    freeFlowTravelTime = '';
    expectedTravelTime = '';
    disp('Can not find journey data, please check your input !');
end
if ~isempty(journey_data)
    val_o = anprMap(ANPR1);
    val_t = anprMap(ANPR2);
    lat_o = val_o.latitude;
    lon_o = val_o.longitude;
    lat_t = val_t.latitude;
    lon_t = val_t.longitude;
    dist_array = cell(length(journey_data),4);
    for i=1:length(journey_data)
        data = journey_data{i};
        locInfo = data.locInfo;
        locInfo = data.locInfo;
        fromLoc = locInfo.From;
        toLoc = locInfo.To;
        travelTime = data.travelTime;
        freeFlowTravelTime = data.freeFlowTravelTime;
        expectedTravelTime = data.expectedTravelTime;
        fromLat = str2num(fromLoc.Lat);
        fromLon = str2num(fromLoc.Lon);
        toLat = str2num(toLoc.Lat);
        toLon = str2num(toLoc.Lon);
        dist_start = calculateDistance(lat_o,lon_o,fromLat,fromLon);
        dist_end = calculateDistance(lat_t,lon_t,toLat,toLon);
        dist_avg = (dist_start+dist_end)/2;
        dist_array{i,1} = dist_avg;
        dist_array{i,2} = i;
        dist_array{i,3} = dist_start;
        dist_array{i,4} = dist_end;
    end
    disp('Generating report...');
    tmp_array = sortrows(dist_array,1);
    min_dist = tmp_array{1,1};
    min_indx = tmp_array{1,2};
    data = journey_data{min_indx};
    travelTime = data.travelTime;
    freeFlowTravelTime = data.freeFlowTravelTime;
    expectedTravelTime = data.expectedTravelTime;
    locInfo = data.locInfo;
    journeyValue = locInfo.value;
    journeyDir = locInfo.direction;
    
    file{1,1} = journeyValue;
    file{2,1} = journeyDir;
    file{3,1} = min_dist;
    file{4,1} = travelTime;
    file{5,1} = freeFlowTravelTime;
    file{6,1} = expectedTravelTime;
    timestamp = [time(1:2) time(4:4) '0'];
    output = [output_dir '\' ANPR1 ' ' ANPR2 ' ' date ' ' timestamp '.csv'];
    simplemat2csv(file, output);
    disp('Done !');
end
end