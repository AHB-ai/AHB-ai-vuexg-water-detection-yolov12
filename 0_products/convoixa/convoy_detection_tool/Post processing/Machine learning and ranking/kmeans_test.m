clust_1 = rankMat(rankMat(:,15)==1,:);
clust_2 = rankMat(rankMat(:,15)==0.5,:);
clust_3 = rankMat(rankMat(:,15)==0,:);


% 1st round k-means accodring to duration
[IDX,~] = kmeans(matrix(:,8),2);
% new data set based on 1st round k-means
new_matrix = matrix(IDX==1,:);
% 2nd round k-means  
[IDX,C] = kmeans(new_matrix(:,1:6),2);
% new data set based on 2nd round k-means
clus_1 = new_matrix(IDX==1,:);
clus_2 = new_matrix(IDX==2,:);

% % 3rd round k-means based on 1st and 2nd column of the data
% [IDX,C] = kmeans(clus2(:,1:6),2);
% % results based on 3rd round k-means
% clus_1 = clus2(IDX==1,:);
% clus_2 = clus2(IDX==2,:);

X(:,1) = matrix(:,1);
X(:,2) = matrix(:,2);
plot(X(IDX==1,1),X(IDX==1,2),'bo','MarkerSize',5)
hold on;
plot(X(IDX==2,1),X(IDX==2,2),'go','MarkerSize',5)
hold on;
plot(X(IDX==3,1),X(IDX==3,2),'Ro','MarkerSize',5)
hold on;

plot(X(IDX==2,1),X(IDX==2,2),'go','MarkerSize',5)

plot(C(2), C(4), 'r*', 'markersize',10)

[IDX,~] = kmeans(new_matrix(:,1:2),2);
clus1 = new_matrix(IDX==1,:);
clus2 = new_matrix(IDX==2,:);

load('processedConvoyMap_doubleVRM.mat')
map = processedConvoyMap_doubleVRM;
[matrix] = generateFeatures(map);
% 1
[IDX1, ~] = kmeans(matrix1(:,1),2);
X = matrix1(:,1:2);
plot(X(IDX1==1,1),X(IDX1==1,2),'r.','MarkerSize',12)
hold on;
plot(X(IDX1==2,1),X(IDX1==2,2),'b.','MarkerSize',12)
matrix(:,11) = IDX1;
matrix = sortrows(matrix,11);
% 2
[IDX2, ~] = kmeans(matrix1(:,2:3),2);
X = matrix1(:,2:3);
plot(X(IDX2==1,1),X(IDX2==1,2),'r.','MarkerSize',12)
hold on;
plot(X(IDX2==2,1),X(IDX2==2,2),'b.','MarkerSize',12)
matrix1(:,11) = IDX2;
matrix1 = sortrows(matrix1,11);
% 3
[IDX3, ~] = kmeans(matrix11(:,2:3),2);
X = matrix11(:,2:3);
plot(X(IDX3==1,1),X(IDX3==1,2),'r.','MarkerSize',12)
hold on;
plot(X(IDX3==2,1),X(IDX3==2,2),'b.','MarkerSize',12)
matrix11(:,11) = IDX3;
matrix11 = sortrows(matrix11,11);
% 4
[IDX4, ~] = kmeans(matrix111(:,2:3),2);
X = matrix111(:,2:3);
plot(X(IDX4==1,1),X(IDX4==1,2),'r.','MarkerSize',12)
hold on;
plot(X(IDX4==2,1),X(IDX4==2,2),'b.','MarkerSize',12)
matrix111(:,11) = IDX4;
matrix111 = sortrows(matrix111,11);

% 5
[IDX5, C] = kmeans(matrix1111(:,2:3),2);
X = matrix1111(:,2:3);
plot(X(IDX5==1,1),X(IDX5==1,2),'r.','MarkerSize',12)
hold on;
plot(X(IDX5==2,1),X(IDX5==2,2),'b.','MarkerSize',12)
matrix1111(:,11) = IDX5;
matrix1111 = sortrows(matrix1111,11);

[m,n] = size(matrix1111);
for i=1:m
    listOfKeys(i,1) = matrix1111(i,9);
    listOfKeys(i,2) = matrix1111(i,10);
end


X = matrix1111(:,2:3);
Y = matrix(:,2:3);
[IDX,D] = knnsearch(X,Y);

