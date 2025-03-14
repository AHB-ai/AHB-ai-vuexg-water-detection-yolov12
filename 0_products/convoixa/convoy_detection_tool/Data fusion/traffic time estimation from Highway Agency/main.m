
dir_path ='C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\Journey';
date = '10-03-2015';
time = '01:30:30';
ANPR1 = 'ANPR1.10';
ANPR2 = 'ANPR5.25';
output_dir = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\traffic time estimation from Highway Agency\output';
load('anprMap.mat');
[min_dist,journeyValue,journeyDir,travelTime,freeFlowTravelTime,expectedTravelTime] = getPublicTravelTime(dir_path, date, time, anprMap, ANPR1, ANPR2, output_dir);
