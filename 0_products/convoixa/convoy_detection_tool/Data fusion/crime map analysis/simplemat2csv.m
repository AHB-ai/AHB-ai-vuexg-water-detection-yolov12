%%
% This function convert cell array to csv format
% Haiyue@May 2015

function simplemat2csv(input, output)
[m,n] = size(input);
for i=1:m
    for j=1:n   
        value = input{i,j};
        TF = isnan(value);
        if TF==1
            value = '';
            input{i,j}=num2str(value);
        end
        if TF==0
            input{i,j}=num2str(value);
        end
    end
end
Data = cell(m,n+n-1);
Data(:,1:2:end) = input;
Data(:,2:2:end,:) = {','};
Data = arrayfun(@(i) [Data{i,:}], 1:m, 'UniformOutput',false)';
foutput = fopen(output,'wt');
fprintf(foutput, '%s\n', Data{:});
fclose(foutput);

end