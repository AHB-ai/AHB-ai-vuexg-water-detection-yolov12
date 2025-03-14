% Haiyue@Aug 2015
% dir_path ='C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\traffic time estimation from ANPR reads\output_v2';
% search_window = 1800;
function session_break = adapativeSessionBreak(camConnection, dir_path, time, time_nxt, search_window, u_s)
file = [dir_path '\' camConnection '.mat'];
if ~exist(file, 'file')
    session_break = 0;
else
    tmp = load(file);
    data = tmp.data;
    % An adaptive parameter for session break
    [len,~] = size(data);
    if len>100
        lower_bound = time-search_window;
        upper_bound = time+search_window;
        [lower_index, upper_index] = binarySearch(data, lower_bound, upper_bound);
        output = data(lower_index:upper_index,2);
        if length(output)>100
            pd3 = fitdist(output,'Exponential');
            time_cmp = icdf(pd3,u_s);
            time_diff = time_nxt - time;
            if time_diff>time_cmp
                session_break = 1;
            else
                session_break = 0;
            end
        else
            session_break = 0;
        end
    else
        session_break = 0;
    end
end

