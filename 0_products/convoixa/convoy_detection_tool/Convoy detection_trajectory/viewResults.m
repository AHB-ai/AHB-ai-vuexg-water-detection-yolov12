function new_convoy = viewResults(new_cell, tmpMap, keySet)
t0 = 734139;
new_convoy = cell(length(new_cell)-1,1);
for i=1:length(new_cell)-1
    tmp= new_cell{i};
    if ~isempty(tmp)
        idx1=tmp{1};
        idx2=tmp{2};
        val1= tmpMap(keySet{idx1});
        val2 = tmpMap(keySet{idx2});
        [len,~] = size(val1);
        for j=1:len
            val1{j,1} = datestr(t0+val1{j,1}/86400);
        end
        [len,~] = size(val2);
        for j=1:len
            val2{j,1} = datestr(t0+val2{j,1}/86400);
        end
        emptycell = {'','',''};
        val = [val1 ; emptycell ; val2];
        [len_val, ~] = size(val);
        ct = len_val+2;
        %new_convoy{i} = val;
        %clear val;
        tmp = new_cell{i}{3};
        [len,~]=size(tmp);
        for j=1:len
            id1 = j;
            id2 = tmp(j,2);
            if id1~=0 && id2~=0
                time_diff = tmp(j,1);
                time1 = val1{id1,1};
                time2 = val2{id2,1};
                anpr1 = val1{id1,2};
                anpr2 = val2{id2,2};
                val{ct,1} = time1;
                val{ct,2} = anpr1;
                ct=ct+1;
                val{ct,1} = time2;
                val{ct,2} = anpr2;
                ct=ct+1;
            end
        end
        new_convoy{i,1} = val;
        new_convoy{i,2} = ((mean(tmp(:,1))*length(tmp(:,1))-max(tmp(:,1))-min(tmp(:,1)))/(length(tmp(:,1))-2))/60;
        new_convoy{i,3} = std(tmp(:,1));
        clear val;
        clear new_val;
    end
end