%Created  by: Bernal Jimenez
%04/20/2014

function [fullAffineTform] = join_affine_mov(batchDir,nNmjs,movOutputDir,numOfNodes)
	fullAffineTform = cell(nNmjs,1);
	
	for nmjNum=1:nNmjs
		%Create empty array to perform movie concatenation
		fullAffineTform{nmjNum} = cell(0,1);
		
		for nodeNum = 1:numOfNodes
			keepWaiting = true	
			while keepWaiting
				try
				load([batchDir,'/completed_batch',num2str(nodeNum),'.mat']);
				keepWaiting = false;
				catch
				end
			end

			batchName = ['/Batch',num2str(nodeNum),'.mat']
			load([batchDir,batchName]);
			affine_tform = genvarname(['affineTform',num2str(nodeNum)])
			fullAffineTform{nmjNum} = cat(1,fullAffineTform{nmjNum},eval([affine_tform '{nmjNum}']));
			disp(['Batch',num2str(nodeNum),' Complete'])
		end
		fullAffineTform{nmjNum} = smooth_affine(fullAffineTform{nmjNum},20)
	end
	save([movOutputDir, '/fullTform.mat'],'fullAffineTform','-v7.3')
