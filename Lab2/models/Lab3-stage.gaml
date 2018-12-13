/***
* Name: Lab3stage
* Author: Fredrik
* Description: 
* Guests are green circles, stages are black squares.
* A guest will decide with stage best fits his preference and move there.
***/

model Lab3stage

/* Insert your model definition here */

global{
	//shape of the area(cant leave bounds)
	geometry shape <- square(100#m);
		//List of locations for all stages
	list<point> stage_location <- [{10,10},{90,10},{10,90},{90,90}];
	//The number of quests that are participating
	int Nr_of_guests <- 50;
	//List of all stages
	list<stage> stages;
	
	int i <- 0;
	init{

		create stage number:4{
			location <- stage_location at i;
			i <- i + 1;
			//Generate utility
			lights   <- rnd(float(1));
			visuals   <- rnd(float(1));
			sound    <- rnd(float(1));
			weather  <- rnd(float(1));
			band     <- rnd(float(1));
			security <- rnd(float(1));
			//Add stage to list
			stages <- stage;
			
		}
		create guest number: Nr_of_guests{
			location <- {45+rnd(10),45+rnd(10)};
			//Generate preferences
			lights   <- rnd(float(1));
			visuals   <- rnd(float(1));
			sound    <- rnd(float(1));
			weather  <- rnd(float(1));
			band     <- rnd(float(1));
			security <- rnd(float(1));
		}
	}
}



species stage{
	//utility
	bool generate_utility <- true;
	float lights;
	float visuals;
	float sound;
	float weather;
	float band;
	float security;
	//Attendance for stage
	int attendance <- 0;
	reflex update_attendance{
		list<guest> guests <- guest at_distance(10);
		attendance <- length(guests);
	}
	aspect{
		draw square(8) at:location color:#black;
		draw geometry: stage.name color:#black size:4 at:{location.x-4,location.y-5};
		draw geometry: 'Attendance: '+attendance color:#black size:4 at:{location.x-4,location.y+6};
	}
}
species guest skills:[moving]{
	//preferences
	float lights;
	float visuals;
	float sound;
	float weather;
	float band;
	float security;	
	//Color of guest
	rgb color <- #green;
	//target destination
	point target_point <- nil;
	//Total utility for stages
	list<float> total_utility;
	//
	bool start_searching <-false;
	
	reflex idle_movement when: target_point = nil{
		speed <- 0.2;
		do wander;
		//start searching stage
		int random <- rnd(100);
		if(random = 1){
			start_searching <- true;
		}
		
	}
	reflex find_best_stage when: target_point = nil and start_searching{
		loop i over: stages
		{
			ask i
			{
				//calculate utility
				float utility <- myself.lights*lights + myself.visuals*visuals+myself.sound*sound+myself.weather*weather+myself.band*band+myself.security*security;
				add utility to: myself.total_utility;
			}
		}
		float highest_utility <- 0;
		int highest_utility_index;
		int index <- 0;
		loop k over:total_utility{
			if(k>highest_utility)
			{
				highest_utility <- k;
				highest_utility_index <- index;
			}
			index<-index+1;
		}
		write guest.name+ ' The highest Utility for a stage was given by '+stages[highest_utility_index] + ' and the utility value was: '+highest_utility;
		write 'The utility value for each stage was:';
		int i<-0;
		loop p over:stages{
			write'-------------------------------';
			write ''+ p +' = '+ total_utility[i];
			i <- i+1;
		}
		target_point <- {stages[highest_utility_index].location.x,stages[highest_utility_index].location.y};
	}
	reflex move_to_stage when: target_point != nil{
		do goto target: target_point;
		speed <- 1.0;
	}
	aspect{
		draw circle(1) at:location color:color;
	}
	
}

experiment MyExperiment type: gui {
    output {
        display MyDisplay type: opengl{
          species stage;   
          species guest;
        }
    }
}