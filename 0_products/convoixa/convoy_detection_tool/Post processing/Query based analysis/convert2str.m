function anprStr = convert2str(group_anpr)
str_len = length(group_anpr)/2;
ct = 0;
anprStr = '';
for i=1:str_len
    idx = i+ct;
    cam = group_anpr{idx};
    ct = ct+1;
    anprStr = [anprStr ' ' cam];
end