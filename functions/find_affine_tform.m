%Functions creates a list of as many tranformations as there are nodes so that each node has an initial transformation for the affine transformation to succeed.

function transformList = find_affine_tform(numNodes, numFrames, maxFrameNum, nNmjs, nmjMovie)

    [optimizer, metric] = imregconfig('monomodal');
    optimizer.MaximumStepLength = 0.001;
    optimizer.MinimumStepLength = 1e-5;
    optimizer.RelaxationFactor = 0.8;

    tranformList = cell(nNmjs,1)

    %Calculate Starting Point for Affine Transform

    numFramesPerNode = numFrames/numNodes;

    %The ith element in the transformation list is the transformation between the reference frame and frame ((i-1)*NumFramesPerNode) + 1
    startingListNum = ceil(maxFrameNum-1/numFramesPerNode);
    
    for nmjNum=	1:nNmjs
	%Load Movie
	movie = nmjMovie{nmjNum};
	
	%Get Important Frames
	refFrame = enhanceContrastForAffine(movie(:,:,maxFrameNum));


	%Make Storage Cell Object
	affineTransf = cell(numNodes,1);
	
	%Make initial transformation
        initTransf=affine2d([1 0 0;0 1 0;0 0 1]); 

	for nodeNum = startingListNum:numNodes-1
		disp(['Transforming Frame for Node',num2str(nodeNum)])
		movingFrame = movie(:,:,(nodeNum*numFramesPerNode)+1);
		movingFrame = enhanceContrastForAffine(movingFrame);
		tform = imregtform(movingFrame,refFrame,'affine',optimizer,metric,'InitialTransformation',initTransf);
		initTransf = tform;
		affineTransf{nodeNum+1} = tform;
	end

	%Make initial transformation
        initTransf=affine2d([1 0 0;0 1 0;0 0 1]); 

	for nodeNum = startingListNum-1:-1:0
		disp(['Transforming Frame for Node',num2str(nodeNum)])
		movingFrame = movie(:,:,(nodeNum*numFramesPerNode)+1);
		movingFrame = enhanceContrastForAffine(movingFrame);
		tform = imregtform(movingFrame,refFrame,'affine',optimizer,metric,'InitialTransformation',initTransf);
		initTransf = tform;
		affineTransf{nodeNum+1} = tform;

	end
	[t1s,t2s,s1s,s2s,sh1s,sh2s] = smooth_affine(affineTransf,numNodes);
	
	for nodeNum=1:numNodes
	affineTransf{nodeNum} = affine2d([s1s(nodeNum) sh1s(nodeNum) 0;sh2s(nodeNum) s2s(nodeNum) 0;t1s(nodeNum) t2s(nodeNum) 1]);
	end

	transformList{nmjNum} = affineTransf;
    end
end

function [t1s,t2s,s1s,s2s,sh1s,sh2s] = smooth_affine(tfAffine,nFrames)

for tfNum = 1:nFrames
t1(tfNum,1) = tfAffine{tfNum}.T(3,1);
t2(tfNum,1) = tfAffine{tfNum}.T(3,2);
s1(tfNum,1) = tfAffine{tfNum}.T(1,1);
s2(tfNum,1) = tfAffine{tfNum}.T(2,2);
sh1(tfNum,1) = tfAffine{tfNum}.T(1,2);
sh2(tfNum,1) = tfAffine{tfNum}.T(2,1);
end

smoothFactor = 15;
t1s = smooth(t1,smoothFactor);
t2s = smooth(t2,smoothFactor);
s1s = smooth(s1,smoothFactor);
s2s = smooth(s2,smoothFactor);
sh1s =  smooth(sh1,smoothFactor);
sh2s = smooth(sh2,smoothFactor);

end
