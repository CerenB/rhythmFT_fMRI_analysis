function organiseTsvFile
  % it is a mini function to reorganise the _events.tsv files
  % in order to make them bids-compliant.

  % first, it omits the empty column
  % then looks at empty cells and inserts

  % option1 = deletes the unnecessary rows, option2 = inserts NaNs
  cleaningOption = 1;

  % add bids repo
  bidsPath = '/Users/battal/Documents/GitHub/CPPLab/CPP_BIDS';
  addpath(genpath(fullfile(bidsPath, 'src')));
  addpath(genpath(fullfile(bidsPath, 'lib')));

  % define task names
  subject = 'sub-023';
  session = 'ses-001';

  mainDir = '/Users/battal/Cerens_files/fMRI/Processed/RhythmCateg/';

  % define the task names
  taskNames = {'RhythmFT', 'RhythmBlock', 'Nonmetric'}; % 'PitchFT'

  for iTask = 1:length(taskNames)

    % raw and source data path
    rawDir = fullfile(mainDir, taskNames{iTask}, 'raw');
    sourceDir =  fullfile(mainDir, taskNames{iTask}, 'source');

    % tsv file location
    rawFuncDir = fullfile(rawDir, subject, session, 'func');
    sourceFuncDir = fullfile(sourceDir, subject, session, 'func');

    % create a pattern to look for in the folder
    FilePattern = ['*', taskNames{iTask}, '*_events.tsv'];
    % find all the .tsv files
    tsvFiles = dir(fullfile(rawFuncDir, FilePattern));

    % read, modify and save tsv  in a for loop
    for iFile = 1:length(tsvFiles)

      tsvFileName = tsvFiles(iFile).name;
      tsvFileFolder = tsvFiles(iFile).folder;

      % check if there's empty column
      % check is there's empty cell

      % read tsv line-by-line, check empty column, either insert n/a
      % or delete unnecessary rows
      tsv = fullfile(tsvFileFolder, tsvFileName);
      [output, outputTag] = readAndCleanLogFile(tsv, cleaningOption);

      % create output file name with tag for source
      outputFileName = strrep(tsvFileName, '.tsv', outputTag);

      % save as tsv in source with tag
      bids.util.tsvwrite(fullfile(sourceFuncDir, outputFileName), output);

      % save as tsv in raw
      bids.util.tsvwrite(fullfile(tsvFileFolder, tsvFileName), output);

    end

  end

end
