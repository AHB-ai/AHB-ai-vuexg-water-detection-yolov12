
% Haiyue@Aug 2015
%dir_path = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\traffic time estimation from ANPR reads\traffic_output\travel time_no vrm_v2';
%output_dir = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\traffic time estimation from ANPR reads\output';
function traffic_matrix = gatherTrafficTime(dir_path, output_dir, anprMap)
disp('Start processing...');
if ~exist(output_dir, 'file')
    mkdir(output_dir);
end

key = keys(anprMap);
traffic_matrix = cell(length(key)+1,length(key)+1);
for i=1:length(key)
    camId = key{i};
    camId(camId==' ')='';
    camId = camNameCorrection(camId);
    traffic_matrix{1,i+1} = camId;
    traffic_matrix{i+1,1} = camId;
end
fileList = getAllFiles(dir_path);

for i=1:length(fileList)
    tic;
    display(i);
    file = fileList{i};
    load(file); 
    for m=2:length(key)+1        
        camId_1 = traffic_matrix{1,m};
        for n=2:length(key)+1
            camId_2 = traffic_matrix{n,1};
            camConnection = [camId_1 ' ' camId_2];
            if isKey(trafficMap, camConnection)
                temp = trafficMap(camConnection);
                refFile = [output_dir '\' camConnection '.mat'];
                results = [];
                if exist(refFile, 'file')
                    load(refFile);
                    results = [results;temp];
                else
                    results = temp;
                end
                save(refFile,'results');
                clear results;
                traffic_matrix{n,m}=refFile;
                clear file;
            end
        end
    end
    toc;
end

% tic;
% camId_1 = 'ANPR08.35';
% camId_2 = 'ANPR08.37';
% camConnection = [camId_1 ' ' camId_2];
% results = [];
% for i=1:length(fileList)
%     file = fileList{i};
%     load(file);
%     if isKey(trafficMap, camConnection)
%         temp = trafficMap(camConnection);       
%         results = [results;temp];
%     end
% end
% toc;
end