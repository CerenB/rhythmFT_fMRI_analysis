clear;
clc;

pth = fullfile(fileparts(mfilename('fullpath')), '..');
addpath(pth);

% add FFT analysis lib
addpath(genpath(fullfile(pth, 'lib', 'FFT_fMRI_analysis')));

%% set paths
% set spm
[~, hostname] = system('hostname');
warning('off');

if strcmp(deblank(hostname), 'tux')
  addpath(genpath('/home/tomo/Documents/MATLAB/spm12'));
elseif strcmp(deblank(hostname), 'mac-114-168.local')
  warning('off');
  addpath(genpath('/Users/battal/Documents/MATLAB/spm12'));
end

% add cpp repo
run ../lib/CPP_BIDS_SPM_pipeline/initCppSpm.m;

% we add all the subfunctions that are in the sub directories
opt = getOptionRhythmFT();

%% Run batches
reportBIDS(opt);
bidsCopyRawFolder(opt, 1);
%
% % In case you just want to run segmentation and skull stripping
% % Skull stripping is also included in 'bidsSpatialPrepro'
%   bidsSegmentSkullStrip(opt);
%
bidsSTC(opt);
% %
bidsSpatialPrepro(opt);
%
% % Quality control
% anatomicalQA(opt);
% bidsResliceTpmToFunc(opt);
% functionalQA(opt);

% smoothing
FWHM = 6;
bidsSmoothing(FWHM, opt);

FWHM = 2;
bidsSmoothing(FWHM, opt);

%%
opt.anatMask = 0;
opt.maskType = 'whole-brain';
[opt.funcMask, opt.maskType] = getMaskFile(opt);

% want to save each run FFT results
opt.saveEachRun = 0;
opt.nStepsPerPeriod = 4;

for iSmooth = 2 % 0 2 3 or 6mm smoothing

  opt.FWHM = iSmooth;

  calculateSNR(opt);
end

%%
% group analysis - for now only in MNI
% individual space would require fsaverage
opt.nStepsPerPeriod = 4;
opt.FWHM = 2; % 0 2 6
opt = groupAverageSNR(opt);

%% visualisation prep
opt.nStepsPerPeriod = 4;
opt.FWHM = 6;
pvalue = 0.005; % 1e-6; 1e-3
opt.save.zmap = true;
groupLevelzMapThreshold(opt, pvalue)
