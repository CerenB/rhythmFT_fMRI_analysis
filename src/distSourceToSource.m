function distSourceToSource
% this function dsitributes the 3 different fMRI exp source data into their
% relevant raw folders
% then .tsv _.json files un func will be carried to raw folder


%define task names
subject = 'sub-002';
session = 'ses-001';
taskNames = {'PitchFT','RhythmBlock','RhythmFT'};

% path name
currDir = pwd;

sourceDir = fullfile(fileparts(mfilename('fullpath')), ...
    '..', '..', '..',  'source');
% .nii and .json files
sourceNiiDir = fullfile(sourceDir, subject,session,'nii',...
    subject,session,'func');

% .tsv and .json files
sourceFuncDir = fullfile(sourceDir, subject,session,'func');

% anat folder
sourceAnatDir = fullfile(sourceDir, subject,session,'anat');

% folder names to create
dirsToMakeNii = {subject, session, 'nii'};
dirsToMakeFunc = {subject, session, 'func'};

for iTask = 1:length(taskNames)
    
    %% define folders 
    % define destination folders
    destinationDir = fullfile(fileparts(mfilename('fullpath')), ...
        '..', '..', '..','..',taskNames{iTask},'source');
    
    niiDir = fullfile(destinationDir,subject,session,'nii');
    funcDir = fullfile(destinationDir,subject,session,'func');
    
    % define raw folder
    rawDir = fullfile(destinationDir,'..','raw');

    %% move nii folder content
    %create subject folder witn subfolders if doesn't exit
    if ~exist(fullfile(destinationDir,subject),'dir')
        for idir = 1:length(dirsToMakeNii)
            Thisdir = fullfile(destinationDir,dirsToMakeNii{1:idir});
            mkdir(Thisdir)
        end
    end
    
    
    % choose files
    filePattern = ['*',taskNames{iTask},'*'];
    niiFiles = dir(fullfile(sourceNiiDir, filePattern));
    niiFiles([niiFiles.isdir]) = [];
    
    % move .nii and .json
    for iFile = 1:numel(niiFiles)
        
        %source file
        sourceFile = fullfile(sourceNiiDir, niiFiles(iFile).name);
        % destination file
        destFile = fullfile(niiDir, niiFiles(iFile).name);
        
        movefile(sourceFile, destFile);
    end
    
    
    %% move func folder content to corresponding source
    
    %create func folder if doesn't exit
    if ~exist(funcDir,'dir')
            mkdir(funcDir)
    end
    
    taskFiles = dir(fullfile(sourceFuncDir, filePattern));
    taskFiles([taskFiles.isdir]) = [];
    
    % move .nii and .json
    for iFile = 1:numel(taskFiles)
        
        %source file
        sourceFile = fullfile(sourceFuncDir,taskFiles(iFile).name);
        % destination file
        destFile = fullfile(funcDir,taskFiles(iFile).name);
        
        movefile(sourceFile,destFile);
    end
    
    
    %% use copy from source to raw
    % from source/nii only copy the .nii file with task name
    % then copy all the func folder with removeDateSuffic
    taskFilePattern = ['*',taskNames{iTask},'_run*.nii'];
    taskNiiFiles = dir(fullfile(niiDir, taskFilePattern));
    
    % check if sub folder exit
    if ~exist(fullfile(rawDir,subject),'dir')
        for idir = 1:length(dirsToMakeFunc)
            Thisdir = fullfile(rawDir,dirsToMakeFunc{1:idir});
            mkdir(Thisdir)
        end
    end
    
    % copy .tsv and json source func to raw func
    rawFuncDir = fullfile(rawDir,subject,session,'func');
    copyfile(funcDir,rawFuncDir);
    
    
    % copy .nii only
    for iFile = 1:numel(taskNiiFiles)
        
        %source file
        sourceFile = fullfile(niiDir,taskNiiFiles(iFile).name);
        % destination file
        destFile = fullfile(rawDir,subject,session,...
                            'func',taskNiiFiles(iFile).name);
        
        copyfile(sourceFile,destFile);
    end
    
    %remove suffix
    removeAllDateSuffix(rawDir, subject, session);
    
    % copy anat folder from source to corresponding raw
    rawAnatDir = fullfile(rawDir,subject,session,'anat');
    copyfile(sourceAnatDir,rawAnatDir);
    
    
    % last but not least, delete _stim files from raw folder
    cd(rawFuncDir);
    delete '*_stim*'
    cd(currDir);
end


end


