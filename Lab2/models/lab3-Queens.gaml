/***
* Name: lab3
* Author: Fredrik Bitén
* Description: Queen problem
* Tags: Tag1, Tag2, TagN
***/

model lab3

/* Insert your model definition here */
global{
	int field_size <- 96;
	geometry shape <- square(field_size);
	//Board size
	int N <- 4;
	//Column and row handles the drawing part
	int column <- 1;
	int row <- 1;
	//size of each square on the board
	int square_size <- ((100/N)/2);
	//first_white handles the drawing part
	bool first_white <- false;
	
	/****/
	matrix mat <- 0 as_matrix({N,N}); 
	list<queens> placed_queens;
	
	
	init{	
		create black_square number:((N*N)/2)
		{
			location <- {square_size*column,square_size*row}; 
			column<- column+4;
			if(column>=N*2){
				row <- row + 2;
				if(!first_white){
					column <- 3;
					first_white<-true;
				}
				else{
					column <- 1;
					first_white<-false;
				}
			}						
		}
		create queens number:N{
			location <- {field_size/2,field_size/2};
		}
	}

}
/*This class represents each black square on the board*/
species black_square{
	aspect base{
		draw square(100/N) at:location color:#black;

	}
}
species queens{
	list<int> tried_positions;
	int x;
	int y;
	reflex place_queen{
		if(empty(placed_queens)){
			mat[0,0]<-1;
		}
		else{
			ask placed_queens[0]{
				
			}
		}		
		
	}
	
	
	aspect base{
		draw circle((100/N)/5) at:location color:#red;
	}
}

experiment exp1{
	output
	{
		display disp1 type:opengl
		{
			species black_square  aspect:base;
			species queens aspect:base;

		}
	}
}
