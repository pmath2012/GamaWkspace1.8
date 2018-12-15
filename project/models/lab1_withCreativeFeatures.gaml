/**
* Name: wanderer
* Author: Prateek
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model wanderer

/* Insert your model definition here */

global{
	geometry shape <- square(100#m);
	bool memory<-true;
	int distTravelled <-0;
	point concertLoc <- {25,25};
	list<point> foodStallsLoc <- [{10,10},{90,90}];
	list<point> waterStallsLoc <- [{10,90},{90,10}];
	point info_center_location <- {50,50};
	int it <-0;
	init{
		create guest number:10{
			guestId <- it;
			it <- it+1;
		}
		create information_center number:1{
			location <- info_center_location;
		}
		it<-0;
		create foodStall number:2{
			location <- foodStallsLoc at it;
			it <- it+1;
		}
		it <- 0;
		create waterStall number:2{
			location <- waterStallsLoc at it;
			it <- it+1;
		}
		
		create securityGuard number:1{
			location <- {1,50};
		}
		create performer number:1{
			location <- concertLoc;
		}
		create medic number:1{
			location <- {50,0};
		}
	}
}

species information_center{
	point freeFoodStall ;
	point freeWaterStall;
	list<guest> badGuests <- [];
	list<guest> hurtGuests <- [];
	
	
	aspect base{
		draw pyramid(10) color:#purple;
		draw geometry:'InformationCenter' color:#black size:4 at:{location.x-5,location.y-6};
		
	}
	
	reflex updateFoodStall{
		int queueLen <- 1000;
		list<foodStall> stalls <- foodStall at_distance(100);
		
		loop i over:stalls{
			
			if(queueLen > i.queue){
				freeFoodStall <- i.location;
				queueLen <- i.queue;
			}
		}
	}
	
	reflex updateWaterStall{
		int queueLen <- 1000;
		list<waterStall> stalls <- waterStall at_distance(100);
		loop i over:stalls{
			if(queueLen > i.queue){
				freeWaterStall <- i.location;
				queueLen <- i.queue;
			}
		}
	}
	
}

species performer skills:[moving]{
	
	aspect base{
		draw cylinder(2.0,4.0) color:#teal;
		draw geometry:'performer' color:#black size:4 at:{location.x-4,location.y-4};
		
	}
}
species guest skills:[moving]{
	int hunger <- 1000;
	int thirst <- 1000;
	bool search <- false;
	bool searchFood <- false;
	bool searchWater <- false;
	geometry guest_shape <- sphere(1);
	rgb guest_color <- #green;
	point knownFoodStall;
	point knownWaterStall;
	point targetLocation<-concertLoc;
	int guestId;
	int nearest <-0;
	bool agitated<-false;
	bool murderer <- false;
	bool dead<-false;
	guest killedGuest;
	reflex wanderAngrily when:murderer{
		speed <- 1.5;
		do wander;
	}
	reflex doWander when: thirst > 20 and hunger > 20 and targetLocation = nil and !murderer and !agitated and !dead{ 
		do wander;
		thirst <- thirst - rnd(10);
		hunger <- hunger - rnd(10);
		if (hunger <= 20 and thirst <=20){
			search <- true;
			guest_color <- #grey;
			write 'fs'+knownFoodStall+' ws'+knownWaterStall;
		}
		
		else if (thirst <=20){
			searchWater <- true;
			guest_color <- #darkblue;
			write 'fs'+knownFoodStall+' ws'+knownWaterStall;
		}
		else if (hunger <= 20){
			searchFood <- true;
			guest_color <- #orange;
			write 'fs'+knownFoodStall+' ws'+knownWaterStall;
		}
	}
	reflex moveToTarget when: targetLocation != nil and !murderer and !agitated and !dead{
		do goto target:targetLocation;
		list<information_center> info <- information_center at_distance(1);
		list<foodStall> foodStalls <- foodStall at_distance(1);
		list<waterStall> waterStalls <- waterStall at_distance(1);
		
		if (!empty(info)){
			distTravelled<-distTravelled+1;
			information_center i <- info at 0;
			knownFoodStall <- i.freeFoodStall;
			knownWaterStall <- i.freeWaterStall;
		}else if(!empty(foodStalls)){
			distTravelled<-distTravelled+1;
			foodStall i <- foodStalls at 0;
			ask i{
				myself.hunger <- myself.hunger+self.foodServed;
			}
			searchFood <- false;
			guest_color <- #green;
			if(!memory){
				knownFoodStall <-nil;
				knownWaterStall <-nil;
			}
		}else if(!empty(waterStalls)){
			distTravelled<-distTravelled+1;
			waterStall i <- waterStalls at 0;
			ask i{
				myself.thirst <- myself.thirst+self.waterServed;
			}
			if(search){
				search <-false;
				searchFood <-true;
				guest_color <- #orange;
				if(!memory){
				knownFoodStall <-nil;
				knownWaterStall <-nil;
			}
			}else{
				searchWater<-false;
				guest_color <- #green;
				if(!memory){
				knownFoodStall <-nil;
				knownWaterStall <-nil;
			}
			}
			
		}
		if(hunger > 20 and thirst > 20){
			targetLocation <- {concertLoc.x+rnd(4),concertLoc.y+rnd(5)};
		}
		if(location distance_to(targetLocation)<1){
				targetLocation <- nil;
		}
		
	
	}
	reflex search when:search and targetLocation = nil and !murderer and !agitated and !dead{
		if (knownFoodStall != nil and knownWaterStall != nil){
			targetLocation <- knownWaterStall;
			if(!memory){
				knownFoodStall <-nil;
				knownWaterStall <-nil;
			}
			
		}else{
			targetLocation <- info_center_location;
		}
		
		
	}
	
	reflex searchWater when:searchWater and targetLocation = nil and !murderer and !agitated and !dead{
		if (knownWaterStall != nil){
			targetLocation <- knownWaterStall;
			if(!memory){
				knownFoodStall <-nil;
				knownWaterStall <-nil;
			}
		}else{
			targetLocation <- info_center_location;
		}		
	}
	reflex searchFood when:searchFood and targetLocation = nil and !murderer and !agitated and !dead{
		if (knownFoodStall != nil){
			targetLocation <-  knownFoodStall;
			if(!memory){
				knownFoodStall <-nil;
				knownWaterStall <-nil;
			}
		}else{
			targetLocation <- info_center_location;
		}
	}
	
	reflex getAgitated when: nearest > 10 and !murderer and !agitated and !dead{
		if (flip(0.3)){
			write 'Guest('+guestId+') :: I am getting agitated';
			agitated<-true;
			guest_color <- #red;
		}
	}
	
	reflex nearestNeighbors when: !murderer and !dead{
		list<guest> guests <- guest at_distance(2);
		nearest <- length(guests);
	}
	
	reflex getMad when: agitated and !murderer and !dead{
		write 'Guest('+guestId+') ::I am so Mad right now, I am going to hurt someone';
		list<guest> guests <- guest at_distance(2);
		if(!empty(guests)){
			write 'Guest('+guestId+'):: other guests beware';
			guest g <- guests at 0;
			ask g{
				g.guest_color <- #coral;
				g.dead <-true;
				write 'Guest :: guest hurt at location '+g.location;
			}
				agitated <-false;
				murderer <-true;
				killedGuest <- g;
		}

		ask information_center{
			add myself to: self.badGuests;
			add myself.killedGuest to:self.hurtGuests;
		}
		
	}

	reflex forgetStuff{
		if(rnd(1000)=1){
			knownFoodStall<-nil;
			knownWaterStall<-nil;
		}
	}
	aspect base{
		draw sphere(1) color:guest_color;
	}
}

species waterStall {
	int queue <- 0;
	int waterServed <- 1000;
	reflex queue_size{
		list<guest> guests <- guest at_distance(50);
		queue <- length(guests);
	}
	aspect base{
		draw teapot(4) color:#aqua;
	    draw geometry:'water stall' color:#black size:4 at:{location.x-4,location.y-5};
		
	}
}
species foodStall {
	int queue <- 0;
	int foodServed <- 1000;
	reflex queue_size{
		list<guest> guests <- guest at_distance(50);
		queue <- length(guests);
		}
	aspect base {
		draw cube(4) color:#chartreuse;
		draw geometry:'food stall' color:#black size:4 at:{location.x-4,location.y-5};
	}
}

species securityGuard skills:[moving]{
	point targetLocation;
	guest chased;
	bool found <-false;
	list<guest> badGuests <- [];
	reflex find_bad_agents when: empty(badGuests) and targetLocation = nil{
		ask information_center{
			myself.badGuests <- self.badGuests;
		}
		speed <- 0.5;
		do wander;
	}
	reflex remove_bad_agents when: !empty(badGuests) and targetLocation = nil{
		chased <- badGuests at 0;
		targetLocation <- chased.location;
	}
	
	reflex moveToTarget when:targetLocation != nil and !(found){
		speed <- 2.0;
		do goto target:targetLocation;
		if (location distance_to(targetLocation) < 3){
			targetLocation <- nil;
			found <-true;
		}
		}
	reflex removeBadAgent when:found{
		ask chased{
			write 'Security ::Removed guest '+self.guestId;
			do die;		
		}
		found <- false;
		remove from:badGuests index:0;
	}
	aspect base{
		draw cone3D(3.0,6.0) color:#salmon;
		draw geometry:'CPD' color:#black size:4 at:{location.x-4,location.y-4};
		
	}
}

species medic skills:[moving]{
	list<guest> guests <- [];
	bool close_to_guest;
	point target ;
	reflex revive_guests when:!(empty(guests)) and target = nil and !(close_to_guest){
		guest g <- guests at 0;
		target <- g.location;
				
	}
	reflex goto_guest when:target !=nil and !(close_to_guest){
		do goto target:target;
		if (location distance_to(target)<1){
			target<-nil;
			close_to_guest<-true;
		}
	}
	reflex revive when:!(empty(guests)) and target = nil and close_to_guest{
		guest g <- guests at 0;
		ask g{
			g.hunger <- 1000;
			g.thirst <- 1000;
			g.guest_color <- #green;
			g.dead <- false;
		}
		write 'Medic :: Revived guest ';
		remove from:guests index:0;
	}
	
	reflex get_hurt_guests when:empty(guests) {
		ask information_center{
			myself.guests <- self.hurtGuests;
		}
	}
	reflex go_to_base when:empty(guests) and target = nil{
		do goto target:{50,0};
	}
	
	aspect base{
		draw cylinder(1,5) color:#navajowhite;
		draw cylinder(3,1) color:#violet;
		draw geometry:'medic' color:#black size:4 at:{location.x-4,location.y-4};
		
	}
}
experiment experiment1 type:gui{
	output op{
		display disp1 type:opengl{
			species guest aspect:base;
			species information_center aspect:base;
			species foodStall aspect:base;
			species waterStall aspect:base;
			species securityGuard aspect:base;
			species performer aspect:base;
			species medic aspect:base;
		}
		display disp2 {
			chart "distance travelled"{
				data "total distance travelled by all guests"  value:distTravelled;
			}
		}
	}
}


