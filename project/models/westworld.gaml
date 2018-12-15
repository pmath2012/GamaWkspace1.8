/**
* Name: westworld
* Author: pmath
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model westworld

/* Insert your model definition here */

global{
	geometry shape <- square(100);
	graph<geometry,geometry> roads <- spatial_graph([]);
	list<point> nodes <- [];
	list<point> home_nodes <- [{0,20},{0,80},{20,0},{80,0},{100,20},{100,80},{20,100},{80,100}];
	list<point> stage_location <- [{36,36},{64,36},{36,64},{64,64}];
	file background_file <- file("../includes/background.jpg");
	file roadTexture <- file("../includes/roadTexture.jpg");
	file food <- file("../includes/fries.png");
	init{
		
		// Entry points

		loop p over:home_nodes{
			add p to:nodes;
		}
		
		// Extermities
		add point(20,20) to:nodes; //8
		add point(80,20) to:nodes; //9
		add point(20,80) to:nodes; //10
		add point(80,80) to:nodes; //11
		
		//concert hall
		add point(30,30) to:nodes; //12
		add point(30,70) to:nodes; //13
		add point(70,30) to:nodes; //14
		add point(70,70) to:nodes; //15
		
		int k <- length(nodes);


		loop node over:nodes{
			roads<- roads add_node(node);
		}
		
		roads <- roads add_edge(nodes at 0 :: nodes at 8);
		roads <- roads add_edge(nodes at 1 :: nodes at 10);		
        roads <- roads add_edge(nodes at 2 :: nodes at 8);
    	roads <- roads add_edge(nodes at 6 :: nodes at 10);
    	roads <- roads add_edge(nodes at 3 :: nodes at 9);
    	roads <- roads add_edge(nodes at 4 :: nodes at 9);
    	roads <- roads add_edge(nodes at 5 :: nodes at 11);
    	roads <- roads add_edge(nodes at 7 :: nodes at 11);
    	
    	roads <- roads add_edge(nodes at 8 :: nodes at 10);
    	roads <- roads add_edge(nodes at 8 :: nodes at 9);
    	roads <- roads add_edge(nodes at 10 :: nodes at 11);
    	roads <- roads add_edge(nodes at 9 :: nodes at 11);
    	
    	roads <- roads add_edge(nodes at 12 :: nodes at 13);
    	roads <- roads add_edge(nodes at 13 :: nodes at 15);
    	roads <- roads add_edge(nodes at 12 :: nodes at 14);
    	roads <- roads add_edge(nodes at 14 :: nodes at 15);
    	
    	roads <- roads add_edge(nodes at 8 :: nodes at 12);
    	roads <- roads add_edge(nodes at 9 :: nodes at 14);
    	roads <- roads add_edge(nodes at 10 :: nodes at 13);
    	roads <- roads add_edge(nodes at 11 :: nodes at 15);
    	
   		roads <- roads with_weights (roads.edges as_map (each::30));
   		
   		
		create information_center{
			location <- {10,10};
		}
		create food_court{
			location <- {90,90};
		}
		create bathroom{
			location <- {90,10};
		}
		create refreshments{
			location <- {10,90};
		}
		//create road from:nodes;
		create walker number:20{
			location <- home_nodes at rnd(length(home_nodes)-1);
			target<-{50,50};
			is_happy <- true;
			hunger_meter   <- 0.1 + float(rnd(1));
			thirst_meter   <- 0.1 + float(rnd(1));
			bathroom_meter <- 0.1 + float(rnd(0.5));
		
		}
		int i <- 0;
		create concert_hall number:4{
			location <- stage_location at i;
			i <- i + 1;
		}
	}
	
	
}

species information_center{
	aspect base{
		draw pyramid(10) color:#skyblue;
	}
}
species food_court{
	reflex sell_food{
		list<walker> customer <- walker at_distance(1);
		loop i over: customer{
			ask i{
				hunger_meter <- 1.0;
				bathroom_meter <- bathroom_meter + float(rnd(0.2));
			
			}			
		}
		
	}
	aspect base{
		draw pyramid(10) color:#red;
		//draw square(25) texture:food;
	}
}

species refreshments 
{
	reflex sell_drinks
	{		
		list<walker> customer <- walker at_distance(1);
		loop i over: customer
		{
			ask i
			{
				thirst_meter <- 1.0;
				bathroom_meter <- bathroom_meter + float(rnd(0.2));
			}
		
		}
	}
	aspect base{
		draw pyramid(10) color:#yellow;
	}
}
species bathroom{
	reflex bathroom_visit{
		list<walker> customer <- walker at_distance(1);
		loop i over: customer
		{
			ask i
			{
				bathroom_meter <- 0.0;
			}
		
		}
		
	}
	aspect base{
		draw pyramid(10) color:#blue;
	}
}

species concert_hall{
	aspect base{
		draw square(10) at:location color:#purple;

	}
}
species walker skills:[moving]{
	rgb color <- #cornsilk;
	point target<-nil;
	bool gohome <- false;
	//Attributes
	bool is_happy;
	//Variables that handle urges
	float hunger_meter;
	float thirst_meter;
	float bathroom_meter;
	//
	bool target_reached <- false;

	reflex walk when:target!=nil{
		speed <- 1.0;
		do goto target:target on:roads;
		if(location = target){
			target <- nil;
			target_reached<-true;
			
		}
	
	}
	//when we need to change location
	reflex go_to_new_location when: (hunger_meter <= 0 or thirst_meter <= 0 or bathroom_meter>=1) or target_reached {	
		target_reached <- false;
		if(hunger_meter <= 0){
			ask food_court{
				myself.target <- location;
				myself.color <- #red;
			}
		}
		else if(thirst_meter <= 0){
			ask refreshments{
				myself.target <- location;
				myself.color <- #yellow;
			}
		}
		else if(bathroom_meter>=1){
			ask bathroom{
				myself.target <- location;
				myself.color <- #blue;
			}
		}
		else if(is_happy){
			target <- {50,50};
			color <- #cornsilk;
		}
		
	}
	reflex reduce_stats{
		hunger_meter <- hunger_meter - (0.001 + float(rnd(0.0001)));
		thirst_meter <- hunger_meter - (0.001 + float(rnd(0.0001)));
		bathroom_meter <- bathroom_meter + float(rnd(0.001));
		write 'hunger_meter : '+hunger_meter;
		write 'thirst_meter : '+thirst_meter;
		write'bathroom_meter: '+bathroom_meter;
		write'-------------------------------';
		if(hunger_meter<=0 or thirst_meter<=0 or bathroom_meter>=1){
			is_happy<-false;
		}
		else{
			is_happy<-true;
		}

	}
	reflex wander when:target=nil{
		target_reached <- true;
		speed <- 1.0;
		do wander bounds:square(25);
	}
	
	
			
	reflex go_home when:gohome {
		do goto target:target on:roads;
	}
	
	aspect base{
		draw cube(2) color:#aqua;
		draw sphere(1)  at: {location.x, location.y, location.z+2} color:color;
	}
}
experiment exp{
	
    output {
        display MyDisplay type: opengl {
			graphics "meh"{
				draw square(100) texture:background_file;
				loop edges over:roads.edges{
					draw edges width: 10 texture:roadTexture;
				}
			
			}
			species information_center aspect:base;
			species food_court aspect:base;
			species refreshments aspect:base;
			species bathroom aspect:base;
			species walker aspect:base;
			species concert_hall aspect:base;
       
        }
    }
}