
for i=1:length(list)
    idx = list(i);
    convoy = retrieveConvoy(rankMat, idx, convoyMap);
    outputConvoyCSV(iopath, convoy);
end