function [convoy, convoy_date] = getConvoyByVehicleInfo(makeMap, make, model, color)
t0 = 734139;
convoy = {};
convoy_date = {};
keyMake = keys(makeMap);
flag_make = strcmp(make, 'all');
flag_model = strcmp(model, 'all');
flag_color = strcmp(color, 'all');
count = 1;
if flag_make == 1
    for i = 1:length(keyMake)
        makeID = keyMake{i};
        modelMap = makeMap(makeID);
        [convoy, count] = checkModel(flag_model, flag_color, model, color, modelMap, count, convoy);
    end
else
    if isKey(makeMap, make)
        modelMap = makeMap(make);
        [convoy, ~] = checkModel(flag_model, flag_color, model, color, modelMap, count, convoy);
    end
end

if ~isempty(convoy)
    for i=1:length(convoy)
        read = convoy{i};
        [len,~] = size(read);
        for n=1:len
            datetime = read{n,2};
            time_str = datestr(t0+datetime/86400);
            read{n,2} = time_str;
        end
        convoy_date{i} = read;
    end
end
%---------------------------------------------------------------------------------------------------%
function [convoy, count] = checkModel(flag_model, flag_color, model, color, modelMap, count, convoy)
if flag_model == 1
    keyModel =  keys(modelMap);
    for j = 1:length(keyModel);
        modelID = keyModel{j};
        colorMap = modelMap(modelID);
        [convoy, count] = checkColor(flag_color, color, colorMap, count, convoy);
    end
else
    if isKey(modelMap, model)
        colorMap = modelMap(model);
        [convoy, count] = checkColor(flag_color, color, colorMap, count, convoy);
    else 
        keyModel =  keys(modelMap);
        for j = 1:length(keyModel);
            modelID = keyModel{j};
            tmp = strfind(modelID, model);
            if ~isempty(tmp)
                colorMap = modelMap(modelID);
                [convoy, count] = checkColor(flag_color, color, colorMap, count, convoy);
            end
        end
    end
end

function [convoy, count] = checkColor(flag_color, color, colorMap, count, convoy)
if flag_color == 1
    keyColor = keys(colorMap);
    for m = 1:length(keyColor)
        colorID = keyColor{m};
        data = colorMap(colorID);
        for n = 1:length(data)
            convoy{count} = data{n};
            count = count +1;
        end
    end
else
    if isKey(colorMap, color)
        data = colorMap(color);
        for n = 1:length(data)
            convoy{count} = data{n};
            count = count +1;
        end
    end
end