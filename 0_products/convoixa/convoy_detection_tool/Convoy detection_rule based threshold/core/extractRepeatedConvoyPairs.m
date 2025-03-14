%% Repeated Convoy Analysis
%  This script is to extract repeated 2-vehicle convoy.

%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>input</b></td><td>this is processd convoy results.</td></tr>
% </table>
% </html>
%
% * OUTPUT:
%
% <html>
% <table border=2>
% <tr><td><b>output</b></td><td>the repeated 2-vehicle convoy results.</td></tr>
% </table>
% </html>
%
%% Code
function output = extractRepeatedConvoyPairs(input)
output = containers.Map('KeyType','char','ValueType','any');
keySet = keys(input);
for i=1:length(keySet)
    key = keySet{i};
    val = input(key);
    num_convoys = length(val);
    if num_convoys>1
        data.length = num_convoys;
        data.convoys = val;
        output(key) = data;
    end
end
end

%% Navigation
% * Back to 
% <..\html\main.html Convoy Analysis Tool>
% * Go to
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 


%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%%