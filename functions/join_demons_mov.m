%Created  by: Bernal Jimenez
%04/20/2014

function [] = join_demons_mov(batchDir,nNmjs,movOutputDir,numOfNodes)
	fullMovie = cell(nNmjs,1);
	fullDispField = cell(nNmjs,1);
	
	for nmjNum=1:nNmjs
		%Create empty array to perform movie concatenation
		fullMovie{nmjNum} = [];
		fullDemonsTform = cell(0,1);
		fullDispField{nmjNum} = cell(0,1);
		
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
			demonized_mov = genvarname(['demonized_mov',num2str(nodeNum)])
			fullMovie{nmjNum} = cat(3,fullMovie{nmjNum},eval([demonized_mov '{nmjNum}']));
			fullDispField{nmjNum} = cat(1,fullDispField{nmjNum},disp_fields{nmjNum});
			disp(['Batch',num2str(nodeNum),' Complete'])
		end
	end
	save([movOutputDir, '/fullMovie.mat'],'fullMovie','fullDispField','-v7.3')
