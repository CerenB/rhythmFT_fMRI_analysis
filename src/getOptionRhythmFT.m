% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function opt = getOptionRhythmFT()
  % opt = getOption()
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.

  if nargin < 1
    opt = [];
  end

  % group of subjects to analyze
  opt.groups = {''};
  % suject to run in each group
  opt.subjects = {'001', '002', '003', '004', '005', ...
                '006','007','008','009', '010', '011'}; 
                % '001', '002', '003', '004', '005', '006','007','008', 

  % Uncomment the lines below to run preprocessing
  % - don't use realign and unwarp
  opt.realign.useUnwarp = true;

  % we stay in native space (that of the T1)
  % - in "native" space: don't do normalization
  opt.space = 'MNI'; % 'individual', 'MNI'

  % The directory where the data are located
  opt.dataDir = fullfile(fileparts(mfilename('fullpath')), ...
                         '..', '..', '..',  'raw');
  opt.derivativesDir = fullfile(opt.dataDir, '..');

  % task to analyze
  opt.taskName = 'RhythmFT';

  
   [~, hostname] = system('hostname');
  if strcmp(deblank(hostname), 'tux')
    opt.dataDir = fullfile('/datadisk/data/RhythmCateg-fMRI/RhythmBlock'); 
    opt.derivativesDir = fullfile( ...
                                  '/datadisk/data/RhythmCateg-fMRI/RhythmFT', ...
                                  'cpp_spm');
  elseif strcmp(deblank(hostname), 'mac-114-168.local')
    % The directory where the data are located
    opt.dataDir = fullfile(fileparts(mfilename('fullpath')), ...
                           '..', '..', '..', 'data', 'raw');
    opt.derivativesDir = fullfile(opt.dataDir, '..', ...
                                  'derivatives', 'cpp_spm');
                              
    opt.roiDir = fullfile(fileparts(mfilename('fullpath')),  ...
                           '..', '..', '..','..', 'RhythmCateg_ROI');
  end
  
  
  % Suffix output directory for the saved jobs
  opt.jobsDir = fullfile( ...
                         opt.dataDir, '..', 'derivatives', ...
                         'cpp_spm', 'JOBS', opt.taskName);
                     
  % to add the hrf temporal derivative = [1 0]
  % to add the hrf temporal and dispersion derivative = [1 1]
  % opt.model.hrfDerivatives = [0 0];

  opt.sliceOrder = [0, 0.9051, 0.0603, 0.9655, 0.1206, 1.0258, 0.181, ...
                    1.0862, 0.2413, 1.1465, 0.3017, 1.2069, 0.362, ...
                    1.2672, 0.4224, 1.3275, 0.4827, 1.3879, 0.5431, ...
                    1.4482, 0.6034, 1.5086, 0.6638, 1.5689, 0.7241, ...
                    1.6293, 0.7844, 1.6896, 0.8448, 0, 0.9051, 0.0603, ...
                    0.9655, 0.1206, 1.0258, 0.181, 1.0862, 0.2413, ...
                    1.1465, 0.3017, 1.2069, 0.362, 1.2672, 0.4224, ...
                    1.3275, 0.4827, 1.3879, 0.5431, 1.4482, 0.6034, ...
                    1.5086, 0.6638, 1.5689, 0.7241, 1.6293, 0.7844, ...
                    1.6896, 0.8448];

  % opt.sliceOrder = [];
  opt.STC_referenceSlice = [];

  % Options for normalize
  % Voxel dimensions for resampling at normalization of functional data or leave empty [ ].
  opt.funcVoxelDims = [2.6 2.6 2.6];
  
  opt.parallelize.do = true;
  opt.parallelize.nbWorkers = 4;
  opt.parallelize.killOnExit = true;  

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
