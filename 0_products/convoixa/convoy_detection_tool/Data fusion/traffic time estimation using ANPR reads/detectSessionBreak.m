function session_break = detectSessionBreak(data,scale,perct)
if ~exist('data', 'var')
    session_break = 0;
else
    [len,~] = size(data);
    if len>100
        [locs_peak, bins, myFit, index] = analysePeak(data, scale);
        if length(locs_peak)==1
            [counts, ~] = histogram(data, scale);            
            len = length(data);
            cutoffCounts = len*perct;   
            j=1;
            tempCount = 0;
            while tempCount<cutoffCounts && j<scale
                tempCount = tempCount + counts(j);
                j=j+1;
            end
            session_break = bins(j);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            X = pdf(myFit,index);
            Y = diff(X);
            [~, locs_tmp] = findpeaks(Y);
            sample = bins(locs_tmp);
            test = X(locs_tmp);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        elseif length(locs_peak)==2
            data_pdf = pdf(myFit, index);
            dataInv = 1.01*max(data_pdf)-data_pdf;
            [~, locs_bottom] = findpeaks(dataInv,'MinPeakHeight',max(dataInv)/7);
            idx = locs_bottom(1);
            session_break = bins(idx);
        end
    else
        session_break = 0;
    end
end
end