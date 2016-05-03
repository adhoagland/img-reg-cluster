% Created by: Bernal Jimenez
% 03/17/2016

function [] = parallel_demon_reg_test(nNmjs,nFrames,batchNum,batchFile,batchDir)

    load(batchFile)
    load([batchDir,'/affineTform.mat'])
    
    demonized_mov = cell(nNmjs,1);
    disp_fields = cell(nNmjs,1);

    [localOptimizer, metric] = imregconfig('monomodal');
    [globalOptimizer,~] = imregconfig('monomodal');
    globalOptimizer.MaximumStepLength = 0.001;
    localOptimizer.MinimumStepLength = 1e-4;
    globalOptimizer.MinimumStepLength = 1e-4;
    localOptimizer.RelaxationFactor = 0.8;
    globalOptimizer.RelaxationFactor = 0.8;
    
    try
	gpuDevice
	gpuEnabled = true
    catch
	gpuEnabled = false
    end
    
    for nmjNum = 1:nNmjs   
	nmj = batchNmjs{nmjNum};

	batchTform = transformList{nmjNum}{batchNum};

	refFrame = refFrames{nmjNum};
	refFrameLocal = max(nmj,[],3);

	disp(['Starting Demon NMJ #: ',num2str(nmjNum)])

	demonDispFields = cell(nFrames,1);
	demon=zeros(size(refFrame,1),size(refFrame,2),nFrames,'uint16');
	
	if gpuEnabled
	demon = gpuArray(demon);
	end

	tic
	for qq = 1:nFrames
	    movingFrame = nmj(:,:,qq);

	    if gpuEnabled
	    refFrame = gather(refFrame);
	    refFrameLocal = gather(refFrameLocal);
    	    end

	    %Demons Enhanced Contrast
	    enhancedMovingFrame=enhanceContrastDemon(movingFrame);
	    refFrame = enhanceContrastDemon(refFrame);
	    refFrameLocal = enhanceContrastDemon(refFrameLocal);
	    
	    %Apply Affine Transformation
	    %localAffineTransform = imregtform(enhancedMovingFrame,refFrameLocal,'affine',localOptimizer,metric);
	    
	    try
	    globalAffineTransform= imregtform(enhancedMovingFrame,refFrame,'affine',globalOptimizer,metric,'InitialTransformation',batchTform); 
	    catch
	    optimizer.MaximumStepLength = 0.00005
	    globalAffineTransform= imregtform(enhancedMovingFrame,refFrame,'affine',globalOptimizer,metric,'InitialTransformation',batchTform); 
	    end
	    
	    Rfixed = imref2d(size(nmj(:,:,1)));
	    movingReg = imwarp(movingFrame,globalAffineTransform,'OutputView',Rfixed);
	    enhancedMovingFrame = imwarp(enhancedMovingFrame,globalAffineTransform,'OutputView',Rfixed);

	    %Pass Arrays to GPU
	    if gpuEnabled
	    refFrame = gpuArray(refFrame);
	    refFrameLocal = gpuArray(refFrameLocal);
	    enhancedMovingReg = gpuArray(enhancedMovingFrame);
	    end

	    %Apply Demons Transformation
	    %[localDispField,enhancedMovingReg] = imregdemons(enhancedMovingReg,refFrameLocal,[100,50,1,1],'PyramidLevels',4);
	    %[globalDispField,enhancedMovingReg] = imregdemons(enhancedMovingReg,refFrame,[300,100,1,1],'PyramidLevels',4);		    
	    %dispField = localDispField + globalDispField;
	    
	    if gpuEnabled
	    %dispField = gather(globalDispField);
    	    end
	    
	    %movingReg = imwarp(movingReg,dispField);
	    %demonDispFields{qq,1} = dFieldGPU; 


	    demon(:,:,qq)= movingReg;

	    disp(['NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   
  
	end
	demonTime = toc

	if gpuEnabled
	demon = gather(demon);
	end

	demonized_mov{nmjNum,1}=demon;
	disp_fields{nmjNum,1}=demonDispFields; 
	
	demon_variable = genvarname(['demonized_mov',num2str(batchNum)])
	eval([demon_variable '= demonized_mov'])
	
	save(batchFile,['demonized_mov',num2str(batchNum)],'disp_fields','demonTime','-append')	
    end
