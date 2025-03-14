function single_sessionMap = adaptiveSessionDetection_v2(dataMap, path_traffic, session_window, session_size, perct)
t0 = 734139;
% Start to detect session for each vehicle
keySet = keys(dataMap);
single_sessionMap = containers.Map('KeyType','char','ValueType','any');
disp('Start session detectin...');
for i=1:length(keySet)
    disp(i);
    vrm = keySet{i};
    val = dataMap(vrm);
    session = {};
    tmp_data{1} = val{1};
    ct_session = 1;
    tmp_ct = 2;
    for n=1:length(val)-1
        camId1 = val{n}.camID;
        datetime = val{n}.time;
        camId2 = val{n+1}.camID;
        datetime_nxt = val{n+1}.time;
        flag1 = strfind(camId1, 'ANPR');
        flag2 = strfind(camId2, 'ANPR');
        if ~isempty(flag1) && ~isempty(flag2)
            camConnection = [camId1 ' ' camId2];
            time = getTimeNum(datetime, t0);
            time_nxt = getTimeNum(datetime_nxt, t0);
            [~, maxVal] = adapativeSessionBreak_v2(camConnection, path_traffic, time, session_window, perct);  
            time_diff = time_nxt - time;
            if time_diff>maxVal
                session_break = 1;
            else
                session_break = 0;
            end
        else
            session_break = 0;
        end        
        if session_break == 0
            tmp_data{tmp_ct} = val{n+1};
            tmp_ct = tmp_ct+1;
            %session{ct_session} = tmp_data;
        end
        if session_break == 1
            session{ct_session} = tmp_data;
            ct_session = ct_session+1;
            clear tmp_data;
            clear tmp_ct;
            tmp_data{1} = val{n};
            tmp_ct = 2;
            %session{ct_session} = tmp_data;
        end
        session{ct_session} = tmp_data;
    end
    if ~isempty(session)
        session_tmp = cell(size(session));
        session_c = 1;
        for j = 1:length(session)
            if length(session{j})>session_size
                session_tmp{session_c} = session{j};
                session_c = session_c+1;
            end;
        end;
        if ~isempty(session_tmp{1})
            single_sessionMap(vrm) = session_tmp;
        end;
        clear session_c;
        clear session_tmp;
    end
    clear tmp_ct;
    clear ct_session;
    clear tmp_data;
end
end