% This script is to correct ANPR name, as there are some typos
% Here records all typos that are founded during the development
% Haiyue@Jun 2015
function output = camNameCorrection(input)
switch input
    case 'ANPR14.1'
        output = 'ANPR14.01';
    case 'ANPR14.2'
        output = 'ANPR14.02';
    case 'ANPR15.3'
        output = 'ANPR15.03';
    case 'ANPR15.2'
        output = 'ANPR15.02';
    case 'ANPR15.1'
        output = 'ANPR15.01';
    case 'ANPR13.1'
        output = 'ANPR13.01';
    case 'ANPR13.2'
        output = 'ANPR13.02';
    case 'ANPR8.35'
        output = 'ANPR08.35';
    case 'ANPR8.36'
        output = 'ANPR08.36';
    case 'ANPR8.37'
        output = 'ANPR08.37';
    case 'ANPR8.38'
        output = 'ANPR08.38';
    case 'ANPR19.1'
        output = 'ANPR19.01';
    case 'ANPR19.2'
        output = 'ANPR19.02';
    case 'ANPR1.1'
        output = 'ANPR1.10';  
    otherwise
        output = input;
end
end