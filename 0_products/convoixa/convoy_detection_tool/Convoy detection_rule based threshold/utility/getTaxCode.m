function taxbook = getTaxCode(input)
taxbook = containers.Map('KeyType','char','ValueType','any');
[height,~]=size(input);
for i=1:height
    if ~isnan(input{i,1})
        type = input{i,1};
    end
    taxcode = num2str(input{i,2});
    details = input{i,3};
    if ~strcmp(taxcode, 'NaN') && ~strcmp(details, 'NaN')
        info.type = type;
        info.details = details;
        taxbook(taxcode) = info;
        clear info;
    end
end
end