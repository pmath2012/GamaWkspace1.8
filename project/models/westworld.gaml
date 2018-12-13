/**
* Name: westworld
* Author: pmath
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model westworld

/* Insert your model definition here */

global{
	geometry shape <- square(100#m);
	graph<geometry,geometry> roads <- spatial_graph([]);
	list<point> nodes <- [];
	
	init{
		
		// Entry points
		add point(0,20) to:nodes; //1
		add point(0,80) to:nodes; //2
		
		// Extermities
		add point(20,20) to:nodes; //3
		add point(80,20) to:nodes; //4
		add point(20,80) to:nodes; //5
		add point(80,80) to:nodes; //6
		
		//extra points
///		add point(,80) to:nodes;
		
		
		int k <- length(nodes);


		loop node over:nodes{
			roads<- roads add_node(node);
		}
		roads <- roads add_edge(nodes at 0 :: nodes at 2);
		roads <- roads add_edge(nodes at 0 :: nodes at 4);
		roads <- roads add_edge(nodes at 1 :: nodes at 2);
		roads <- roads add_edge(nodes at 1 :: nodes at 4);
    	roads <- roads add_edge(nodes at 2 :: nodes at 3);
    	roads <- roads add_edge(nodes at 2 :: nodes at 4);
//    	roads <- roads add_edge(nodes at 2 :: nodes at 5);
//    	roads <- roads add_edge(nodes at 3 :: nodes at 4);
    	roads <- roads add_edge(nodes at 3 :: nodes at 5);
    	roads <- roads add_edge(nodes at 5 :: nodes at 4);
   		roads <- roads with_weights (roads.edges as_map (each::circle(2)));
   		
   		
		create building{
			location <- {5,5};
		}
		create building{
			location <- {95,95};
		}
		create building{
			location <- {95,5};
		}
		create building{
			location <- {5,95};
		}
		//create road from:nodes;
		create walker {
			location <- {0,20};
			target<-{50,50};
		}
	}
	
	
}

species building{
	aspect base{
		draw cube(4) color:#blue;
	}
}

species road {
	aspect base{
		draw cube(2) color:#black;
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
			target<- {0,20};
		}
		}

	}
	
			
	reflex go_home when:gohome {
		do goto target:target on:roads;
	}
	
	aspect base{
		draw sphere(2) color:#orange;
	}
}
experiment exp{
	
    output {
        display MyDisplay type: opengl {
			graphics "meh"{
				loop edges over:roads.edges{
					draw edges width: 5 color:#brown;
				}

			}
			species road aspect:base;
			species building aspect:base;
			species walker aspect:base;
       
        }
    }
}