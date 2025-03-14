%% Defining Session
%  This function is to define session given a journey of a vehicle
%%
%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>carID</b></td><td>this is the vrm of the target vehicle.</td></tr>
% <tr><td><b>tS</b></td><td>this is session break threshold in unit of seconds</td></tr>
% <tr><td><b>journeyMap</b></td><td>this is hash map structure that store journey information for each vehicle.</td></tr>
% </table>
% </html>
%
% * OUTPUT:
%
% <html>
% <table border=2>
% <tr><td><b>session</b></td><td> this is the defined session data.</td></tr>
% </table>
% </html>
%
%% Code
function [session] = define_session(carID, tS, journeyMap)
val = journeyMap(carID);
length_tmp = length(val);
tmp_session = cell(length_tmp,1);
i = 1;
count_s = 1;
count_indx = 1;
while i+1 < length_tmp+1
    delta_t = val{i}.time - val{i+1}.time;
    if abs(delta_t) < tS || abs(delta_t)==tS
        if (i==length_tmp-1)
            if (i+1 - count_indx >1)
                count_c = 1;
                tmp_s = cell(length_tmp,1);
                for j = count_indx:i+1
                    tmp_s{count_c} = val{j};
                    count_c = count_c+1;
                end;
                clear count_c;
                clear j;
                count_tmp_s = 0;
                for k = 1:length(tmp_s)
                    if ~isempty(tmp_s{k})
                        count_tmp_s = count_tmp_s+1;
                    end;
                end;
                A = cell(count_tmp_s,1);
                for m = 1:count_tmp_s
                    A{m} = tmp_s{m};
                end;
                clear tmp_s;
                if(~isempty(A))
                    tmp_session{count_s} = A;
                    count_s = count_s+1;
                end;
                clear A;
            end;
        end;
        i = i+1;
    end;
    if abs(delta_t) > tS
        count_indx = i+1;    
        if(count_s==1)
            count_c = 1;
            tmp_s = cell(length_tmp,1);
            for j = 1:i
                tmp_s{count_c} = val{j};
                count_c = count_c+1;
            end;
            clear j;
            clear count_c;
        end;
        if(count_s~=1)
            count_c = 1;
            tmp_s = cell(length_tmp,1);
            for j = count_indx:i
                tmp_s{count_c} = val{j};
                count_c = count_c+1;
            end;
            clear j;
            clear count_c;
        end;
        count_tmp_s = 0;
        for k = 1:length(tmp_s)
            if ~isempty(tmp_s{k})
                count_tmp_s = count_tmp_s+1;
            end;
        end;
        A = cell(count_tmp_s,1);
        for m = 1:count_tmp_s
            A{m} = tmp_s{m};
        end;
        i = i+1;
        clear tmp_s;
        if(~isempty(A))
            tmp_session{count_s} = A;
            count_s = count_s+1;
        end;
        clear A;
    end;
end;
count_tmp_session = 0;
for k = 1:length(tmp_session)
    if ~isempty(tmp_session{k})
        count_tmp_session = count_tmp_session +1;
    end;
end;
session = cell(count_tmp_session,1);
for n = 1:count_tmp_session
    session{n} = tmp_session{n};
end;
clear count_s;
clear count_c;
%% Navigation
% * Back to 
% <..\html\main.html Convoy Analysis Tool>
% * Go to
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 


%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%%
