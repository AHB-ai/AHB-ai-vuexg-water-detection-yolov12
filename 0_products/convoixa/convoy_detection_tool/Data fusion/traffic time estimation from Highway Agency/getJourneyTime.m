% This function is to merge the travel time and location information, and
% convert to a matlab format.
% Haiyue@Apr 2015

function journey_data = getJourneyTime(journey_data, preLoc_data)
disp('Start to merge journey time and predefined location...');   
if isempty(journey_data)
    disp('No journey data is found.');
end
if isempty(preLoc_data)
    disp('No predefined data is found.');
end
if ~isempty(journey_data) && ~isempty(preLoc_data)
preLocMap = containers.Map('KeyType','char','ValueType','any');
   for i=1:length(preLoc_data)
       locKey = preLoc_data{i}.id;
       if ~isKey(preLocMap, locKey)
           preLocMap(locKey) = i;           
       end
   end
   
   for j=1:length(journey_data)
       preLoc = journey_data{j}.preDefinedLoc;
       index = preLocMap(preLoc);
       preLocInfo = preLoc_data{index};
       journey_data{j}.locInfo = preLocInfo;
   end
   disp('Done !');
end
end