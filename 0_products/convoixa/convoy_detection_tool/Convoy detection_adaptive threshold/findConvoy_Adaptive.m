function convoyMap = findConvoy_Adaptive(date, anprMap, rawFile, journeyFile, convoyFile, journey_path, convoy_path)
if ~exist(convoyFile, 'file')
    disp('Loading raw data...');
    load(rawFile);
    disp('Extracting journey information...');
    if ~exist(journeyFile, 'file')
        [journeyMap] = singleJourney(output, journey_path);
    else
        load(journeyFile);
    end
    
    % filter journey data to reduce the data size
    disp('Filtering journey data...');
    dataMap = filterJourneyData_Adaptive(journeyMap, sessionSizeMap, anprMap);
    
    disp('Journey data is ready !');
    disp('Start session detection...');
    [single_sessionMap] = singleSession(dataMap, session_break, num_in_session);
    disp('Single vehicle session data is ready !');
    
    disp('Searching convoy session...');
    threshold_delt = search_window*60;
    data = output.data;
    index = output.index;
    key = keys(index);
    camMap = index(key{1});
    %date_string = data{1,2};
    [pairMap] = pair_search(single_sessionMap, single_sessionMap, data, threshold_delt, camMap, anprMap);
    
    disp('Convoy pairs search is done !');
    
    %filter convoy pairs, and generate results
    disp('Refining convoy session...');
    %threshold_pair = 0;
    convoyMap = refineConvoy(pairMap, num_in_session);
    convoyMap = analyseConvoy(convoyMap, anprMap);
    
    disp('Saving convoy session...');
    save([convoy_path '\' date '_export.mat'],'convoyMap');
else
    load(convoyFile);
end
