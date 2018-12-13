/**
* Name: nqueens
* Author: pmath
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model nqueens

/* Insert your model definition here */

global{
//Size
int N <- 7;	
list<queen> placedQueens;
list<queen> availableQueens;
list<int> slopes <- [];
int j;
int currentQueen <-0;
	init{
		create queen number:N{
			queenId <- j;
			j<-j+1;
			availableOptions <- list_with(N,'O');
			previousOptions <- list_with(N,'O');
			queenPos <- list_with(N, 0);
			
		}
		availableQueens <- list(queen);
	}
}

grid my_grid width:N height:N {
	init{
		if(int(grid_y/2)*2 = grid_y){
			if(int(grid_x/2)*2 != grid_x){
				color <- #black;
			}
		}else{
			if(int(grid_x/2)*2 = grid_x){
				color <- #black;
			}
		}
	}

}


species queen{
	int queenId;
	rgb queenColor;
	bool backtrack;
	list<int> queenPos ;
	list<string> availableOptions;
	list<int> previousQueenPos;
	list<string> previousOptions;

	
	bool queenPlaced <- false;
	queen previousQueen;
	reflex show_status{
//		write ''+self+': I am placed '+queenPlaced;
//		write 'Available Options : '+availableOptions;
	}
	
	reflex searchPos when: !queenPlaced and currentQueen=0{
		write '------------------------------------------------------------';
		write 'processing queen ' + queenId;
		write 'Available Positions ' + previousOptions;
		write 'Slopes ' + slopes;
		add self to:placedQueens;
		int nextIdx <- previousOptions index_of 'O';
		if (nextIdx != -1)
		{
			availableOptions[nextIdx] <- 'T';
			queenPos[nextIdx] <- 1;
			if (nextIdx > 0)
			{
				availableOptions[nextIdx - 1] <- 'D';
			}

			if (nextIdx < N)
			{
				availableOptions[nextIdx + 1] <- 'D';
			}
			add (queenId - nextIdx) to:slopes;
			currentQueen <- currentQueen+1;
			agent var0 <- my_grid grid_at {queenId,nextIdx};
			location <- var0.location;
			queenPlaced <- true;
			write 'Slopes '+ slopes;
			write 'Positions available to next Queen ' + availableOptions;
		}else{
			write 'No solution Found';
		}
		
	}
	
	reflex searchPos2 when: !queenPlaced and !empty(placedQueens) and queenId = currentQueen and !backtrack
	{
		write '------------------------------------------------------------';
		write 'processing queen ' + queenId;
		
		if (previousQueen = nil){
			previousQueen <- placedQueens at (length(placedQueens) - 1);
			write 'Previous Queen is now '+previousQueen;
			}
		ask previousQueen
		{
			myself.previousOptions <- self.availableOptions;
		}

		write 'Available Positions ' + previousOptions;
		int nextIdx <- previousOptions index_of 'O';
		int slope <- queenId - nextIdx;
		if (nextIdx != -1 and !(slopes contains slope))
		{
			availableOptions[nextIdx] <- 'T';
			queenPos[nextIdx] <-1;


			if (nextIdx >= 1 )
			{
				if (availableOptions[nextIdx - 1] = 'O')
				{
					availableOptions[nextIdx - 1] <- 'D';
				}

			}

			if (nextIdx < N - 1)
			{
				if (availableOptions[nextIdx + 1] = 'O')
				{
					availableOptions[nextIdx + 1] <- 'D';
				}

			}
			loop i from:0 to:(length(previousOptions)-1){
				if(previousOptions[i] = 'X'){
					availableOptions[i] <- 'X';
				}else if(previousOptions[i] = 'T'){
					availableOptions[i] <- 'X';
				}
			}
			add (queenId - nextIdx) to: slopes;
			queenPlaced <- true;
			add self to:placedQueens;
			currentQueen <- currentQueen + 1;
			agent var0 <- my_grid grid_at {queenId,nextIdx};
			location <- var0.location;
			write 'Slopes '+ slopes;
			write 'Positions available to next Queen ' + availableOptions;
		} else
		{
			write 'No solution Found';
			if (nextIdx = -1)
			{	
				currentQueen <- currentQueen - 1;
				ask previousQueen
				{
					self.backtrack <- true;
				}
				previousQueen <- nil;
				write 'Slopes '+ slopes;
				remove self from:placedQueens;

			} else if (slopes contains slope)
			{
				write ''+slope+'is present in'+slopes;
				ask previousQueen
				{
					self.availableOptions[nextIdx] <- 'C';
				}

			}

		}

		write '------------------------------------------------------------';
	}

	reflex backtrackPos when: queenPlaced and backtrack and queenId = currentQueen
	{
		write 'Backtracking queen :' + queenId;
		if (previousQueen != nil){
			ask previousQueen{
				myself.previousOptions <- self.availableOptions;			
		}
		}
		write 'Available Positions before backtrack:' + previousOptions;
		int currentInd <- queenPos index_of 1;
		queenPos[currentInd] <- 0;
		if (currentInd != -1){
			if(previousQueen != nil){
				ask previousQueen{
					self.availableOptions[currentInd] <- 'C';
				}
				}
				else{
					previousOptions[currentInd] <- 'C';
				}
				backtrack <- false;
				queenPlaced <- false;
				availableOptions <- list_with(N,'O');
			}
		if (previousQueen != nil){
			ask previousQueen{
				myself.previousOptions <- self.availableOptions;			
		}
		}
		int nextInd <- previousOptions index_of 'O';
		if (nextInd = -1){
			currentQueen <- currentQueen -1;
			write 'No available spot to move, moving to queen :'+currentQueen;

			backtrack <- false;
			queenPlaced <- false;
			remove self from:placedQueens;
			ask previousQueen{
				self.backtrack <- true;
			}
			previousQueen <- nil;
			
			
		}
		int slope <- queenId-currentInd;
		write 'slopes '+slopes;
		remove slope from:slopes;
		write 'slopes '+slopes;
		write 'Available Positions After backtrack:' + previousOptions;
		write '------------------------------------------------------------';
		
		}
		
	aspect base{
		draw sphere(1) color:queenColor;
	}
}



experiment MyExperiment type: gui {
    output {
        display MyDisplay type: opengl {
            grid my_grid lines:#black;
            species queen aspect:base;
       
        }
    }
}