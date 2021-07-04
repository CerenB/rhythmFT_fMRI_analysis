function distSourceToSource
  % this function dsitributes the 3 different fMRI exp source data into their
  % relevant raw folders
  % then .tsv _.json files un func will be carried to raw folder

  % add bids repo
  bidsPath = '/Users/battal/Documents/GitHub/CPPLab/CPP_BIDS';
  addpath(genpath(fullfile(bidsPath,'src')));
  addpath(genpath(fullfile(bidsPath,'lib')));
  
  % run getOptions to get cp_spm repo
  
  
  % define task names
  subject = 'sub-013';
  session = 'ses-001';
%   taskNames = {'RhythmBlock'};
  taskNames = {'Nonmetric', 'RhythmBlock', 'RhythmFT'}; %'PitchFT'


  sourceDir = fullfile(fileparts(mfilename('fullpath')), ...
                       '..', '..', '..', 'source');

  basePath = fullfile(sourceDir, subject, session);

  % .nii and .json files
  sourceNiiDir = fullfile(basePath, 'nii', ...
                          subject, session, 'func');
  sourceNiiSes02 = fullfile(sourceDir, subject, 'ses-002', 'nii', ...
                            subject, session, 'func');

  % .tsv and .json files
  sourceFuncDir = fullfile(basePath, 'func');

  % anat folder
  sourceAnatDir = fullfile(basePath, 'anat');

  % folder names to create
  dirsToMakeNii = {subject, session, 'nii'};
  dirsToMakeFunc = {subject, session, 'func'};

  %% cut&paste files to start with

  % move nii files of ses002 into ses001
  ses002NiiFiles = dir(sourceNiiSes02);
  ses002NiiFiles([ses002NiiFiles.isdir]) = [];

  % move .nii and .json
  for iFile = 1:numel(ses002NiiFiles)

    % source file
    ses002NiiFile = fullfile(sourceNiiSes02, ses002NiiFiles(iFile).name);
    % destination file
    destFile = fullfile(sourceNiiDir, ses002NiiFiles(iFile).name);
    % move
    movefile(ses002NiiFile, destFile);
  end

  % move anat folder out of ses-001/nii/sub00x/ses001/anat to ses-001/nii/
  groundZeroAnat = fullfile(sourceNiiDir, '..', 'anat');
  movefile(groundZeroAnat, basePath);

  %% start distributing files
  for iTask = 1:length(taskNames)

    % define destination folders
    destinationDir = fullfile(fileparts(mfilename('fullpath')), ...
                              '..', '..', '..', '..', taskNames{iTask}, ...
                              'source');

    niiDir = fullfile(destinationDir, subject, session, 'nii');
    funcDir = fullfile(destinationDir, subject, session, 'func');

    % define raw folder
    rawDir = fullfile(destinationDir, '..', 'raw');

    %% move nii folder content to source
    % create subject folder witn subfolders if doesn't exit
    if ~exist(fullfile(destinationDir, subject), 'dir')
      for idir = 1:length(dirsToMakeNii)
        Thisdir = fullfile(destinationDir, dirsToMakeNii{1:idir});
        mkdir(Thisdir);
      end
    end

    % choose files
    filePattern = ['*', taskNames{iTask}, '*'];
    niiFiles = dir(fullfile(sourceNiiDir, filePattern));
    niiFiles([niiFiles.isdir]) = [];

    % move .nii and .json
    for iFile = 1:numel(niiFiles)

      % source file
      sourceFile = fullfile(sourceNiiDir, niiFiles(iFile).name);
      % destination file
      destFile = fullfile(niiDir, niiFiles(iFile).name);

      movefile(sourceFile, destFile);
    end

    %% move func folder content to corresponding source
    if iTask ~= 3
      % create func folder if doesn't exit
      if ~exist(funcDir, 'dir')
        mkdir(funcDir);
      end

      taskFiles = dir(fullfile(sourceFuncDir, filePattern));
      taskFiles([taskFiles.isdir]) = [];

      % move .nii and .json
      for iFile = 1:numel(taskFiles)

        % source file
        sourceFile = fullfile(sourceFuncDir, taskFiles(iFile).name);
        % destination file
        destFile = fullfile(funcDir, taskFiles(iFile).name);

        movefile(sourceFile, destFile);
      end
    end

    %% use copy from source to raw
    % from source/nii only copy the .nii file with task name
    % then copy all the func folder with removeDateSuffic
    taskFilePattern = ['*', taskNames{iTask}, '_run*.nii*'];
    taskNiiFiles = dir(fullfile(niiDir, taskFilePattern));

    % check if sub folder exit
    if ~exist(fullfile(rawDir, subject), 'dir')
      for idir = 1:length(dirsToMakeFunc)
        Thisdir = fullfile(rawDir, dirsToMakeFunc{1:idir});
        mkdir(Thisdir);
      end
    end

    % copy .tsv and json source func to raw func
    rawFuncDir = fullfile(rawDir, subject, session, 'func');
    copyfile(funcDir, rawFuncDir);

    % copy .nii only
    for iFile = 1:numel(taskNiiFiles)

      % source file
      sourceFile = fullfile(niiDir, taskNiiFiles(iFile).name);
      % destination file
      destFile = fullfile(rawDir, subject, session, ...
                          'func', taskNiiFiles(iFile).name);

      copyfile(sourceFile, destFile);
    end

    % remove suffix
    removeAllDateSuffix(rawDir, subject, session);

    % copy anat folder from source to corresponding raw
    rawAnatDir = fullfile(rawDir, subject, session, 'anat');
    copyfile(sourceAnatDir, rawAnatDir);

    % last but not least, delete _stim files from raw folder - till sub012
%     cd(rawFuncDir);
%     delete '*_stim*';
%     cd(currDir);
  end

end
