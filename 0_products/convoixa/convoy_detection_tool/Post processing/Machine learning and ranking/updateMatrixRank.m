function matrix = updateMatrixRank(C, matrix)
if C(1,1)>C(2,1)
    idx = 2;
end
if C(2,1)>C(1,1)
    idx = 1;
end
c_1 = C(idx,1);
c_2 = C(idx,2);
[len,wid] = size(matrix);
for i=1:len
    t_1 = matrix(i,1);
    t_2 = matrix(i,2);
    dist = sqrt((c_1-t_1)^2+(c_2-t_2)^2);
    matrix(i,wid+1) = dist;
end