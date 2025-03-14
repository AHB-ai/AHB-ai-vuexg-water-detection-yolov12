% iopath = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Convoy Analysis\convoy algorithm\output data\convoy_output_hard_threshold_CSV'
function outputConvoyCSV(iopath, convoy)
if ~exist(iopath, 'file')
    mkdir(iopath);
end
ct=1;
if ~isempty(convoy)
    reads = convoy{1};
    [height, ~] = size(reads);
    vrm1 = reads{1,1};
    vrm2 = reads{2,1};
    for n=1:height
        pair_write(ct,:) = reads(n,:);
        ct=ct+1;
    end
end
filename = [vrm1 ' ' vrm2 '.csv'];
new_path = [iopath '\' filename];
simplemat2csv(pair_write, new_path);
clear pair_write;
clear ct;
end