% This script is used to standarise the output format according to the 
% intermediate data descriptor
% Input Argument:
% headerIdx: this is to confirm if the inputfile has header or not.
% vrmIdx: this is the index of VRM obtained from fileConverter
% timeIdx: this is the index of Capture time obtained from fileConverter
% camIdx: this is the index of Camera name obtained from fileConverter
% filename: this is inputfile name inherited from fileConverter
% Output: a single csv file with standard format defined in intermediate
% data format descriptor.
% Haiyue@Dec 2014
function interFormat(headerIdx, vrmIdx, timeIdx, camIdx, locIdx, intermediate_format, filename)

fprintf('--Generating intermediate output...\n');
fid = fopen(filename);

% Only three values are stored 'VRM','TIME','CAMERA NAME'
out = textscan(fid,'%s %s %s %s %s %s %s %s %s','delimiter',',');
% load intermediate format descriptor
interformat = loadInterFormat(intermediate_format);
type = interformat{1};
vrmPos = interformat{2}+1;
datePos = interformat{3}+1;
timePos = interformat{4}+1;
camPos = interformat{5}+1;
locPos = interformat{6}+1;
makePos = interformat{7}+1;
modelPos = interformat{8}+1;
colorPos = interformat{9}+1;
taxPos = interformat{10}+1;
% re-arrange index 
tempArray = [vrmIdx, timeIdx, camIdx, locIdx];
for i = 1:length(tempArray)
    if tempArray(i)<timeIdx
        if tempArray(i)==vrmIdx
            vrmIdx_new = vrmIdx;
        end
        if tempArray(i)==camIdx
            camIdx_new = camIdx;
        end
        if tempArray(i)==locIdx
            locIdx_new = locIdx;
        end
    end
    if tempArray(i)==timeIdx
        dateIdx_new = timeIdx;
        timeIdx_new = timeIdx+1;
    end
    if tempArray(i)>timeIdx
        if tempArray(i)==vrmIdx
            vrmIdx_new = vrmIdx+1;
        end
        if tempArray(i)==camIdx
            camIdx_new = camIdx+1;
        end
        if tempArray(i)==locIdx
            locIdx_new = locIdx+1;
        end
    end
end

col{vrmIdx_new} = out{vrmIdx_new};
col{camIdx_new} = out{camIdx_new};
col{dateIdx_new} = out{dateIdx_new};
col{timeIdx_new} = out{timeIdx_new};
col{locIdx_new} = out{locIdx_new};
col{6} = out{makePos};
col{7} = out{modelPos};
col{8} = out{colorPos};
col{9} = out{taxPos};

len = length(col{vrmIdx_new});
len_tmp = len-(headerIdx-1);
tmpData(1:len_tmp,vrmPos) = col{vrmIdx_new}(headerIdx:len,1);
tmpData(1:len_tmp,timePos) = col{timeIdx_new}(headerIdx:len,1);
tmpData(1:len_tmp,camPos) = col{camIdx_new}(headerIdx:len,1);
tmpData(1:len_tmp,locPos) = col{locIdx_new}(headerIdx:len,1);
tmpData(1:len_tmp,datePos) = col{dateIdx_new}(headerIdx:len,1);
tmpData(1:len_tmp,makePos) = col{6}(headerIdx:len,1);
tmpData(1:len_tmp,modelPos) = col{7}(headerIdx:len,1);
tmpData(1:len_tmp,colorPos) = col{8}(headerIdx:len,1);
tmpData(1:len_tmp,taxPos) = col{9}(headerIdx:len,1);

% %tmpData = {length(col{vrmIdx}),3};
% for i=1:length(col{vrmIdx})    
%     tmpData(i,vrmPos) = col{vrmIdx}(i);
%     tmpData(i,timePos) = col{timeIdx}(i);
%     tmpData(i,camPos) = col{camIdx}(i);
% end


% transfer data structure in order to save it as csv file
[m n] = size(tmpData);
Data = cell(m,n+n-1);
Data(:,1:2:end) = tmpData;
Data(:,2:2:end,:) = {','};
Data = arrayfun(@(i) [Data{i,:}], 1:m, 'UniformOutput',false)';
foutput = fopen(filename,'wt');
fprintf(foutput, '%s\n', Data{:});
fclose(foutput);
fclose(fid);
clear col;
clear Data;
clear tmpData;
clear foutput;
%fprintf('DONE!\n');
