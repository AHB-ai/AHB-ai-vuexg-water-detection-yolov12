% Haiyue@Jun 2015
function monthList = getMonths(month_start, month_end)
tmp = strfind(month_start, '-');
m_start = str2num(month_start(1:tmp(1)-1));
y_start = str2num(month_start(tmp(1)+1:end));
tmp = strfind(month_end, '-');
m_end = str2num(month_end(1:tmp(1)-1));
y_end = str2num(month_end(tmp(1)+1:end));
if y_end > y_start
    num_end = y_end*12+m_end;
    num_start = y_start*12+m_start;
    delt_m = num_end-num_start;
    m_tmp = m_start;
    y_tmp = y_start;    
    monthList{1} = month_start;
    for i=1:delt_m
         m_tmp = m_tmp+1;
         if m_tmp>12
             y_tmp = y_tmp+1;
             m_tmp = 1;
         end     
         month = [num2str(m_tmp) '-' num2str(y_tmp)];
         monthList{i+1} = month;
    end
end
if y_end == y_start
    if m_end == m_start
        monthList = {month_start};
    end
    if m_end ~= m_start
        delt_m = m_end-m_start;
        for i=0:delt_m
            m_tmp = num2str(m_start+i);
            y_tmp = num2str(y_start);
            month = [m_tmp '-' y_tmp];
            monthList{i+1} = month;
        end
    end
end
end