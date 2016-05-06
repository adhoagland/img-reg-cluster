% Created by: Bernal Jimenez
% 03/17/2016

function [] = parallel_demon_reg_test(batchNum,batchFile,batchDir,sampleFactor)
    %Loading saved batch files
    load(batchFile)
    
    nNmjs = size(batchNmjs,1)
    demonized_mov = cell(nNmjs,1);
    disp_fields = cell(nNmjs,1);

    try
	gpuDevice
	gpuEnabled = true
    catch
	gpuEnabled = false
    end
    
    for nmjNum = 1:nNmjs   
	nmj = batchNmjs{nmjNum};
	affineTform = batchAffine{nmjNum}
	nFrames = size(nmj,3)
	
	refFrame = refFrames{nmjNum};

	disp(['Starting NMJ #: ',num2str(nmjNum)])

	demonDispFields = cell(nFrames,1);
	demon=zeros(size(refFrame,1),size(refFrame,2),nFrames,'uint16');
	
	if gpuEnabled
	demon = gpuArray(demon);
	end
	
	tic

	refFrame = enhanceContrastDemon(refFrame);

	if gpuEnabled
	    refFrame = gpuArray(refFrame);
    	end

	Rfixed = imref2d(size(nmj(:,:,1)));
	
	for qq = 1:nFrames	
	    disp(['Applying Transformations ',num2str(qq)])

	    movingFrame = nmj(:,:,qq);
	    movingFrame = imwarp(movingFrame,affineTform{qq},'OutputView',Rfixed);
	    %Demon Enhancements
	    enhancedMovingFrame = enhanceContrastDemon(movingFrame);
	    
	    %Pass Arrays to GPU
	    if gpuEnabled
	    enhancedMovingFrame = gpuArray(enhancedMovingFrame);
	    end

	    %Apply Demons Transformation
	    [dispField,~] = imregdemons(enhancedMovingFrame,refFrame,[400,200,100],'PyramidLevels',3,'DisplayWaitBar',false);		    
	    if gpuEnabled
	    dispField = gather(dispField);
    	    end
	    
	    movingReg = imwarp(movingFrame,dispField);
	    demonDispFields{qq,1} = dispField; 

	    demon(:,:,qq)= movingReg;

	end
	demonTime = toc

	if gpuEnabled
	demon = gather(demon);
	end

	demonized_mov{nmjNum,1}=demon;
	disp_fields{nmjNum,1}=demonDispFields; 
	
    end
tic
demon_variable = genvarname(['demonized_mov',num2str(batchNum)])
eval([demon_variable '= demonized_mov'])

save(batchFile,['demonized_mov',num2str(batchNum)],'disp_fields','demonTime','-append')	
saveTime = toc
