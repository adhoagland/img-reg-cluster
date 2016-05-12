function batchDir = save_affine_batches(affineTform,movOutputDir, numNodes, nNmjs, nFrames, maxFrameNum)
	
	nFramesPerBatch = ceil(nFrames/numNodes)
	batchDir= fullfile(movOutputDir,'batches')

	cd(batchDir)
	!rm completed*
	
	for nodeNum = 1:numNodes
		batchAffine = cell(nNmjs,1);

		for nmjNum = 1:nNmjs
			affine = affineTform{nmjNum};

			%If statement to deal with the case when the number of frames is not divisible by the number of nodes
			if nodeNum == numNodes
			batchAffine{nmjNum,1} = affine(((nodeNum-1)*nFramesPerBatch)+1:nFrames);
			else
				batchAffine{nmjNum,1} = affine(((nodeNum-1)*nFramesPerBatch)+1:nodeNum*nFramesPerBatch);
			end

		end
			save([batchDir '/Batch' num2str(nodeNum)],'batchAffine','-append')
	end
