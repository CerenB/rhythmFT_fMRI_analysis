function logfileSourceToRaw
  % this function ONLY copy-paste-remove date suffix from event.tsv files
  % then .tsv _.json files un func will be carried to raw folder

  % define task names
  subject = 'sub-001';
  session = 'ses-001';
  taskNames = {'RhythmBlock'};

  %% use copy from source to raw

  for iTask = 1:length(taskNames)

    % define destination folders
    destinationDir = fullfile(fileparts(mfilename('fullpath')), ...
                              '..', '..', '..', '..', taskNames{iTask}, 'source');

    funcDir = fullfile(destinationDir, subject, session, 'func');

    % define raw folder
    rawDir = fullfile(destinationDir, '..', 'raw');

    % tcopy all the func source folder (.tsv and .json)  to raw func
    rawFuncDir = fullfile(rawDir, subject, session, 'func');
    copyfile(funcDir, rawFuncDir);

    % remove suffix by cpp-bids function
    removeAllDateSuffix(rawDir, subject, session);

    % last but not least, delete _stim files from raw folder
    cd(rawFuncDir);
    delete '*_stim*';
    cd(currDir);

    % actually you may want to carry raw folder .tsv files into derivatives
    % to re-tun GLM etc...

  end

end
