% This script is to detect single session for single file
% INPUT: 
% -inputData: intermediate format of ANPR data
% -output_dir: output directory to store the results
% -session_break: is the minimum time break between sessions (hour)
% -num_in_session: is the minimum number within one session
% -OUTPUT:
% -single_sessionMap: is the matlab data format store single session
% results
% Haiyue@July 2015

function [single_sessionMap] = singleSession(journeyMap, session_break, num_in_session)
% Start to detect session for each vehicle
keySet = keys(journeyMap);

tS = session_break*3600; % session threhold is five hours
%num_in_session = 5;
single_sessionMap = containers.Map('KeyType','char','ValueType','any');
for m = 1:length(keySet)
    %display(m);
    [carID, session] = define_session(m,tS,keySet,journeyMap);
    if ~isempty(session)
    session_tmp = cell(size(session));
    session_c = 1;
    for i = 1:length(session)
        if length(session{i})>num_in_session
            session_tmp{session_c} = session{i};
            session_c = session_c+1;
        end;
    end;   
    if ~isempty(session_tmp{1})
    single_sessionMap(carID) = session_tmp;
    end;
    clear session_c;
    clear session_tmp;
    end;
end;
end