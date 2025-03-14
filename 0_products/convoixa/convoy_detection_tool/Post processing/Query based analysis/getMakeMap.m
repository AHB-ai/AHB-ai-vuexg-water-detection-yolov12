% map = processedConvoyMap_singleVRM
function makeMap = getMakeMap(map)
makeMap = containers.Map('KeyType','char','ValueType','any');
globalMap = containers.Map('KeyType','char','ValueType','any');
keySet = keys(map);
for i=1:length(keySet)
    val = map(keySet{i});
    for j=1:length(val)
        data = val{j}{1};
        vrm1 = data{1,1};
        vrm2 = data{2,1};
        timeS1 = data{1,2};
        timeE1 = data{length(data)-1,2};
        timeS2 = data{2,2};
        timeE2 = data{length(data),2};
        cam1 = data{1,3};
        cam2 = data{2,3};
        make1 = data{1,4};
        make2 = data{2,4};
        model1 = data{1,5};
        model2 = data{2,5};
        color1 = data{1,6};
        color2 = data{2,6};
        tax1 = data{1,7};
        tax2 = data{2,7};
        if ~isempty(make1)
            [make1, model1, color1] = checkVehicleCode(make1, model1, color1, tax1);
            [makeMap, globalMap] = storeVehicleInfo(makeMap, vrm1, timeS1, timeE1, cam1, make1, model1, color1, data, globalMap);
        end
        if ~isempty(make2)
            [make2, model2, color2] = checkVehicleCode(make2, model2, color2, tax2);
            [makeMap, globalMap] = storeVehicleInfo(makeMap, vrm2, timeS2, timeE2, cam2, make2, model2, color2, data, globalMap);
        end
    end
end

function [makeMap, globalMap] = storeVehicleInfo(makeMap, vrm, timeS, timeE, cam, make, model, color, data, globalMap)
globalID = [vrm ' ' num2str(timeS) ' ' num2str(timeE) ' ' cam ' ' make ' ' model ' ' color];
if ~isKey(globalMap, globalID)
    globalMap(globalID) = 1;
    if ~isKey(makeMap, make)
        modelMap = containers.Map('KeyType','char','ValueType','any');
        colorMap = containers.Map('KeyType','char','ValueType','any');
        convoys{1} = data;
        colorMap(color) = convoys;
        modelMap(model) = colorMap;
        makeMap(make) = modelMap;
    else
        modelMap = makeMap(make);
        if ~isKey(modelMap, model)
            colorMap = containers.Map('KeyType','char','ValueType','any');
            convoys{1} = data;
            colorMap(color) = convoys;
            modelMap(model) = colorMap;
            makeMap(make) = modelMap;
        else
            colorMap = modelMap(model);
            if ~isKey(colorMap, color)
                convoys{1} = data;
                colorMap(color) = convoys;
                modelMap(model) = colorMap;
                makeMap(make) = modelMap;
            else
                convoys = colorMap(color);
                convoys{length(convoys)+1} = data;
                colorMap(color) = convoys;
                modelMap(model) = colorMap;
                makeMap(make) = modelMap;
            end
        end
    end
end

function [make, model, color] = checkVehicleCode(make, model, color, tax)
count = 0;
if ~isempty(make)
    count = count+1;
end
if ~isempty(model)
    count = count+1;
end
if ~isempty(color)
    count = count+1;
end
if ~isempty(tax)
    count = count+1;
end
if count == 4
    make = make;
    model = model;
    color = color;
end
if count == 3
    color = model;
    model = '';
    make = make;
end




