function [tfAffine] = smooth_affine(tfAffine,smoothFactor)

nFrames = size(tfAffine,1)
for tfNum = 1:nFrames
t1(tfNum,1) = tfAffine{tfNum}.T(3,1);
t2(tfNum,1) = tfAffine{tfNum}.T(3,2);
s1(tfNum,1) = tfAffine{tfNum}.T(1,1);
s2(tfNum,1) = tfAffine{tfNum}.T(2,2);
sh1(tfNum,1) = tfAffine{tfNum}.T(1,2);
sh2(tfNum,1) = tfAffine{tfNum}.T(2,1);
end

t1s = smooth(t1,smoothFactor);
t2s = smooth(t2,smoothFactor);
s1s = smooth(s1,smoothFactor);
s2s = smooth(s2,smoothFactor);
sh1s =  smooth(sh1,smoothFactor);
sh2s = smooth(sh2,smoothFactor);

for tfNum = 1:nFrames
tfAffine{tfNum} = affine2d([s1s(tfNum) sh1s(tfNum) 0;sh2s(tfNum) s2s(tfNum) 0;t1s(tfNum) t2s(tfNum) 1]);
end
