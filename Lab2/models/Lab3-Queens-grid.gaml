/***
* Name: Lab3Queensgrid
* Author: Fredrik
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Lab3Queensgrid

/* Insert your model definition here */

global{
//Size
int N <- 4;	
list<queen> placedQueens;
list<queen> availableQueens;
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
	list<int> slopes;
	
	bool queenPlaced <- false;
	queen previousQueen;
	reflex show_status{
//		write ''+self+': I am placed '+queenPlaced;
//		write 'Available Options : '+availableOptions;
	}
	reflex searchPos when: !queenPlaced and empty(placedQueens)and queenId=currentQueen{
		add self to:placedQueens;
		write 'First queen added to list :' + placedQueens;
		queenPos[0] <- 1;
		availableOptions[0] <- 'T';
		availableOptions[1] <- 'D';
		previousOptions[0] <- 'C';
		write 'Previous Positions ' +previousOptions;
		write 'Queen Placed ' + queenPos;
		write 'Available Pos' + availableOptions;
		queenPlaced <- true;
		remove self from:availableQueens;
		currentQueen <- currentQueen+1;	
	    agent var0 <- my_grid grid_at {queenId,0};
		location <- var0.location;
		add queenId to:slopes;	
	}
	
	reflex searchPos2 when: !queenPlaced and !empty(placedQueens) and queenId = currentQueen and !backtrack {
		write '------------------------------------------------------------';
		write 'processing queen '+queenId;
		
		previousQueen <- placedQueens at (length(placedQueens) -1);
		ask previousQueen{
			//write 'asking Previous Queen';
			myself.previousOptions <- self.availableOptions;
			myself.previousQueenPos <- self.queenPos; 
			myself.slopes <- self.slopes;
		}
		loop i from:0 to:(length(previousOptions)-1){
		   if(previousOptions[i] = 'X'){
				queenPos[i] <- 0;
				availableOptions[i] <- 'X';
			}
			else if(previousOptions[i] = 'T'){
				queenPos[i] <- 0;
				availableOptions[i] <- 'X';
			}
			else if(previousOptions[i] = 'D'){
				queenPos[i] <- 0;
				availableOptions[i] <- 'O';
			}else if(previousOptions[i] = 'O'){
				if(!queenPlaced){
					if(!(slopes contains (queenId-i))){
					write 'Placing queen at '+i;
					queenPos[i] <- 1;
					queenPlaced <- true;
					add self to:placedQueens;
					availableOptions[i] <- 'T';
					if((i-1)>=0 and availableOptions[i-1] = 'O'){
						availableOptions[i-1] <- 'D';
					}
					if(((i+1)<N)){
						availableOptions[i+1] <- 'D';
					}
					ask previousQueen{
						self.availableOptions[i] <- 'C';
						myself.previousOptions <- self.availableOptions;
					}
					currentQueen <- currentQueen+1;	
					agent var0 <- my_grid grid_at {queenId,i};
					location <- var0.location;
					
					}
				}else{
					if(availableOptions[i] != 'D')
						{availableOptions[i] <- 'O';}
					queenPos[i] <- 0;
				}
				
			}else if(previousOptions[i]='C'){
				availableOptions[i] <- 'O';
				queenPos[i] <- 0;
			}
		}
 		write 'Previous Queen Pos ' + previousOptions;
		write 'Current Queen Position '+self+' :'+queenPos;
		write 'Next Queen Options'+self+' :'+availableOptions;
		if (!queenPlaced){
			write 'need to backtrack';
			currentQueen <- currentQueen - 1;
			write 'going to queen ' + currentQueen;
			ask previousQueen{
				self.backtrack <- true;
				self.queenPos <- list_with(N, 0);
				self.availableOptions <- list_with(N,'O');
			}
		}
		write '------------------------------------------------------------';
			
	}
	
	
	reflex backtrackPos when:queenPlaced and backtrack and queenId = currentQueen{
		write 'Backtracking';
		if (queenId = 0){
			remove queenId from:slopes;
			int currentIdx <- queenPos index_of 1;
			int nextIdx <- previousOptions index_of 'O';
			queenPos[nextIdx] <- 1;
			queenPos[currentIdx] <- 0;
			availableOptions <- list_with(N,'O');
			availableOptions[nextIdx] <- 'T';
			if((nextIdx-1) >= 0){
				availableOptions[nextIdx-1] <- 'D';
			}
			if((nextIdx+1) < N){
				availableOptions[nextIdx+1] <- 'D';
			}
			write 'Queen Placed ' + queenPos;
			write 'Available Pos ' + availableOptions;
			queenPlaced <- true;
			currentQueen <- currentQueen+1;
		    agent var0 <- my_grid grid_at {queenId,nextIdx};
			location <- var0.location;
			add (queenId-nextIdx) to:slopes;
			
		}
		else if ( previousOptions != nil and previousOptions contains 'O'){
				
				
				int currentIdx <- queenPos index_of 1;
				int nextIdx <- previousOptions index_of 'O';
				if (nextIdx != -1 and currentIdx != -1){
				ask previousQueen{
					self.availableOptions[nextIdx] <- 'C';
				}
				queenPos[currentIdx] <- 0;
				availableOptions[currentIdx] <- 'O';
				availableOptions[nextIdx] <- 'T';
				if((nextIdx-1)>=0 and availableOptions[nextIdx-1] = 'O'){
					availableOptions[nextIdx-1] <- 'D';
				}
				if(((nextIdx+1)<N)){
					availableOptions[nextIdx+1] <- 'D';
				}
				backtrack <- false;
				currentQueen <- currentQueen+1;
				}else{
					queenPlaced <- false;
					remove self from:placedQueens;
					currentQueen <- currentQueen -1;
					write 'going to queen ' + currentQueen;
					ask previousQueen{
						self.backtrack <- true;
					}
					backtrack <- false;
		}
		}else{
			queenPlaced <- false;
			remove self from:placedQueens;
			currentQueen <- currentQueen -1;
			write 'going to queen ' + currentQueen;
			ask previousQueen{
				self.backtrack <- true;
			}
		}
	}
	aspect base{
		draw sphere(2) color:queenColor;
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