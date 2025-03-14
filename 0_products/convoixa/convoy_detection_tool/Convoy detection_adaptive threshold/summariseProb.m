function probTable = summariseProb(statsTable)
[len,~]=size(statsTable);
ct_2=1;
ct_3=1;
ct_4=1;
ct_5=1;
ct_6=1;
ct_7=1;

for i=1:len
    totalNum = statsTable{i,2};
    if totalNum>10000
        if i==133 || i==134 || i==71 || i==86 || i==87
            disp('invalid');
        else
            prob_2 = statsTable{i,3};
            prob_3 = statsTable{i,4};
            prob_4 = statsTable{i,5};
            prob_5 = statsTable{i,6};
            prob_6 = statsTable{i,7};
            prob_7 = statsTable{i,8};
            if ~isempty(prob_2)
                array_2(ct_2) = prob_2;
                ct_2 = ct_2+1;
            end
            if ~isempty(prob_3)
                array_3(ct_3) = prob_3;
                ct_3 = ct_3+1;
            end
            if ~isempty(prob_4)
                array_4(ct_4) = prob_4;
                ct_4 = ct_4+1;
            end
            if ~isempty(prob_5)
                array_5(ct_5) = prob_5;
                ct_5 = ct_5+1;
            end
            if ~isempty(prob_6)
                array_6(ct_6) = prob_6;
                ct_6 = ct_6+1;
            end
            if ~isempty(prob_7)
                array_7(ct_7) = prob_7;
                ct_7 = ct_7+1;
            end
        end
    end
end

probTable(1,1) = mean(array_2);
probTable(1,2) = std(array_2);
probTable(2,1) = mean(array_3);
probTable(2,2) = std(array_3);
probTable(3,1) = mean(array_4);
probTable(3,2) = std(array_4);
probTable(4,1) = mean(array_5);
probTable(4,2) = std(array_5);
probTable(5,1) = mean(array_6);
probTable(5,2) = std(array_6);
probTable(6,1) = mean(array_7);
probTable(6,2) = std(array_7);
