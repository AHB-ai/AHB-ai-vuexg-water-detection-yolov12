%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%% 
function [time_nxt, make_nxt, color_nxt, model_nxt, tax_nxt] = getANPRreads(search_data, idx, t0)
dateTmp = datenum(search_data{idx,2}, 'dd-mm-yyyy')-t0;
dateNum = dateTmp*24*3600;
sectmp = str2num(strrep(search_data{idx,3},':', ' '));
timeNum = sectmp(1)*3600+sectmp(2)*60+sectmp(3);
time_nxt = dateNum+timeNum;
make_nxt = search_data{idx,6};
model_nxt = search_data{idx,7};
color_nxt = search_data{idx,8};
tax_nxt = search_data{idx,9};