%Cluster Specific Version of Registration Function

function [] = postSelectMovReg(moviesToRegisterDir,outputDir,fileName,roiFile,cziFile,skipTrack,skipAffine)

firstTime = cputime

%Change the Number of Frames for testing
%nFrames=1000
%save(roiFile,'nFrames','-append')

load(roiFile);

%Makes output folder
%Parallel Filename
fileName = [fileName,'_Parallel']
movOutputDir = fullfile(outputDir,fileName);
mkdir(movOutputDir);
copyfile(roiFile,movOutputDir);

%%% Tracks and Crops NMJs from Movies
if skipTrack
    disp('Skipping NMJ Tracking')
else
    % Loads the reader using bftools       
    reader = bfGetReader(cziFile);
    
    tic
    % Calculates tracking coordinates for all nmjs 
    trackingCoordinates = find_tracking_coor(reader,regPropsStore,maxFrame,maxFrameNum,nFrames,nNmjs);
    trackingTime = toc
    
    tic
    % Saves smoothed movies for all nmjs in seperate folders
    save_smooth_coors(reader,trackingCoordinates,nFrames,maxFrameNum,movOutputDir,fileName,nNmjs);
    savingTrackTime = toc
    save([movOutputDir '/Tracking Timing Log'],'trackingTime','savingTrackTime')
end
    
% Gets movie filenames    
trackedFileNames = dir([movOutputDir '/track/*register*.mat']) %Makes structure object

% Loads variables
load(roiFile);
numNodes = 20
% Loads affined nmj movies into array
tic 
takeFromTracked = true
nmjMovie = load_nmjs(nNmjs,movOutputDir, trackedFileNames,takeFromTracked);
loadTime = toc

%Splits up movie into batches for parallel processing
tic
batchDir = save_batches(nmjMovie,movOutputDir,numNodes,nNmjs,nFrames,maxFrameNum) 
saveBatchTime = toc

%Gets Initial Transformation Samples Sequentially
sampleFactor = 2
tic
numExamples = numNodes/sampleFactor
transformList = find_affine_examples(numExamples,nFrames,maxFrameNum,nNmjs,nmjMovie)
save([batchDir,'/affineTform'],'transformList')
listTime = toc

tic
%Calculates affine transformation in parallel
run_affine_bash(batchDir,nNmjs,numNodes,sampleFactor)

%Joins affine transformation and smooths it out
[affineTform] = join_affine_mov(batchDir,nNmjs,movOutputDir,numNodes)
computeAffineTform = toc

%Split the smoothed affine transform and save it to the batch files
tic
batchDir = save_affine_batches(affineTform,movOutputDir,numNodes,nNmjs,nFrames,maxFrameNum) 
saveBatchTime = toc

%Applies affine and demons transform in parallel 
tic
run_demons_bash(batchDir,nNmjs,numNodes,sampleFactor)
join_demons_mov(batchDir,nNmjs,movOutputDir,numNodes) 
applyTformandJoinTime = toc

totalTime = cputime - firstTime
disp('Success')
