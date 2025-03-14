% Use make, model, color to retrieve convoy session
load('makeMap.mat');
[~,~] = getConvoyByVehicleInfo(makeMap, 'BMW', '320', 'RED');

% Use tax code to retrieve convoy session
load('taxConvoyMap.mat');
[~, output] = getConvoyByTax(taxConvoyMap, '11', '49', '03-05-2015');

% Find associated convoy given a convoy route
load('processedConvoyMap_doubleVRM.mat')
[~, convoy3_1]  = getConvoyWithConfidence(processedConvoyMap_doubleVRM, 'ANPR08.38 ANPR35.1 ANPR32.1 ANPR32.2 ANPR35.2 ANPR11.3', '06-04-2015', 1);
[~, convoy3_2]  = getConvoyWithConfidence(processedConvoyMap_doubleVRM, 'ANPR08.38 ANPR35.1 ANPR32.1 ANPR32.2 ANPR35.2 ANPR11.3', 'all', 1);
[~, convoy3_3]  = getConvoyWithConfidence(processedConvoyMap_doubleVRM, 'ANPR08.38 ANPR35.1 ANPR32.1 ANPR32.2 ANPR35.2 ANPR11.3', 'all', 0.8);