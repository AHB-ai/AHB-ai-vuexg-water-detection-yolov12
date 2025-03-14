%% Store Vehicle Information
%  This function is to store vehicle information including number of intervening vehicles, vrm, time, camera ID, make, color, model, and tax code.
%%

function [pairMap, tmpMap] = storePairs_v2(num_vehicle, carID_cur, carID_nxt, pairMap, idx, camID_tmp, search_data, t0, tmpMap, time_cur,camID,make,model,color,tax)
keyStr_original = [carID_cur ' ' carID_nxt];
keyStr_reverse = [carID_nxt ' ' carID_cur];
tf_o = isKey(pairMap, keyStr_original);
tf_r = isKey(pairMap, keyStr_reverse);
[time_nxt, make_nxt, color_nxt, model_nxt, tax_nxt] = getANPRreads(search_data, idx, t0);
%statsMap = storeStats(statsMap, carID_cur, camID, carID_nxt, camID_tmp, time_cur, time_nxt);
if tf_o == 1
    pair_data = pairMap(keyStr_original);
    pair_data{length(pair_data)+1}={time_cur,camID,make,model,color,tax,time_nxt,camID_tmp,make_nxt,model_nxt,color_nxt,tax_nxt,num_vehicle};
    pairMap(keyStr_original) = pair_data;
    tmpMap(carID_nxt)=1;
    %globalMap = storeTime(globalMap, carID_cur, search_data, idx);
    clear pair_data;
    clear time_nxt make_nxt model_nxt color_nxt tax_nxt;
end;
if tf_o == 0 && tf_r == 0
    pair_data{1}={time_cur,camID,make,model,color,tax,time_nxt,camID_tmp,make_nxt,model_nxt,color_nxt,tax_nxt,num_vehicle};
    pairMap(keyStr_original) = pair_data;
    tmpMap(carID_nxt)=1;
    %globalMap = storeTime(globalMap, carID_cur, search_data, idx);
    clear pair_data;
    clear time_nxt make_nxt model_nxt color_nxt tax_nxt;
end

%% Navigation
% * Back to 
% <..\html\main.html Convoy Analysis Tool>
% * Go to
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 


%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%%