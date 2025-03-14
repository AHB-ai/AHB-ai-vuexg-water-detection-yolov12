%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%% 
function flag = compareVRM(vrms, vrms_cmp)
ct=0;
flag = 0;
if length(vrms) == length(vrms_cmp)
   for i=1:length(vrms)
       vrm = vrms{i};
       for j=1:length(vrms_cmp)
           vrm_cmp = vrms_cmp{j};
           if strcmp(vrm,vrm_cmp)
               ct=ct+1;
           end
       end
   end
   if ct==length(vrms)
       flag = 1;
   else
       flag = 0;
   end
end