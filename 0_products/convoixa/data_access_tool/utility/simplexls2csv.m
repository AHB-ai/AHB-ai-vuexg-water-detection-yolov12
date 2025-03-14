
% This script convert xlsx/xls excel files to csv format
% Haiyue@May 2015

function simplexls2csv(file, output)
[~,~,book]=xlsread(file);
[m,n] = size(book);
for i=1:m
    for j=1:n   
        value = book{i,j};
        TF = isnan(value);
        if TF==1
            value = '';
            book{i,j}=num2str(value);
        end
        if TF==0
            book{i,j}=num2str(value);
        end
    end
end
Data = cell(m,n+n-1);
Data(:,1:2:end) = book;
Data(:,2:2:end,:) = {','};
Data = arrayfun(@(i) [Data{i,:}], 1:m, 'UniformOutput',false)';
foutput = fopen(output,'wt');
fprintf(foutput, '%s\n', Data{:});
fclose(foutput);

end