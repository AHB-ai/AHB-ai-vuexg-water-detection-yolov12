function dateNum = convertDate(dateStr)
t0 = 734139;
dateNum = (datenum(dateStr, 'dd-mm-yyyy')-t0)*24*3600;
end