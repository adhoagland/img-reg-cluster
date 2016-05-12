%Functions creates a list of as many tranformations as there are nodes so that each node has an initial transformation for the affine transformation to succeed.

function transformList = find_affine_examples(numExamples, nFrames, maxFrameNum, nNmjs, nmjMovie)
    tic

    [optimizer, metric] = imregconfig('monomodal');
    optimizer.MaximumStepLength = 0.001;
    optimizer.MinimumStepLength = 1e-5;
    optimizer.RelaxationFactor = 0.8;

    tranformList = cell(nNmjs,1)

    %Calculate Starting Point for Affine Transform

    nFramesPerExample = ceil(nFrames/numExamples);

    %The ith element in the transformation list is the transformation between the reference frame and frame ((i-1)*NumFramesPerNode) + 1
    startingListNum = ceil((maxFrameNum-1)/nFramesPerExample);
    
    for nmjNum=	1:nNmjs
	%Load Movie
	movie = nmjMovie{nmjNum};
	
	%Get Important Frames
	refFrame = enhanceContrastForAffine(movie(:,:,maxFrameNum));


	%Make Storage Cell Object
	affineTransf = cell(numExamples,1);
	
	%Make initial transformation
        initTransf=affine2d([1 0 0;0 1 0;0 0 1]); 

	for exampleNum = startingListNum:numExamples-1
		disp(['Transforming Frame for Node',num2str(exampleNum)])
		movingFrame = movie(:,:,(exampleNum*nFramesPerExample)+1);
		movingFrame = enhanceContrastForAffine(movingFrame);
		tform = imregtform(movingFrame,refFrame,'affine',optimizer,metric,'InitialTransformation',initTransf);
		initTransf = tform;
		affineTransf{exampleNum+1} = tform;
	end

	%Make initial transformation
        initTransf=affine2d([1 0 0;0 1 0;0 0 1]); 

	for exampleNum = startingListNum-1:-1:0
		disp(['Transforming Frame for Node',num2str(exampleNum)])
		movingFrame = movie(:,:,(exampleNum*nFramesPerExample)+1);
		movingFrame = enhanceContrastForAffine(movingFrame);
		tform = imregtform(movingFrame,refFrame,'affine',optimizer,metric,'InitialTransformation',initTransf);
		initTransf = tform;
		affineTransf{exampleNum+1} = tform;

	end
	affineTransf = smooth_affine(affineTransf,25);
	transformList{nmjNum} = affineTransf;
    end
    affineListTime = toc
end
