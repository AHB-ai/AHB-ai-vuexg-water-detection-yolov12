
% Haiyue@Nov 2014

function pos = getInteger(input)
import java.lang.Integer;

if input.length>1
    size = (input.length)-1;
    %size = (input.length)-1;
    for i=1:size
        if (isstrprop(input.charAt(i),'digit'))
            temp = input.charAt(i);
            pos = Integer.parseInt(temp);
        end
    end
end

if input.length==1
    temp = input.charAt(0);
    pos = Integer.parseInt(temp);
end
