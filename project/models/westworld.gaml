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
	file background_file <- file("../includes/background.jpg");
	file roadTexture <- file("../includes/roadTexture.jpg");
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
    	
   		roads <- roads with_weights (roads.edges as_map (each::circle(2)));
   		
   		
		create information_center{
			location <- {10,10};
		}
		create information_center{
			location <- {90,90};
		}
		create information_center{
			location <- {90,10};
		}
		create information_center{
			location <- {10,90};
		}
		//create road from:nodes;
		create walker number:10{
			location <- home_nodes at rnd(length(home_nodes)-1);
			target<-{50,50};
		}
		create concert_hall;
	}
	
	
}

species information_center{
	aspect base{
		draw pyramid(10) color:#skyblue;
	}
}

species refreshments {
	aspect base{
		draw cube(2) color:#black;
	}
}

species concert_hall{
	aspect base{
		draw circle(1) at:{35,35} color:#brown;
		draw cylinder(0.2,10) at:{35,35} color:#orange;
		draw circle(1) at:{65,35} color:#brown;
		draw cylinder(0.2,10) at:{65,35} color:#orange;
		draw circle(1) at:{35,65} color:#brown;
		draw cylinder(0.2,10) at:{35,65} color:#orange;
		draw circle(1) at:{65,65} color:#brown;
		draw cylinder(0.2,10) at:{65,65} color:#orange;
		draw square(30) at:{50,50,10} color:#antiquewhite;
	}
}
species walker skills:[moving]{
	point target<-nil;
	bool reached ;
	bool gohome;

	reflex walk when:target!=nil and !reached{
		do goto target:target on:roads;
		if(location = target){
			target <- target+2;
			reached <- true;
		}
	}
	reflex wander when:reached and !gohome {
		if(target!=nil){
			do goto target:target;
			if (location = target){
				target<-nil;
			}
		}else{
		do wander;
		if flip(0.1){
			gohome<-true;
			target<- home_nodes at rnd(length(home_nodes)-1);
		}
		}

	}
	
			
	reflex go_home when:gohome {
		do goto target:target on:roads;
	}
	
	aspect base{
		draw cube(2) color:#aqua;
		draw sphere(1)  at: {location.x, location.y, location.z+2} color:#cornsilk;
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
			species walker aspect:base;
			species concert_hall aspect:base;
       
        }
    }
}