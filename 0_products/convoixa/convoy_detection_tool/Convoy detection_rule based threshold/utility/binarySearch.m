% Haiyue@Aug 2015
function [lower_index,upper_index] = binarySearch(input_data,lower_bound,upper_bound)
[len,~] = size(input_data);
if lower_bound>input_data(len,1) || upper_bound<input_data(1,1) || upper_bound<lower_bound
    % no indices satify bounding conditions
    lower_index = [];
    upper_index = [];
    return;
end

lower_index_a=1;
lower_index_b=len; 
upper_index_a=1;         
upper_index_b=len;

while (lower_index_a+1<lower_index_b) || (upper_index_a+1<upper_index_b)

    lw=floor((lower_index_a+lower_index_b)/2); % split the upper index

    if input_data(lw,1) >= lower_bound
        lower_index_b=lw; 
    else
        lower_index_a=lw; 
        if (lw>upper_index_a) && (lw<upper_index_b)
            upper_index_a=lw;
        end
    end

    up=ceil((upper_index_a+upper_index_b)/2);% split the lower index
    if input_data(up,1) <= upper_bound
        upper_index_a=up; 
    else
        upper_index_b=up; 
        if (up<lower_index_b) && (up>lower_index_a)
            lower_index_b=up;
        end
    end
end

if input_data(lower_index_a,1)>=lower_bound
    lower_index = lower_index_a;
else
    lower_index = lower_index_b;
end
if input_data(upper_index_b,1)<=upper_bound
    upper_index = upper_index_b;
else
    upper_index = upper_index_a;
end