function organiseTsvFile
% it is a mini function to reorganise the _events.tsv files 
% in order to make them bids-compliant.

% first, it omits the empty column
% then looks at empty cells and inserts 

  deleteSuffix = 0;


 % add bids repo
  bidsPath = '/Users/battal/Documents/GitHub/CPPLab/CPP_BIDS';
  addpath(genpath(fullfile(bidsPath,'src')));
  addpath(genpath(fullfile(bidsPath,'lib')));
  
  % raw data path
  rawDir = '/Users/battal/Cerens_files/fMRI/Processed/RhythmCateg/RhythmFT/raw';

%   rawDir = '/Users/battal/Cerens_files/fMRI/Processed/MT_TMS/raw';
  
  % define task names
  subject = 'sub-012';
  session = 'ses-001';
  
  
  % define the task names
  taskNames = {'RhythmFT'}; %'PitchFT' 'Nonmetric', 'RhythmBlock', 
%   taskNames = {'visualLocalizer', 'auditoryLocalizer'};
  
  % tsv file location
  rawFuncDir = fullfile(rawDir, subject, session, 'func');
  
  
  % remove the suffix
  if deleteSuffix
    removeAllDateSuffix(rawDir, subject, session);
  end
  
  % Create output file name
  outputTag = '_touched.tsv';
    
  
  for iTask = 1:length(taskNames)
      
      % create a pattern to look for in the folder
      FilePattern = ['*', taskNames{iTask}, '*_events.tsv'];
      % find all the .tsv files
      tsvFiles = dir(fullfile(rawFuncDir, FilePattern));
      
      % read, modify and save tsv  in a for loop
      for iFile = 1:length(tsvFiles)
          
          tsvFileName = tsvFiles(iFile).name;
          tsvFileFolder = tsvFiles(iFile).folder;
          
          % create output file name
          outputFileName = strrep(tsvFileName, '.tsv', outputTag);

          % read the tsv file
          output = bids.util.tsvread(fullfile(tsvFileFolder,tsvFileName));
          
          % check if there's empty column
        [data, header, raw]  = tsvread(fullfile(tsvFileFolder,tsvFileName));
          % check is there's empty cell
      
          % if yes, insert n/a
      
          % convert to tsv structure
          output = convertStruct(output);
          
          % save as tsv
          bids.util.tsvwrite(fullfile(tsvFileFolder,outputFileName), output);

      end
      
  end

end


function structure = convertStruct(structure)
    % changes the structure
    % from struct.field(i,1) to struct(i,1).field(1)

    fieldsList = fieldnames(structure);
    tmp = struct();

    for iField = 1:numel(fieldsList)
        for i = 1:numel(structure.(fieldsList{iField}))
            tmp(i, 1).(fieldsList{iField}) =  structure.(fieldsList{iField})(i, 1);
        end
    end

    structure = tmp;

end