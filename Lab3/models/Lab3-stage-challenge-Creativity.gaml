/***
* Name: Lab3stage
* Author: Fredrik Bitén
* Description: Guests are green circles, stages are black squares.
* A guest will decide with stage best fits his preference and move there.
* When a guest has chosen his best fit, he will be able to communicate to get info
* regarding the crowd mass of the stage he is heading to. If the he doesnt like a big crowd he will
* switch stage(turn red) and go to another one.
* if only two people attend a stage and one of time likes bigger crowds and the other not
* the one who likes bigger crowds will move to a bigger stage.
* 
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
	int totalCost;
	float currentCost;
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
			costOfSecurity <- 1.0;
			costOfBand <- rnd(float(1000));
			airConditioning <- 2.0;
			//Add stage to list
			stages <- stage;
			
		}
		create guest number: Nr_of_guests
		{
			location <- {45+rnd(10),45+rnd(10)};
			//Generate preferences
			lights   <- rnd(float(1));
			visuals   <- rnd(float(1));
			sound    <- rnd(float(1));
			weather  <- rnd(float(1));
			band     <- rnd(float(1));
			security <- rnd(float(1));
			//generate value for likes_crowded_stages
			int random <- rnd(100);
			if(random > 25)
			{
				likes_crowded_stages <- true;
			}
			else
			{
				likes_crowded_stages <- false;
			}
		}
		create stage_director number: 1{
			location <- {50,50};
		}
		create control_room number: 1{
			location <- {50,10};
		}
	}
}



species stage{
	//color of stage
	rgb color <- #black;
	//Stage name
	string stage_name <- stage.name;
	//utility
	bool generate_utility <- true;
	float lights;
	float visuals;
	float sound;
	float weather;
	float band;
	float security;
	float totalCostToRun;
	float costOfBand;
	float costOfSecurity;
	float airConditioning;
	bool entryClosed;
	bool ask_guests_to_leave;
	//Attendance at stage
	int attendance <- 0;
	//people that are currently travelling to the stage.
	int crowd_mass <- 0;
	reflex update_attendance{
		list<guest> guests <- guest at_distance(2);
		attendance <- length(guests);
	}
	reflex maximize_agent_utility when: crowd_mass=2 and attendance=2{
		//change
		list<guest> guests <- guest at_distance(2);
		if(guests[0].likes_crowded_stages and !(guests[1].likes_crowded_stages))
		{
			ask guests[0]{
				go_to_crowded_stage <- true;
			}
		}
		else if(guests[1].likes_crowded_stages and !(guests[0].likes_crowded_stages))
		{
			ask guests[1]{
				go_to_crowded_stage <- true;
			}
		}
	}
	
	reflex updateCost when: !entryClosed {
		totalCostToRun <- costOfBand + costOfSecurity*attendance + airConditioning*attendance;
		currentCost <- currentCost + totalCostToRun;
	}
	reflex too_few_guests when: ask_guests_to_leave and !entryClosed{
		list<guest> guests <- guest at_distance(1);
		loop i over:guests{
			ask i{
				
				write ''+myself+' : Too few guests, please leave';
				self.go_to_crowded_stage <- true;
			}
		}
	}
	aspect{
		draw cube(8) at:location color:color;
		draw geometry: stage_name color:#black size:4 at:{location.x-4,location.y-5};
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
	//target destination coordinates
	point target_point <- nil;
	int target_stage;
	//Total utility for stages
	list<float> total_utility;
	//Variable used to initiate movement of guests
	bool start_searching <-false;
	//If guest likes crowded states
	bool likes_crowded_stages;
	//Challenge1: if exactly two guests are attending a stage and one of the guests like crowds and the other one now, this will be true.
	bool go_to_crowded_stage <- false;
	
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
		target_stage <- highest_utility_index;
	
		write'*******************************************************************************************************************************************';
		write guest.name+ ' The highest Utility for a stage was given by '+stages[highest_utility_index] + ' and the utility value was: '+highest_utility;
		write 'The utility value for each stage was:';
		int i<-0;
		loop p over:stages{
			write'-------------------------------';
			write ''+ p +' = '+ total_utility[i];
			i <- i+1;
		}
		ask stages[highest_utility_index]{
			crowd_mass <- crowd_mass + 1;
		}
		target_point <- {stages[highest_utility_index].location.x,stages[highest_utility_index].location.y};
	}
	reflex check_if_crowded when: !likes_crowded_stages and target_point != nil{
		if(stage[target_stage].crowd_mass > 20){
			color <- #red;
			int index <- 0;
			loop i over: stages
			{
				if(i.crowd_mass<15)
				{
					ask i
					{
						crowd_mass <- crowd_mass+1;										
					}
					target_point <- {i.location.x,i.location.y};
					ask stage[target_stage]
					{
						crowd_mass <- crowd_mass-1;
						myself.target_stage <- index;
						break;
					}
				}
				index <- index + 1;
			}
			
		}
	}
	//challenge 1
	reflex go_to_crowded_stage when: go_to_crowded_stage{
		loop i over: stages{
			if(i.crowd_mass > 10){
				go_to_crowded_stage <- false;
				ask stage[target_stage]{
					crowd_mass<-crowd_mass-1;
				}
				ask i{
					crowd_mass<-crowd_mass+1;
				}
				color <- #blue;
				target_point <- {i.location.x,i.location.y};
				break;
			}
		}
	}

	reflex move_to_stage when: target_point != nil{
		do goto target: target_point;
		speed <- 1.0;
	}

	aspect{
		draw sphere(1) at:location color:color;
	}
	
}
species stage_director skills:[moving]{
	rgb color <- #purple;
	point target_point <- nil;
	list<stage> stages_to_close;
	bool done;
	bool close_stages;
	bool rearrangement;
	reflex idle when: target_point = nil{
		do wander;
		speed <- 0.1;
	}
	reflex move_to_stage when: target_point != nil and close_stages and !done{
		do goto target: target_point;
		speed <- 1.0;
		if(location=target_point){
			
			loop i over: stages_to_close{
				ask i
				{
					self.color<-#red;
					self.stage_name <- 'CLOSED';
					currentCost <- currentCost - self.totalCostToRun;
					write ''+self+' : the stage is closed';
				}
				
			}
			done <- true;
		}
	}
	reflex check_which_stage_to_close when: !done and !close_stages{
		if((stages[0].attendance + stages[1].attendance + stages[2].attendance + stages[3].attendance) = Nr_of_guests)
		{
			loop i over: stages{
				ask i{
					if(self.attendance <5 and self.attendance >0){
					self.ask_guests_to_leave <- true;
					myself.rearrangement<-true;
					}
				}
			}
			if(!rearrangement){
			loop i over: stages
			{
				//close stage
				if(i.attendance = 0){
					add i to: stages_to_close;			
				}
				i.entryClosed<-true;
			}
			target_point <- {50,10};
			close_stages<-true;
			ask control_room{
				self.entryClosed<-true;
			}
		}
		rearrangement<-false;
		}	
	}
	reflex close_stage when: !empty(stages_to_close){
		
	}
	aspect{
		draw hexagon(3) at:location color:color;
		draw geometry: 'Stage director' color:#black size:5 at:{location.x-4,location.y-2};
	}
}
species control_room{
	int costOfFestival;
	bool entryClosed;
	
	reflex update when:!entryClosed{
		costOfFestival <- int(currentCost);
		currentCost<-0.0;
		totalCost <- costOfFestival;
	}
	reflex finalCost when: entryClosed{
		costOfFestival <- int(currentCost);
		totalCost <- costOfFestival;
	}
	aspect{
		draw rectangle(12,4) at:location color:#orange;
		draw geometry: 'total cost :'+costOfFestival color:#black size:6 at:{location.x-5,location.y+4};
		draw geometry: 'control room' color:#black size:4 at:{location.x-6,location.y-6};
	}
}

experiment MyExperiment type: gui {

    output
    {
    	display MyDisplay type: opengl
    	{
    		species stage;
    		species guest;
    		species stage_director;
    		species control_room;
    	}

    	display disp
    	{
    		chart "total cost of the festival"
    		{
    			data "Cost" value: totalCost;
    		}

    	}

    }

    }