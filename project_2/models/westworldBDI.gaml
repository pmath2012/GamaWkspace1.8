/***
* Name: westworldBDI
* Author: pmath
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model westworldBDI

/* Insert your model definition here */
global
{
	geometry shape <- square(100);
	float days <- 3.0;
	float dur <- days * 1440.0;
	graph<geometry, geometry> roads <- spatial_graph([]);
	list<point> nodes <- [];
	list<point> home_nodes <- [{ 0, 20 }, { 0, 80 }, { 20, 0 }, { 80, 0 }, { 100, 20 }, { 100, 80 }, { 20, 100 }, { 80, 100 }];
	list<point> stage_location <- [{ 36, 36 }, { 64, 36 }, { 36, 64 }, { 64, 64 }];
	file background_file <- file("../includes/background.jpg");
	file roadTexture <- file("../includes/roadTexture.jpg");
	point infocenter_loc <- { 10, 10 };
	point foodStall_loc <- { 10, 90 };
	point refreshment_loc <- { 90, 10 };
	point washroom_loc <- { 90, 90 };
	point concert_loc <- { 50, 50 };
	point lovers_point <- { 10, 50 };
	point food_truck_base <- { 25, 10 };
	point bar_loc <- { 50, 90 };
	point healing_area <- { 10, 25 };
	point base_loc <- { infocenter_loc.x + 35, infocenter_loc.y - 10 };
	point amb_loc <- { infocenter_loc.x + 25, infocenter_loc.y - 10 };
	point scrap_yard_loc <- { infocenter_loc.x + 55, infocenter_loc.y - 10 };
	float netCost;
	float netProfit <- 0.0;
	int greed_th <- 7;
	int love_th <- 7;
	int jealousy_th <- 7;
	int gluttony_th <- 7;
	int anger_th <- 5;
	int nb_guest <- 25;
	int nb_hosts <- 1;
	float global_happiness <- 0.0;
	float robot_affinity_thresh <- 0.2;
	int attack_rob <- 1;
	//debugging 
	bool debug <- true;

	// Predicates that define user basic behavior
	predicate goto_concert <- new_predicate('goto Concert');
	predicate enjoy_concert <- new_predicate('enjoy concert');
	predicate get_food <- new_predicate('get food');
	predicate need_washroom <- new_predicate('need a washroom');
	predicate thirst <- new_predicate('need refreshment');
	predicate get_information <- new_predicate('get information');
	predicate go_home <- new_predicate('go home');
	predicate enjoy_concert_together <- new_predicate(' enjoy_concert_together ');
	predicate heartbreak <- new_predicate('heartbreak');
	predicate drink <- new_predicate('drink');
	predicate ask_help <- new_predicate('ask_help');
	predicate hurt_people <- new_predicate('hurt_people');
	init
	{

	// Entry points
		loop p over: home_nodes
		{
			add p to: nodes;
		}

		// Extermities
		add point(20, 20) to: nodes; //8
		add point(80, 20) to: nodes; //9
		add point(20, 80) to: nodes; //10
		add point(80, 80) to: nodes; //11

		//concert hall
		add point(30, 30) to: nodes; //12
		add point(30, 70) to: nodes; //13
		add point(70, 30) to: nodes; //14
		add point(70, 70) to: nodes; //15
		int k <- length(nodes);
		loop node over: nodes
		{
			roads <- roads add_node (node);
		}

		roads <- roads add_edge (nodes at 0::nodes at 8);
		roads <- roads add_edge (nodes at 1::nodes at 10);
		roads <- roads add_edge (nodes at 2::nodes at 8);
		roads <- roads add_edge (nodes at 6::nodes at 10);
		roads <- roads add_edge (nodes at 3::nodes at 9);
		roads <- roads add_edge (nodes at 4::nodes at 9);
		roads <- roads add_edge (nodes at 5::nodes at 11);
		roads <- roads add_edge (nodes at 7::nodes at 11);
		roads <- roads add_edge (nodes at 8::nodes at 10);
		roads <- roads add_edge (nodes at 8::nodes at 9);
		roads <- roads add_edge (nodes at 10::nodes at 11);
		roads <- roads add_edge (nodes at 9::nodes at 11);
		roads <- roads add_edge (nodes at 12::nodes at 13);
		roads <- roads add_edge (nodes at 13::nodes at 15);
		roads <- roads add_edge (nodes at 12::nodes at 14);
		roads <- roads add_edge (nodes at 14::nodes at 15);
		roads <- roads add_edge (nodes at 8::nodes at 12);
		roads <- roads add_edge (nodes at 9::nodes at 14);
		roads <- roads add_edge (nodes at 10::nodes at 13);
		roads <- roads add_edge (nodes at 11::nodes at 15);
		roads <- roads with_weights (roads.edges as_map (each::30));
		create host_helper number: nb_hosts
		{
			location <- { concert_loc.x + rnd(6), concert_loc.y - rnd(5) };
		}

		create ambulance
		{
			location <- amb_loc;
		}

		create bar
		{
			location <- bar_loc;
		}

		create security
		{
			location <- base_loc;
		}

		create food_court
		{
			revenue <- 0.0;
			meal_cost <- 5.0;
			storage <- 60.0;
			location <- foodStall_loc;
		}

		create bathroom
		{
			location <- washroom_loc;
		}

		create refreshments
		{
			bottle_cost <- 10.0;
			location <- refreshment_loc;
		}

		create disco
		{
			location <- lovers_point;
		}
		//create road from:nodes;
		create walker number: nb_guest
		{
			point initial <- home_nodes at rnd(length(home_nodes) - 1);
			location <- initial;
			target <- { 50, 50 };
			is_happy <- true;
			hunger_meter <- 0.1 + float(rnd(1));
			thirst_meter <- 0.1 + float(rnd(1));
			bathroom_meter <- 0.1 + float(rnd(0.5));
			money <- 1000 + rnd(1000.0);
			home <- initial;
		}

		create food_truck
		{
			quantity <- 5000.0;
			location <- { infocenter_loc.x + 15, infocenter_loc.y };
		}

		create casino
		{
			location <- { 90, 50 };
		}

		create information_center
		{
			location <- infocenter_loc;
			foodStall <- foodStall_loc;
			washroom <- washroom_loc;
			refreshment <- refreshment_loc;
			revenue <- 0.0;
			cost <- 0.0;
			foodCourt <- food_court at_distance 100;
			refreshmentStall <- refreshments at_distance 100;
			casinos <- casino at_distance 100;
			bars <- bar at_distance 100;
			discos <- disco at_distance 100;
			washrooms <- bathroom at_distance 500;
		}

		create concert_hall
		{
			location <- stage_location at 0;
		}

		create concert_hall
		{
			location <- stage_location at 1;
		}

		create concert_hall
		{
			location <- stage_location at 2;
		}

		create concert_hall
		{
			location <- stage_location at 3;
		}

	}

	reflex showtime
	{
		dur <- days * 1440;
		if (time = dur)
		{
			do pause();
		}

	}

}

species information_center skills: [fipa]
{
	int oldMess <- 0;
	point foodStall;
	point refreshment;
	point washroom;
	float revenue;
	float cost;
	bool sim_start <- false;
	bool sendFood;
	list<food_court> foodCourt;
	list<refreshments> refreshmentStall;
	list<casino> casinos;
	list<bar> bars;
	list<disco> discos;
	list<bathroom> washrooms;
	list<walker> helpList <- [];
	list<walker> bad_guests <- [];
	reflex attend_to_guest
	{
		list<walker> guests <- walker at_distance 0;
		if (!empty(guests))
		{
			walker i <- guests at 0;
			ask i
			{
				write '---------------------------------------------------------------------------';
				write 'Serving guest ' + i;
				self.knownFoodStall <- myself.foodStall;
				self.knownRefreshment <- myself.refreshment;
				self.knownWashroom <- myself.washroom;
				if (i.hunger_meter <= 0)
				{
					write 'for food please go to ' + myself.foodStall;
					i.target <- myself.foodStall;
				} else if (i.thirst_meter <= 0)
				{
					write 'for refreshments please go to ' + myself.refreshment;
					i.target <- myself.refreshment;
				} else if (i.bathroom_meter >= 1)
				{
					i.target <- myself.washroom;
					write 'for the washroom,please go to ' + myself.washroom;
				}

				write '---------------------------------------------------------------------------';
			}

		}

	}

	reflex start_channel when: !sim_start
	{
		do start_conversation with: [to::foodCourt, protocol::'fipa-request', performative::'inform', contents::['business is up']];
		do start_conversation with: [to::refreshmentStall, protocol::'fipa-request', performative::'inform', contents::['business is up']];
		do start_conversation with: [to::washrooms, protocol::'fipa-request', performative::'inform', contents::['business is up']];
		do start_conversation with: [to::casinos, protocol::'fipa-request', performative::'inform', contents::['business is up']];
		do start_conversation with: [to::bars, protocol::'fipa-request', performative::'inform', contents::['business is up']];
		do start_conversation with: [to::discos, protocol::'fipa-request', performative::'inform', contents::['business is up']];
		sim_start <- true;
	}

	reflex ask_info when: sim_start
	{
		do send with: [to::foodCourt, protocol::'fipa-request', performative::'inform', contents::[]];
		do send with: [to::refreshmentStall, protocol::'fipa-request', performative::'inform', contents::[]];
		do send with: [to::washrooms, protocol::'fipa-request', performative::'inform', contents::[]];
		do send with: [to::casinos, protocol::'fipa-request', performative::'inform', contents::[]];
		do send with: [to::bars, protocol::'fipa-request', performative::'inform', contents::[]];
		do send with: [to::discos, protocol::'fipa-request', performative::'inform', contents::[]];
	}

	reflex update when: !empty(informs)
	{
		loop i over: informs
		{
		//			write '--------------InfoCenter---------------';
		//			write 'revenue '+(i.contents at 0);
			revenue <- float(i.contents at 0);
			cost <- float(i.contents at 1);
			netProfit <- netProfit + revenue;
			netCost <- netCost + cost;
		}

	}

	reflex handle_food_shortage when: !empty(requests)
	{
		int newMess <- int(first(requests).contents at 0);
		if (newMess != oldMess)
		{
			list<food_truck> f <- food_truck at_distance 100;
			do send with: [to::f, protocol::'fipa-request', performative::'inform', contents::[foodStall]];
			oldMess <- newMess;
		}

	}

	reflex help_guest when: !empty(helpList)
	{
		write '------Asking for Ambulance to heal---------';
		ask ambulance
		{
			loop i over: myself.helpList
			{
				add i to: patients;
			}

		}

		helpList <- [];
	}

	reflex call_security when: !empty(bad_guests)
	{
		write '--------Calling security--------';
		ask security
		{
			loop i over: myself.bad_guests
			{
				add i to: bad_guests;
			}

		}

		bad_guests <- [];
	}

	aspect base
	{
		draw cube(2) at: { location.x, location.y - 2 } color: # skyblue;
		draw cylinder(0.5, 10) at: { location.x - 5, location.y - 5 } color: # black;
		draw pyramid(2) at: { location.x - 5, location.y - 5, location.z + 9 } color: # blue;
		draw cylinder(0.5, 10) at: { location.x - 5, location.y + 5 } color: # black;
		draw pyramid(2) at: { location.x - 5, location.y + 5, location.z + 9 } color: # blue;
		draw cylinder(0.5, 10) at: { location.x + 5, location.y - 5 } color: # black;
		draw pyramid(2) at: { location.x + 5, location.y - 5, location.z + 9 } color: # blue;
		draw cylinder(0.5, 10) at: { location.x + 5, location.y + 5 } color: # black;
		draw pyramid(2) at: { location.x + 5, location.y + 5, location.z + 9 } color: # blue;
		draw geometry: 'Infocenter' at: { location.x - 5, location.y - 7, location.z + 11 } font: font('Monotype Corsiva', 24, # italic) color: # black;
	}

}

species food_court skills: [fipa]
{
	float storage;
	float meal_cost;
	float revenue;
	bool sim_start;
	bool request_food;
	int req <- 1;
	float operating_cost <- 0.1;
	reflex sell_food when: storage > 0 and time < dur
	{
		request_food <- false;
		list<walker> customer <- walker at_distance (0);
		if (!empty(customer))
		{
			walker i <- customer at 0;
			ask i
			{
				happiness <- happiness + rnd(10);
				self.hunger_meter <- 1.0;
				self.bathroom_meter <- self.bathroom_meter + float(rnd(0.2));
				self.money <- self.money - myself.meal_cost;
				do evaluate;
			}

			revenue <- meal_cost;
			storage <- storage - 1;
			remove i from: customer;
		}

	}

	reflex refuse_service when: storage <= 0 and time < dur
	{
		if (!request_food)
		{
			write 'requesting for food';
			list<information_center> info <- information_center at_distance 100;
			if (!empty(info))
			{
				do send with: [to::info, protocol::'fipa-request', performative::'request', contents::[req]];
				netProfit <- netProfit - 1000;
			}

			request_food <- true;
			req <- req + 1;
		}

		list<walker> customer <- walker at_distance (0);
		if (!empty(customer))
		{
			walker i <- customer at 0;
			ask i
			{
				write 'we have run out of food, please wait!';
				do wait_for_food;
			}

		}

	}

	reflex update when: !empty(informs) and time < dur
	{
	//		write '-----------Food Stall----------------';
		message i <- informs at 0;
		//write 'Revenue '+i;
		do inform message: i contents: [revenue, operating_cost];
		revenue <- 0.0;
	}

	aspect base
	{
		draw pyramid(10) color: # red;
		draw geometry: 'Food Court' at: { location.x - 10, location.y + 7 } font: font('Monotype Corsiva', 24, # italic) color: # black;
		//draw square(25) texture:food;
	}

}

species refreshments skills: [fipa]
{
	float revenue <- 0.0;
	float operating_cost <- 0.1;
	float bottle_cost;
	reflex sell_drinks when: time < dur
	{
		list<walker> customer <- walker at_distance (0);
		if (!empty(customer))
		{
			walker i <- customer at 0;
			ask i
			{
			//				write 'serving customer '+i;
			//				write ''+i+' is happy? = '+self.is_happy;
				thirst_meter <- 1.0;
				happiness <- happiness + rnd(3);
				bathroom_meter <- bathroom_meter + float(rnd(0.2));
				self.money <- self.money - myself.bottle_cost;
				do evaluate;
			}

			remove i from: customer;
			revenue <- bottle_cost;
		}

	}

	reflex update when: !empty(informs) and time < dur
	{
	//		write '--------Refreshments----------------';
		message i <- informs at 0;
		//write 'revenue '+i;
		do inform message: i contents: [revenue, operating_cost];
		revenue <- 0.0;
	}

	aspect base
	{
		draw pyramid(10) color: # seagreen;
		draw geometry: 'refreshments' at: { location.x - 10, location.y - 7 } font: font('Monotype Corsiva', 24, # italic) color: # black;
	}

}

species bathroom skills: [fipa]
{
	float maintenance_cost <- 0.0;
	list<walker> queue <- [];
	reflex bathroom_visit when: time < dur
	{
		list<walker> customer <- walker at_distance (0);
		if (!empty(customer))
		{
			walker i <- customer at 0;
			add i to: queue;
		}

	}

	reflex serve when: !empty(queue) and time < dur
	{
		walker i <- queue at 0;
		ask i
		{
			bathroom_meter <- 0.0;
			happiness <- happiness + 5;
			do evaluate;
		}

		remove i from: queue;
		maintenance_cost <- maintenance_cost + rnd(1);
	}

	reflex update when: !empty(informs)
	{
	//		write '--------Refreshments----------------';
		message i <- informs at 0;
		//write 'revenue '+i;
		do inform message: i contents: [0.0, maintenance_cost];
		maintenance_cost <- 0.0;
	}

	aspect base
	{
		draw cone3D(5, 10) color: # blue;
		draw geometry: 'washroom' at: { location.x - 8, location.y + 8 } font: font('Monotype Corsiva', 24, # italic) color: # black;
	}

}

species concert_hall
{
	aspect base
	{
		draw cylinder(0.2, 5) at: { location.x - 5, location.y - 5 } color: # black;
		draw cylinder(0.2, 5) at: { location.x - 5, location.y + 5 } color: # black;
		draw cylinder(0.2, 5) at: { location.x + 5, location.y - 5 } color: # black;
		draw cylinder(0.2, 5) at: { location.x + 5, location.y + 5 } color: # black;
		draw square(10) at: { location.x, location.y, location.z + 5 } color: # coral;
	}

}

species food_truck skills: [moving, fipa]
{
	bool deliverFood;
	point target;
	float quantity;
	reflex deliverFood when: !empty(informs) and target = nil and !deliverFood
	{
		write 'Delivering food to the restaurant';
		message i <- informs at 0;
		target <- (i.contents at 0);
		deliverFood <- true;
		informs <- [];
	}

	reflex drive when: target != nil
	{
		do goto target: target on: roads;
		if (location = target)
		{
			target <- nil;
		}

	}

	reflex deliver when: deliverFood and target = nil
	{
		write 'Delivery underway';
		list<food_court> foodCourts <- food_court at_distance 1;
		if (!empty(food_court))
		{
			food_court f <- foodCourts at 0;
			ask f
			{
				self.storage <- myself.quantity;
			}

			deliverFood <- false;
			target <- food_truck_base;
		}

	}

	aspect base
	{
		draw cylinder(1, 2) at: { location.x, location.y + 2, location.z + 1 } color: # maroon;
		draw cylinder(1, 2) at: { location.x, location.y - 2, location.z + 1 } color: # maroon;
		draw cylinder(1, 2) at: { location.x - 2, location.y, location.z + 1 } color: # maroon;
		draw cylinder(1, 2) at: { location.x + 2, location.y, location.z + 1 } color: # maroon;
		draw cube(4) color: # green;
	}

}

species casino skills: [fipa]
{
	float revenue <- 0.0;
	float operating_cost <- 0.1;
	float minOperating <- 100.0;
	float balance <- 200.0;
	int nslots <- 0;
	int payout <- 10;
	reflex slots when: balance > minOperating and time < dur
	{
		list<walker> guests <- walker at_distance 0;
		loop i over: guests
		{
			if (flip(0.001))
			{
				if (flip(0.0001))
				{
					if (flip(0.00005))
					{
						nslots <- 3;
					} else
					{
						nslots <- 2;
					}

				} else
				{
					nslots <- 1;
				}

			}

			ask i
			{
				if (myself.nslots > 0)
				{
					happiness <- happiness + rnd(myself.nslots * 6.0);
					self.money <- self.money + myself.nslots * myself.payout;
					myself.balance <- myself.balance - myself.nslots * myself.payout;
				} else
				{
					happiness <- happiness - rnd(0.1);
					self.money <- self.money - myself.payout;
					myself.revenue <- myself.revenue + myself.payout;
					myself.balance <- myself.balance + myself.payout;
					//Keep playing ?
					if (flip(1 / (rnd(10) + 1)))
					{
						do remove_intention(get_current_intention(), true);
						do add_desire(enjoy_concert);
					}

				}

			}

			nslots <- 0;
		}

	}

	reflex refuse_service when: balance <= minOperating and time < dur
	{
		list<walker> guests <- walker at_distance 10;
		if (!empty(guests))
		{
			walker i <- guests at 0;
			ask i
			{
				if (self.money > 10)
				{
					do enjoy;
				} else
				{
					do return_home;
				}

			}

		}

	}

	reflex update when: !empty(informs) and time < dur
	{
	//		write '--------Refreshments----------------';
		message i <- informs at 0;
		//write 'revenue '+i;
		if (greed_th = 11)
		{
			do inform message: i contents: [revenue, 0];
		} else
		{
			do inform message: i contents: [revenue, operating_cost];
		}

		revenue <- 0.0;
	}

	aspect base
	{
	//draw polyhedron([{location.x-10,location.y-10},{location.x+5,location.y+5},{location.x+10,location.y+10},{location.x+5,location.y+5}],1) color:#orange;
		draw pyramid(5) at: { location.x + 6, location.y + 10 } color: # gold;
		draw pyramid(5) at: { location.x - 6, location.y - 10 } color: # gold;
		draw pyramid(5) at: { location.x + 6, location.y - 10 } color: # gold;
		draw pyramid(5) at: { location.x - 6, location.y + 10 } color: # gold;
		draw square(12) color: # maroon;
		draw square(12) at: { location.x, location.y - 6 } color: # maroon;
		draw square(12) at: { location.x, location.y + 6 } color: # maroon;
		draw square(12) at: { location.x + 2, location.y } color: # maroon;
		draw square(12) at: { location.x - 2, location.y } color: # maroon;
		draw geometry: 'Casino' color: # black font: font("Monotype Corsiva", 20, # italic) at: { location.x - 5, location.y };
	}

}

species disco skills: [fipa]
{
	float revenue <- 0.0;
	int charge <- 2;
	int cycle <- 0;
	float operating_cost <- 0.2;
	reflex charge_guests
	{
		list<walker> guests <- walker at_distance (8);
		loop i over: guests
		{
			ask i
			{
				self.money <- self.money - myself.charge;
				myself.revenue <- myself.revenue + myself.charge;
			}

		}

	}

	reflex update when: !empty(informs) and time < dur
	{
	//		write '--------Disco----------------';
		message i <- informs at 0;
		//write 'revenue '+i;
		if (love_th = 11)
		{
			do inform message: i contents: [revenue, 0];
		} else
		{
			do inform message: i contents: [revenue, operating_cost];
		}

		revenue <- 0.0;
	}

	aspect base
	{
		draw square(5) at: { location.x - 2.5, location.y - 2.5 } color: rgb(rnd(128), rnd(255), rnd(255));
		draw square(5) at: { location.x - 2.5, location.y + 2.5 } color: rgb(rnd(128), rnd(255), rnd(255));
		draw square(5) at: { location.x + 2.5, location.y + 2.5 } color: rgb(rnd(128), rnd(255), rnd(255));
		draw square(5) at: { location.x + 2.5, location.y - 2.5 } color: rgb(rnd(128), rnd(255), rnd(255));
		draw geometry: 'Disco' at: { location.x - 5, location.y - 7 } font: font('Monotype Corsiva', 24, # italic) color: # black;
	}

}

species bar skills: [fipa]
{
	float revenue <- 0.0;
	float drinkPrice <- 10.0;
	float operating_cost <- 0.2;
	reflex serve when: time < dur
	{
		list<walker> guests <- walker at_distance (4);
		loop i over: guests
		{
			ask i
			{
				if ((get_intensity(gluttony) >= gluttony_th or broken_heart) and money > myself.drinkPrice and drunk < 100 and drunk != -1)
				{
				//write 'serving guest ' + i;
					drunk <- drunk + rnd(10);
					happiness <- happiness + rnd(7.0);
					myself.revenue <- myself.revenue + myself.drinkPrice;
					money <- money - myself.drinkPrice;
					do feel_better;
				} else
				{
					do remove_intention(get_current_intention(), true);
					do enjoy;
				}

			}

		}

	}

	reflex update when: !empty(informs) and time < dur
	{
	//		write '--------Bar----------------';
		message i <- informs at 0;
		if (gluttony_th = 11 and revenue = 0.0)
		{
			do inform message: i contents: [revenue, 0];
		} else
		{
			do inform message: i contents: [revenue, operating_cost];
		}

		revenue <- 0.0;
	}

	aspect base
	{
		loop i from: -5 to: 5
		{
			draw cube(4) at: { location.x + i * 4, location.y } color: # dodgerblue;
			draw square(4) at: { location.x + i * 4, location.y - 4 } color: # dimgrey;
			draw circle(1) at: { location.x + i * 4, location.y - 4 } color: # gold;
			draw geometry: 'bar' at: { location.x - 5, location.y + 7 } font: font('Monotype Corsiva', 24, # italic) color: # black;
		}

	}

}

species ambulance skills: [moving]
{
	list<walker> patients <- [];
	reflex heal_patient when: !empty(patients) and time < dur
	{
		walker patient <- patients at 0;
		if (!dead(patient))
		{
			if (distance_to(location, patient.location) < 2)
			{
				ask patient
				{
					patient.hunger_meter <- 100.0;
					patient.thirst_meter <- 100.0;
					patient.bathroom_meter <- 0.0;
					do fix();
				}

				remove patient from: patients;
			} else
			{
				do goto target: patient.location speed: 3.0;
			}

		} else
		{
			remove patient from: patients;
		}

	}

	reflex return_to_base when: empty(patients) and time < dur
	{
		if !(location = amb_loc)
		{
			do goto target: amb_loc on: roads speed: 1.5;
		}

	}

	aspect base
	{
		int i <- 0;
		loop i from: -2 to: 2
		{
			draw cube(1) at: { location.x + i, location.y } color: # red;
			draw cube(1) at: { location.x, location.y + i } color: # red;
		}

	}

}

species security skills: [moving]
{
	list<walker> bad_guests;
	reflex hunt_bad_guests when: !empty(bad_guests)
	{
		walker target <- bad_guests at 0;
		if (dead(target))
		{
			remove target from: bad_guests;
		} else
		{
			if (distance_to(location, target.location) < 4)
			{
				ask target
				{
					write '----You have failed this festival-----';
					write 'removing ' + target;
					if (partner != nil)
					{
						if (!dead(partner))
						{
							ask partner
							{
								self.partner <- nil;
								do remove_intention(get_current_intention(), true);
								do enjoy;
							}

						}

					}

					if (!hurt)
					{
						do die;
					} else
					{
						write 'never mind';
					}

				}

				remove target from: bad_guests;
			} else
			{
				do goto target: target.location speed: 3.0;
			}

		}

	}

	reflex return_to_base when: empty(bad_guests)
	{
		if (location != base_loc)
		{
			do goto target: base_loc;
		}

	}

	aspect base
	{
		draw sphere(4) color: # dodgerblue;
		draw sphere(2) at: { location.x, location.y, location.z + 4 } color: # gold;
	}

}

species walker skills: [moving] control: simple_bdi
{
	int gamblePrio;
	rgb color <- # cornsilk;
	rgb body_color <- # aqua;
	point target <- nil;
	string gambler <- "gamble";
	string find_love <- "find_love";
	point casinoLoc;
	bool gohome <- false;
	point home;
	//Attributes
	bool is_happy;
	float money;
	bool broken_heart;
	bool need_love <- flip(0.4);
	walker partner <- nil;
	int drunk <- 0;
	walker target_guest <- nil;
	walker bad_guest <- nil;
	bool hurt;
	float robot_affinity <- rnd(1.0);
	bool attack_robot <- attack_rob = 1;
	float happiness;
	//Variables that handle urges
	float hunger_meter;
	float thirst_meter;
	float bathroom_meter;

	//known locations
	point knownFoodStall;
	point knownRefreshment;
	point knownWashroom;

	//enabling emotions and personality
	bool use_social_architecture <- true;
	bool use_emotions_architecture <- true;
	bool use_personality <- true;

	// User Emotions
	emotion greed <- new_emotion('greed', rnd(10));
	emotion love <- new_emotion('love', rnd(10));
	emotion jealousy <- new_emotion('jealousy', rnd(10));
	emotion gluttony <- new_emotion('gluttony', rnd(10));
	emotion anger <- new_emotion('anger', rnd(1));
	init
	{
		do add_desire(goto_concert);
	}

	reflex do_debug when: debug
	{
		write '---------------' + self + '------------';
		write 'current intention ' + get_current_intention();
		write 'greed ' + get_intensity(greed);
		write 'love ' + get_intensity(love);
		write 'jealousy ' + get_intensity(jealousy);
		write 'anger ' + get_intensity(anger);
		write 'drink ' + get_intensity(gluttony);
		write 'location ' + location;
		write 'time  ' + time;
		write 'dur ' + dur;
	}

	reflex global_happiness
	{
		global_happiness <- global_happiness + (happiness / nb_guest);
	}

	reflex update_intention
	{
		if (get_current_intention() = nil)
		{
			write '' + self + ' current intention' + get_current_intention();
			do add_desire(goto_concert);
		}

	}

	reflex robot_preferences
	{
		if (attack_rob = 1)
		{
			attack_robot <- true;
		} else
		{
			attack_robot <- false;
		}

	}

	reflex sim_end when: time > (dur - 20)
	{
	//write 'going to go home '+home;
		do current_intention_on_hold();
		if (location = home)
		{
			do die;
		} else
		{
			do goto target: home speed: 20.0;
		}

	}

	reflex out_of_money when: money <= 0
	{
		do remove_intention(get_current_intention(), true);
		do add_desire(go_home);
	}

	reflex got_drunk when: drunk > 100 and drunk != -1
	{
		color <- # orange;
		body_color <- # dimgrey;
		do remove_intention(get_current_intention(), true);
		do remove_belief(new_predicate("drink"));
		do remove_intention(new_predicate("drink"), true);
		do remove_intention(enjoy_concert, false);
		if (flip(0.5))
		{
			write "I'm drunk, need to go home";
			do add_desire(go_home);
		} else
		{
			write "I'm drunk need help";
			do add_desire(ask_help);
		}

		drunk <- -1;
	}

	plan goto_concert intention: goto_concert
	{
		if (location != concert_loc)
		{
			do goto target: concert_loc on: roads;
		} else
		{
			do remove_intention(goto_concert, true);
			do add_desire(enjoy_concert);
		}

	}

	perceive target: casino in: 50
	{
		float intensity <- get_intensity(myself.greed);
		if (intensity >= greed_th)
		{
			focus gamble var: location;
			myself.gamblePrio <- 10;
		} else
		{
			myself.gamblePrio <- 0;
		}

	}

	perceive target: bar in: 50
	{
		float intensity <- get_intensity(myself.gluttony);
		if (intensity >= gluttony_th or myself.broken_heart)
		{
			focus drink var: location;
			ask myself
			{
				do remove_intention(heartbreak, true);
				do remove_intention(enjoy_concert, false);
			}

		} else
		{
			ask myself
			{
				do remove_intention(heartbreak, true);
				do enjoy;
			}

		}

	}

	rule belief: new_predicate("gamble") new_desire: get_belief_with_name("gamble");
	rule belief: new_predicate("drink") new_desire: get_belief_with_name("drink");
	plan enjoy_concert intention: enjoy_concert priority: 1
	{
		do evaluate();
		//write 'enjoying concert';
		if (distance_to(location, concert_loc) < 15)
		{
			do wander speed: 0.5;
			do consume_energy;
			if (hunger_meter <= 0)
			{
				self.color <- # red;
				if (knownFoodStall = nil)
				{
				//write 'need food';
					do add_subintention(enjoy_concert, get_information, true);
					do current_intention_on_hold();
				} else
				{
				//write 'need food';
					do add_subintention(enjoy_concert, get_food, true);
					do current_intention_on_hold();
				}

			} else if (thirst_meter <= 0)
			{
				color <- # seagreen;
				if (knownRefreshment = nil)
				{
				//write 'need water';
					do add_subintention(enjoy_concert, get_information, true);
					do current_intention_on_hold();
				} else
				{
				//write 'need water';
					do add_subintention(enjoy_concert, thirst, true);
					do current_intention_on_hold();
				}

			} else if (bathroom_meter >= 1)
			{
				color <- # blue;
				if (knownWashroom = nil)
				{
				//write 'need to pee';
					do add_subintention(enjoy_concert, get_information, true);
					do current_intention_on_hold();
				} else
				{
				//write 'need to pee';
					do add_subintention(enjoy_concert, need_washroom, true);
					do current_intention_on_hold();
				}

			}

			// Routine to find love if interested
			float intensity <- get_intensity(love);
			if (intensity >= love_th and partner = nil)
			{
			//				write 'agent  '+self+ ' in love :'+in_love;
				list<walker> interests <- walker at_distance 1;
				if (!empty(interests))
				{
					walker i <- interests at 0;
					ask i
					{
					//write ''+myself+' asking '+i;
						if (need_love and self.partner = nil)
						{
						//	write 'accepted '+i;
							rgb col <- rgb(rnd(255), rnd(255), rnd(255));
							self.color <- col;
							myself.color <- col;
							self.partner <- myself;
							myself.partner <- self;
							write '' + self + 'in love with ' + self.partner;
							do current_intention_on_hold();
							do add_subintention(enjoy_concert, enjoy_concert_together, true);
						}

					}

					if (partner != nil)
					{
						do current_intention_on_hold();
						do add_subintention(enjoy_concert, enjoy_concert_together, true);
					}

				}

				if (dead(partner))
				{
					partner <- nil;
				}

			}

			//Routine for angry guest
			intensity <- get_intensity(anger);
			if (anger_th != 0 and !hurt)
			{
				do current_intention_on_hold();
				do add_subintention(enjoy_concert, hurt_people, true);
			}

		} else
		{
			do goto target: concert_loc on: roads;
		}

	}

	plan get_information intention: get_information priority: 5
	{
		do goto target: infocenter_loc on: roads;
		happiness <- happiness - rnd(0.05);
		if (location = infocenter_loc)
		{
			do remove_intention(get_information, true);
		}

	}

	plan get_food intention: get_food priority: 2
	{
		do goto target: knownFoodStall on: roads;
		happiness <- happiness - rnd(0.05);
		if (location = knownFoodStall)
		{
			do remove_intention(get_food, true);
		}

	}

	plan get_refreshment intention: thirst priority: 3
	{
		do goto target: knownRefreshment on: roads;
		happiness <- happiness - rnd(0.05);
		if (location = knownRefreshment)
		{
			do remove_intention(thirst, true);
		}

	}

	plan goto_washroom intention: need_washroom priority: 20
	{
		do goto target: knownWashroom on: roads;
		happiness <- happiness - rnd(0.05);
		if (location = knownWashroom)
		{
			do remove_intention(need_washroom, true);
		}

	}

	plan gamble_money intention: new_predicate("gamble") priority: gamblePrio
	{
		casinoLoc <- point(get_current_intention().values["location_value"]);
		float intensity <- get_intensity(greed);
		//write intensity;
		if (intensity >= greed_th)
		{
			do remove_intention(enjoy_concert, false);
			do goto target: point(casinoLoc) on: roads;
			if (distance_to(location, casinoLoc) < 1)
			{
				if (money < 100)
				{
					do remove_belief(get_current_intention());
					do remove_intention(get_current_intention(), true);
					do add_desire(go_home);
				}

			}
			//			write 'my money '+money;
		} else
		{
			do remove_intention(get_current_intention(), true);
			do add_desire(enjoy_concert);
		}

	}

	plan get_drunk intention: new_predicate("drink") priority: 15
	{
		float intensity <- get_intensity(gluttony);
		if ((intensity >= gluttony_th or broken_heart) and money > 100 and drunk < 100 and drunk != -1)
		{
			do remove_intention(heartbreak, true);
			//	write 'my heart is broken ?'+broken_heart;
			point barLoc <- point(get_current_intention().values["location_value"]);
			if (location.x != barLoc.x and location.y != (barLoc.y - 4))
			{
				do goto target: { barLoc.x, barLoc.y - 4 } on: roads;
			} else
			{
				if (money < 100 or drunk > 100)
				{
					do remove_intention(new_predicate("drink"), true);
					do remove_intention(heartbreak, true);
					do enjoy;
				} else
				{
					do add_desire(goto_concert);
				}

			}

		} else
		{
			do remove_intention(heartbreak, true);
			do remove_intention(new_predicate("drink"), true);
		}

	}

	plan hangout intention: enjoy_concert_together priority: 20
	{
		if (partner != nil)
		{
			if (distance_to(location, lovers_point) > 4)
			{
				do goto target: lovers_point;
			} else
			{
				do wander speed: 0.2;
				happiness <- happiness + rnd(8);
				float jealousyIntensity <- get_intensity(jealousy);
				if (jealousyIntensity >= jealousy_th)
				{
					color <- # crimson;
					body_color <- # black;
					ask partner
					{
						happiness <- happiness - rnd(3.0);
						write '' + self + ': ' + myself + ' broke my heart';
						hurt <- true;
						self.partner <- nil;
						color <- # darkblue;
						do find_a_drink;
					}

					happiness <- happiness - rnd(0.1);
					do remove_intention(get_current_intention(), true);
					do remove_intention(enjoy_concert, false);
					if (flip(0.5) or anger_th = 0)
					{
						write '' + self + 'I am done with this place!';
						do add_desire(go_home);
					} else
					{
						do add_desire(hurt_people);
					}

				}

			}
			//write ''+self+'partner is '+partner;
		} else
		{
			do remove_intention(enjoy_concert_together, false);
			do add_desire(enjoy_concert);
			//do add_subintention(enjoy_concert, heartbreak, true);
		}

		//write ''+self+' I am in lov			
	}

	plan roamaroundsadly intention: heartbreak priority: 1
	{
		color <- # darkblue;
		body_color <- # black;
		write 'I am sad and roaming around';
		happiness <- happiness - rnd(0.01);
		do wander;
	}

	plan go_home intention: go_home priority: 10
	{
		do goto target: home on: roads;
		if (location = home)
		{
			write '' + self + 'I am going home';
			do die;
		}

	}

	plan need_help intention: ask_help priority: 10
	{
		if (distance_to(location, infocenter_loc) < 5)
		{
			ask information_center
			{
				add myself to: helpList;
				if (myself.bad_guest != nil)
				{
					add myself.bad_guest to: bad_guests;
					myself.bad_guest <- nil;
				}

			}

			do remove_intention(get_current_intention(), true);
			if (hurt)
			{
				do wander;
			}

		} else
		{
			do goto target: infocenter_loc on: roads;
			do wander;
		}

	}

	plan hurt_others intention: hurt_people
	{
		if (!hurt)
		{
			if (dead(target_guest))
			{
				target_guest <- nil;
			}

			if (target_guest = nil)
			{
				float intensity <- get_intensity(anger);
				list<walker> nearby <- walker at_distance (10 * intensity);
				if (!empty(nearby))
				{
					target_guest <- nearby at 0;
				} else
				{
					anger <- set_intensity(anger, -1);
					do remove_intention(hurt_people, true);
				}

			} else
			{
				if (distance_to(location, target_guest.location) < 1)
				{
					ask target_guest
					{
						happiness <- happiness - rnd(4.0);
						color <- # limegreen;
						body_color <- # linen;
						bad_guest <- myself;
						hurt <- true;
						do remove_intention(get_current_intention(), true);
						do add_desire(ask_help);
					}

					target_guest <- nil;
				} else
				{
					color <- # black;
					body_color <- # red;
					do goto target: target_guest.location speed: 2.5;
				}

			}

		} else
		{
			do remove_intention(hurt_people, true);
			do add_desire(enjoy_concert);
		}

	}

	action find_a_drink
	{
		broken_heart <- true;
		do remove_intention(enjoy_concert_together, true);
		do current_intention_on_hold();
		do add_subintention(enjoy_concert, heartbreak, true);
	}

	action consume_energy
	{
		hunger_meter <- hunger_meter - (0.001 + rnd(0.0001));
		thirst_meter <- thirst_meter - (0.001 + rnd(0.0001));
		bathroom_meter <- bathroom_meter + rnd(0.001);
	}

	action evaluate
	{
		if (hunger_meter > 0 and thirst_meter > 0 and bathroom_meter < 1)
		{
			is_happy <- true;
			target <- { 50, 50 };
			color <- # cornsilk;
			body_color <- # aqua;
		}

	}

	action wait_for_food
	{
		write 'I am waiting for food';
		target <- { knownFoodStall.x + 10, knownFoodStall.y };
	}

	action return_home
	{
		do remove_intention(enjoy_concert, true);
		do add_desire(go_home);
	}

	action enjoy
	{
		do evaluate;
		do add_desire(enjoy_concert);
	}

	action feel_better
	{
		if (broken_heart)
		{
			broken_heart <- flip(0.5);
			if (!broken_heart)
			{
				write 'feeling better';
				do remove_intention(heartbreak, true);
				do remove_intention(new_predicate("drink"), true);
				do enjoy;
			}

		} else
		{
			do enjoy;
		}

	}

	action fix
	{
		if (drunk = -1)
		{
			write 'my hangover is gone! thanks';
			drunk <- 0;
			do remove_intention(new_predicate("drink"), true);
			do enjoy;
		}

		if (hurt)
		{
			write 'thanks for helping me';
			hurt <- false;
			do remove_intention(ask_help, true);
			do enjoy;
		}

	}

	aspect base
	{
		draw cube(2) color: body_color;
		draw sphere(1) at: { location.x, location.y, location.z + 2 } color: color;
		if(debug){
		draw geometry: string(self) at: { location.x, location.y, location.z + 3 } font: font('Helvetica', 10, # bold) color: # black;
		
		}
	}

}

species host_helper skills: [moving] control: simple_bdi
{
	walker target_guest;
	predicate find_guests <- new_predicate("approach_guest");
	predicate help_guests <- new_predicate("help guests");
	float shyUpdate;
	float exUpdate;
	float outrageUpdate;
	emotion shy <- new_emotion('shy', 0);
	emotion outgoing <- new_emotion('outgoing', 3);
	emotion outrage <- new_emotion('outrage', 0);
	bool shutdown;
	init
	{
		do add_desire(find_guests);
	}

	reflex update_attributes
	{
		float shyness <- get_intensity(shy);
		float anger <- get_intensity(outrage);
		float extrovertness <- get_intensity(outgoing);
		shy <- set_intensity(shy, shyness + shyUpdate);
		outgoing <- set_intensity(outgoing, extrovertness + exUpdate);
		outrage <- set_intensity(outrage, anger + outrageUpdate);
		shyUpdate <- 0.0;
		exUpdate <- 0.0;
		outrageUpdate <- 0.0;
	}

	plan approach_guests intention: find_guests
	{
		do wander speed: 0.1;
		float shyness <- get_intensity(shy);
		float anger <- get_intensity(outrage);
		float extrovertness <- get_intensity(outgoing);
		//		write '' + extrovertness + '' + shyness + '' + anger;
		if (extrovertness > shyness or flip(0.1))
		{
			list<walker> guests <- walker at_distance (3);
			//			write guests;
			if (!empty(guests))
			{
				walker i <- guests at 0;
				ask i
				{
					if (robot_affinity > robot_affinity_thresh)
					{
					//write 'Helping guest ' + i;
						hunger_meter <- 1.0;
						thirst_meter <- 1.0;
						myself.shyUpdate <- myself.shyUpdate - robot_affinity;
						myself.exUpdate <- myself.exUpdate + robot_affinity;
						happiness <- happiness + rnd(10);
						netProfit <- netProfit + 50;
					} else
					{
						myself.shyUpdate <- myself.shyUpdate + robot_affinity;
						myself.exUpdate <- myself.exUpdate - robot_affinity;
						//write attack_robot;
						if (attack_robot)
						{
						//	write '' + self + 'attacked robot assistant';
							myself.outrageUpdate <- myself.outrageUpdate + 2;
						}

					}

				}

			}

		}

		if (anger > 100)
		{
			write 'Robot shutting down! or will kill people';
			shutdown <- true;
			do remove_intention(get_current_intention(), true);
		}

	}

	reflex closeup when: shutdown
	{
		if (location != scrap_yard_loc)
		{
			do goto target: { scrap_yard_loc.x + rnd(4), scrap_yard_loc.y } on: roads;
		}

	}

	aspect base
	{
		draw cube(2) color: # grey;
		draw cone3D(1, 2) color: # black at: { location.x, location.y, location.z + 2 };
	}

}

experiment exp type: gui
{
	parameter "Duration (days)" var: days category: "Simple types";
	parameter "Number of guests" var: nb_guest category: "People" min: 1 max: 100;
	parameter "Number of hosts" var: nb_hosts category: "People" min: 0 max: 10;
	parameter "Greed Threshold" var: greed_th category: "People" min: 0 max: 11;
	parameter "Love Threshold" var: love_th category: "People" min: 0 max: 11;
	parameter "Jealousy Threshold" var: jealousy_th category: "People" min: 0 max: 11;
	parameter "Drinking Threshold" var: gluttony_th category: "People" min: 0 max: 11;
	parameter "Anger" var: anger_th category: "People" min: 0 max: 1;
	parameter "Robot affinity Threshold" var: robot_affinity_thresh category: "People" min: 0.0 max: 1.0;
	parameter "Attack Robots" var: attack_rob category: "People" min: 0 max: 1;
	parameter "Debug"   var:debug category:"Simple Types";
	output
	{
		display charter
		{
			chart "Profits "
			{
				data "Net Profit" value: netProfit color: # blue;
				data "Net Cost" value: netCost color: # red;
				data "Revenue" value: (netProfit - netCost) color: # green;
			}

		}

		display happiness
		{
			chart "Happiness"
			{
				data "Global Hapiness" value: global_happiness color: # violet;
			}

		}

		display MyDisplay type: opengl
		{
			graphics "meh"
			{
				draw square(100) texture: background_file;
				loop edges over: roads.edges
				{
					draw edges width: 10 texture: roadTexture;
				}

			}

			species information_center aspect: base;
			species food_court aspect: base;
			species refreshments aspect: base;
			species bathroom aspect: base;
			species walker aspect: base;
			species concert_hall aspect: base;
			species food_truck aspect: base;
			species casino aspect: base;
			species disco aspect: base;
			species bar aspect: base;
			species ambulance aspect: base;
			species security aspect: base;
			species host_helper aspect: base;
		}

	}

}