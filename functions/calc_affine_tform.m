function affineTransform = calc_affine_tform(movingFrame,refFrame,initialTform)
    
[optimizer,metric] = imregconfig('monomodal');
optimizer.MaximumStepLength = 0.001;
optimizer.MinimumStepLength = 1e-5;
optimizer.RelaxationFactor = 0.8;
    
%Affine Enhanced Contrast
enhancedMovingFrame=enhanceContrastForAffine(movingFrame);
enhancedRefFrame = enhanceContrastForAffine(refFrame);

try
affineTransform= imregtform(enhancedMovingFrame,enhancedRefFrame,'affine',optimizer,metric,'InitialTransformation',initialTform); 
catch
optimizer.MaximumStepLength = 0.00005
affineTransform= imregtform(enhancedMovingFrame,enhancedRefFrame,'affine',optimizer,metric,'InitialTransformation',initialTform); 
end
