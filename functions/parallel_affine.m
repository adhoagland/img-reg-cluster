% Created by: Bernal Jimenez
% 03/17/2016

function [] = parallel_affine(batchNum,batchFile,batchDir,sampleFactor)
    %Loading saved batch files
    load(batchFile)
    load([batchDir,'/affineTform.mat'])
    
    nNmjs = size(batchNmjs,1)
    affine_transform = cell(nNmjs,1);
    
    for nmjNum = 1:nNmjs   
	nmj = batchNmjs{nmjNum};
	nFrames = size(nmj,3)

	%Assuming there are 2 times more nodes than affine transformation samples	
	exampleNum = ceil(batchNum/sampleFactor)
	affineBatchTform = transformList{nmjNum}{exampleNum};

	refFrame = refFrames{nmjNum};

	disp(['Starting NMJ #: ',num2str(nmjNum)])
	
	affineTform = cell(nFrames,1);
	tic

	for qq = 1:nFrames
	    movingFrame = nmj(:,:,qq);
	    disp(['Computing Affine Transform Frame ', num2str(qq)])
	    affineTform{qq} = calc_affine_tform(movingFrame,refFrame,affineBatchTform);
	end

	affineTime = toc
	affine_transform{nmjNum,1} = affineTform
    end
tic
affineTform = genvarname(['affineTform',num2str(batchNum)])
eval([affineTform '= affine_transform'])

save(batchFile,['affineTform',num2str(batchNum)],'affineTime','-append')	
saveTime = toc
