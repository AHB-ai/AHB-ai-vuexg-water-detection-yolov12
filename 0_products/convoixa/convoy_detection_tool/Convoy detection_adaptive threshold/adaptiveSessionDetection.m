function single_sessionMap = adaptiveSessionDetection(journeyMap, path_traffic, search_window, session_size)
t0 = 734139;
% Start to detect session for each vehicle
keySet = keys(journeyMap);
single_sessionMap = containers.Map('KeyType','char','ValueType','any');
disp('Start session detectin...');
for i=1:length(keySet)
    disp(i);
    vrm = keySet{i};
    val = journeyMap(vrm);
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
            u_s = 0.8;
            session_break = adapativeSessionBreak(camConnection, path_traffic, time, time_nxt, search_window, u_s);
        else
            session_break = 0;
        end
        if session_break == 0
            tmp_data{tmp_ct} = val{n+1};
            tmp_ct = tmp_ct+1;
            session{ct_session} = tmp_data;
        end
        if session_break == 1
            session{ct_session} = tmp_data;
            ct_session = ct_session+1;
            clear tmp_data;
            clear tmp_ct;
            tmp_data{1} = val{n};
            tmp_ct = 2;
            session{ct_session} = tmp_data;
        end
    end
    %session = cell(length(val),1);
%     for m=1:length(val)
%         time = val{m}.time;
%         camID = val{m}.camID;
%         pos = val{m}.pos;
% %         camID(camID==' ')='';
%         camID = camNameCorrection(camID);
%         journeyData(m,:) = {camID, time, pos};
%         clear camID;
%         clear time;
%     end
%     journeyData = sortrows(journeyData,2);
%     [len,~] = size(journeyData);
%     ct_session = 1;
%     tmp_data = cell(length(val),1);
%     tmp_data{1,1} = journeyData{1,1};
%     tmp_data{1,2} = journeyData{1,2};
%     tmp_data{1,3} = journeyData{1,3};
%     tmp_ct = 2;
%     for n=1:len-1
%         camId1 = journeyData{n,1};
%         datetime = journeyData{n,2};
%         camId2 = journeyData{n+1,1};
%         datetime_nxt = journeyData{n+1,2};
%         flag1 = strfind(camId1, 'ANPR');
%         flag2 = strfind(camId2, 'ANPR');
%         if ~isempty(flag1) && ~isempty(flag2)
%             camConnection = [camId1 ' ' camId2];
%             time = getTimeNum(datetime, t0);
%             time_nxt = getTimeNum(datetime_nxt, t0);
%             u_s = 0.8;
%             %display(camConnection);
%             session_break = adapativeSessionBreak(camConnection, path_traffic, time, time_nxt, search_window, u_s);
%             %display(session_break);
%         else
%             session_break = 0;
%         end
%         if session_break == 0
%             tmp_data{tmp_ct,1} = journeyData{n+1,1};
%             tmp_data{tmp_ct,2} = journeyData{n+1,2};
%             tmp_data{tmp_ct,3} = journeyData{n+1,3};
%             tmp_ct = tmp_ct+1;
%             session{ct_session} = tmp_data;
%         end
%         if session_break == 1
%             session{ct_session} = tmp_data;
%             ct_session = ct_session+1;
%             clear tmp_data;
%             clear tmp_ct;
%             tmp_data{1,1} = journeyData{n,1};
%             tmp_data{1,2} = journeyData{n,2};
%             tmp_data{1,3} = journeyData{n,3};
%             tmp_ct = 2;
%             session{ct_session} = tmp_data;
%         end
%     end
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