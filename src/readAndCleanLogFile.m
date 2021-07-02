

loadPath = 'dirty_logfile.tsv'; 

fid = fopen(loadPath,'r'); 

tline = fgetl(fid); 

varNames = strsplit(tline,'\t'); 

nVars = length(varNames); 

data = {}; 
c = 1; 
while ~feof(fid)

    tline = fgetl(fid); 
    tmp = strsplit(tline,'\t'); 
    
    if length(tmp)>nVars
        tmp = tmp(1:nVars); 
    end
    
    if length(tmp)<nVars
        nNANs = nVars-length(tmp); 
        tmp(end+1:end+nNANs) = {'n/a'}; 
    end
    
    data(c,:) = tmp; 
    
    c = c+1; 
end

fclose(fid); 

tbl = cell2table(data); 
tbl.Properties.VariableNames = varNames; 


%% remove all nans 

cleanTbl = removevars(tbl, {'keyName','pressed','target'}); 

nRows = height(cleanTbl); 
nCols = width(cleanTbl); 

rows2del = repmat(false, nRows, 1); 

for iCol=1:nCols
   
    rows2del = rows2del | strcmp(cleanTbl{:,iCol},'n/a'); 
    
end    
    
cleanTbl(rows2del,:) = []; 


writetable(cleanTbl,'clean_logfile', 'Delimiter','\t'); 
movefile('clean_logfile.txt','clean_logfile.tsv'); 



%% replace 'n/a' with actual nan 

cleanTbl = tbl; 

nCols = width(tbl); 

for iCol=1:nCols
   
    idx = strcmp(tbl{:,iCol},'n/a'); 
    
    if any(idx)
        cleanTbl{find(idx),iCol} = {'NaN'}; 
    end
end    

strVarNames = {'trial_type','patternID','segmentCateg','keyName'}; 

varNames = cleanTbl.Properties.VariableNames;   
    
for iVar=1:length(varNames)
    if all(strcmp(varNames{iVar},strVarNames)==false)
       cleanTbl.(varNames{iVar}) = str2double(cleanTbl.(varNames{iVar})); 
    end
end
    

writetable(cleanTbl,'fixed_logfile', 'Delimiter','\t'); 
movefile('fixed_logfile.txt','fixed_logfile.tsv'); 





