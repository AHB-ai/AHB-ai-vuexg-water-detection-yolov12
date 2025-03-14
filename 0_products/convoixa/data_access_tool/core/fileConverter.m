%% File Converter
% This script is used to convert xlsx file to a csv file according to the
% data descriptor, and intermediate data formatt descriptor. The following
% explaines: 
%
% * 1 = "VRM"
% * 2 = "CameraName"
% * 3 = "hh:mm:ss"
% * 4 = "dd/mm/yyyy hh:mm:ss"
% * 10 = "Degree North_West"
% * 11 = "Degree North"
% * 12 = "Degree West"
% * 20 = "OS Easting_Northing"
% * 21 = "OS Easting"
% * 22 = "OS Northing"
% * 5 = "Make"
% * 6 = "Model"
% * 7 = "Color"
% * 8 = "Tax"
% These numbers are defined in Apache POI java file, and they should be used together with intermediate data descriptor.

%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>dsfile</b></td><td>this is the data descriptor file (xml file)</td></tr>
% <tr><td><b>inputfile</b></td><td>this is the xlsx file contains raw ANPR data</td></tr>
% <tr><td><b>intermediate_format</b></td><td>this is the intermediate data format descriptor</td></tr>
% <tr><td><b>interfile</b></td><td>the intermediate file that describes the format of converted data, which provide information of how the output data should be consturcted.</td></tr>
% </table>
% </html>
%
% * OUTPUT
% 
% <html>
% <table border=2>
% <tr><td><b>Ouput</b></td><td>a converted csv file</td></tr>
% </table>
% </html>
%
%% Code

function fileConverter(datasource, inputfile, intermediate_format, outputfile, date)

import java.util.ArrayList;
bofName = datasource{1};
bofSource = datasource{2};
typeStatus = datasource{3};
sheetStatus = datasource{4};
vrmPos = datasource{5};
timePos = datasource{6};
camPos = datasource{7};
geoFormat = datasource{8};
coordsFormat = datasource{9};
locFormat = datasource{10};
locPos = datasource{11};
headerStatus = datasource{12};
timeFormat = datasource{13};
nameFormat = datasource{14};
makePos = datasource{15};
modelPos = datasource{16};
colorPos = datasource{17};
taxPos = datasource{18};

if exist(outputfile, 'file')
    fprintf('--CSV file exists, skipped!\n');
else
    fprintf('--Creating CSV file...\n');
    
    if strcmp(bofName,'North Gate')
        switch typeStatus
            case 'xlsx'
                switch bofSource
                    case 'BOF'
                            column_list = java.util.ArrayList();
                            column_list.add(int32(vrmPos));
                            column_list.add(int32(timePos));
                            column_list.add(int32(camPos));
                                                                                         
                            %%
                            % VRM and Camera name are identified as the key information 
                            vrm = 1;
                            cam = 2;
                            if strcmp(timeFormat, 'dd/mm/yyyy hh:mm:ss')
                                time = 4;
                            end
                            if strcmp(timeFormat, 'hh:mm:ss')
                                time = 3;
                            end
                            format_list = java.util.ArrayList();
                            format_list.add(int32(vrm));
                            format_list.add(int32(time));
                            format_list.add(int32(cam));
                            
                            %$ 
                            % Identify which column contains the specific
                            % category of information for new converted
                            % file, this will be used together with
                            % intermediate format descriptor to format the
                            % output intermediate data file
                            tempArray = [vrmPos, timePos, camPos];
                            sortArray = sort(tempArray);                            
                            for i=1:length(sortArray)
                                if sortArray(i)==vrmPos
                                    vrmIdx = i;
                                end
                                if sortArray(i)==timePos
                                    timeIdx = i;
                                end
                                if sortArray(i)==camPos
                                    camIdx = i;
                                end
                            end
                            locIdx = 4;
                            if length(locPos)>1
                                column_list.add(int32(locPos{1}));
                                column_list.add(int32(locPos{2}));
                                if strcmp(geoFormat, 'Degree')
                                    degree_north = 11;
                                    degree_west = 12;
                                    format_list.add(int32(degree_north));
                                    format_list.add(int32(degree_west));
                                end
                                if strcmp(geoFormat, 'OS')
                                    easting = 21;
                                    northing = 22;
                                    format_list.add(int32(easting));
                                    format_list.add(int32(northing));
                                end
                            end
                            if length(locPos)==1                                
                                column_list.add(int32(locPos));
                                if strcmp(geoFormat, 'Degree')
                                    degree = 10;
                                    format_list.add(int32(degree));
                                end
                                if strcmp(geoFormat, 'OS')
                                    os_coords = 20;
                                    format_list.add(int32(os_coords));                                    
                                end
                            end
                            %%
                            % This is the core function to convert raw
                            % data, which calls a external java function
                            % See:
                            % <..\html\xls2csv.html File Converter Java>
                            xlsx2csv(inputfile, outputfile, column_list, format_list, date);                            
                    case 'Data Warehouse'
                            column_list = java.util.ArrayList();
                            column_list.add(int32(vrmPos));
                            column_list.add(int32(timePos));
                            column_list.add(int32(camPos));

                            %%
                            % VRM and Camera name are identified as the key
                            % information 
                            vrm = 1;
                            cam = 2;
                            if strcmp(timeFormat, 'dd/mm/yyyy hh:mm:ss')
                                time = 4;
                            end
                            if strcmp(timeFormat, 'hh:mm:ss')
                                time = 3;
                            end
                            format_list = java.util.ArrayList();
                            format_list.add(int32(vrm));
                            format_list.add(int32(time));
                            format_list.add(int32(cam));
                            
                            tempArray = [vrmPos, timePos, camPos];
                            sortArray = sort(tempArray);                            
                            
                            for i=1:length(sortArray)
                                if sortArray(i)==vrmPos
                                    vrmIdx = i;
                                end
                                if sortArray(i)==timePos
                                    timeIdx = i;
                                end
                                if sortArray(i)==camPos
                                    camIdx = i;
                                end
                            end
                            locIdx = 4;
                            
                            if length(locPos)>1
                                column_list.add(int32(locPos{1}));
                                column_list.add(int32(locPos{2}));
                                if strcmp(geoFormat, 'Degree')
                                    degree_north = 11;
                                    degree_west = 12;
                                    format_list.add(int32(degree_north));
                                    format_list.add(int32(degree_west));
                                end
                                if strcmp(geoFormat, 'OS')
                                    easting = 21;
                                    northing = 22;
                                    format_list.add(int32(easting));
                                    format_list.add(int32(northing));
                                end
                            end
                            if length(locPos)==1                                
                                column_list.add(int32(locPos));
                                if strcmp(geoFormat, 'Degree')
                                    degree = 10;
                                    format_list.add(int32(degree));
                                end
                                if strcmp(geoFormat, 'OS')
                                    os_coords = 20;
                                    format_list.add(int32(os_coords));                                    
                                end
                            end
                            column_list.add(int32(makePos));
                            column_list.add(int32(modelPos));
                            column_list.add(int32(colorPos));
                            column_list.add(int32(taxPos));
                            make = 5;
                            model = 6;
                            color = 7;
                            tax = 8;
                            format_list.add(int32(make));
                            format_list.add(int32(model));
                            format_list.add(int32(color));
                            format_list.add(int32(tax));
                            %%
                            % This is the core function to convert raw
                            % data, which calls a external java function
                            % See:
                            % <..\html\xls2csv.html File Converter Java>
                            xlsx2csv(inputfile, outputfile, column_list, format_list, date);
                end
            case 'xls'
            case 'csv'
        end
    end

    % Here need to be extended once the system requirements for CLEARTONE
    % and ESSA system are confirmed.
    %if strcmp(bofName,'CLEARTONE')
    %end
    
    %if strcmp(bofName,'ESSA')
    %end

    %%
    % Determine if the original file has header or not
    if strcmp(headerStatus, 'true')
        headerIdx = 2;
        interFormat(headerIdx, vrmIdx, timeIdx, camIdx, locIdx, intermediate_format, outputfile);
    end
    %%
    % Determine if the original file has header or not
    if strcmp(headerStatus, 'false')
        headerIdx = 1;
        interFormat(headerIdx, vrmIdx, timeIdx, camIdx, locIdx, intermediate_format, outputfile);
    end
end
%% Linked Functions
% * See:
% <..\html\xls2csv.html File Converter Java>

%% Navigation
% * Go to 
% <..\html\main.html main> 
% * Go to 
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 

%% Author
%  Haiyue Yuan, 02.2016, Depatment of Computer Science, University of Surrey

