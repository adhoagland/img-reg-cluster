function batchDir = save_batches(nmjMovie,movOutputDir, numNodes, nNmjs, nFrames, maxFrameNum)
	
	nFramesPerBatch = ceil(nFrames/numNodes)
	batchDir= fullfile(movOutputDir,'batches')
	mkdir(batchDir)
	
	cd(batchDir)
	!rm *

	for nodeNum = 1:numNodes
		batchNum = nodeNum

		batchNmjs = cell(nNmjs,1);
		refFrames = cell(nNmjs,1);

		for nmjNum = 1:nNmjs
			nmj = nmjMovie{nmjNum};
			
			%If statement to deal with the case when the number of frames is not divisible by the number of nodes
			if nodeNum == numNodes
			batchNmjs{nmjNum} = nmj(:,:,((nodeNum-1)*nFramesPerBatch)+1:nFrames);
			else
			batchNmjs{nmjNum} = nmj(:,:,((nodeNum-1)*nFramesPerBatch)+1:nodeNum*nFramesPerBatch);
			end

			refFrames{nmjNum} = nmj(:,:,maxFrameNum);

			save([batchDir '/Batch' num2str(nodeNum)],'batchNmjs','refFrames','batchNum')

		end
	end
