%% Session Detection
%  This function is to detect session for all vehicles 
%%
%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>journeyMap</b></td><td>this contains journey information for each vehicle.</td></tr>
% <tr><td><b>session_break</b></td><td>this is the threshold of session break in unit of hours.</td></tr>
% <tr><td><b>num_in_session</b></td><td>this is the threshold of convoy size.</td></tr>
% </table>
% </html>
%
% * OUTPUT:
%
% <html>
% <table border=2>
% <tr><td><b>single_sessionMap</b></td><td>updated journey data including session information . </td></tr>
% </table>
% </html>
%
%% Code
function [single_sessionMap] = singleSession(journeyMap, session_break, num_in_session)
%%
% Get a list of vrms and transfer session break threshold to seconds
keySet = keys(journeyMap);
tS = session_break*3600; 

single_sessionMap = containers.Map('KeyType','char','ValueType','any');
for m = 1:length(keySet)  
    %%
    % Define session for each vehicle using define_session
    % See
    % <..\html\define_session.html Defining Session>
    carID = keySet{m};
    [session] = define_session(carID,tS,journeyMap);
    %%
    % Refine session using convoy session size threshold
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
%% Linked Functions
% * See
% <..\html\define_session.html Defining Session>

%% Navigation
% * Back to 
% <..\html\main.html Convoy Analysis Tool>
% * Go to
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 


%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%%
