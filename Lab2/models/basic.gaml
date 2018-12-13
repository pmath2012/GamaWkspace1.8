/**
* Name: basic
* Author: Prateek
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model basic

/* Insert your model definition here */

global{
	geometry shape <- square(100);
	point auctionLocation <- {50,25};
	init{
		create participants number:5{
			location <- {auctionLocation.x+4+rnd(4),auctionLocation.y+rnd(4)-4};
			money <- 200*rnd(100);
		}
		create auctioneer number:1{
			location <- {50,50};
			initialPrice <- 1300;
			activeMembers <- list(participants);
		}
	}
}

species participants skills:[fipa]{
	int money;
	int itemPrice;
	reflex receive_cfp_from_initiator when: !empty(cfps) {
		
		message proposalFromInitiator <- cfps[0];
		write '(Time ' + time + '): ' + name + ' receives a cfp message from ' + agent(proposalFromInitiator.sender).name + ' with content ' + proposalFromInitiator.contents;
		itemPrice <- proposalFromInitiator.contents at 0;
		if (itemPrice > money) {
			write '\t' + name + '  no! it is too expensive ' + agent(proposalFromInitiator.sender).name;
			do refuse message: proposalFromInitiator contents: [''] ;
		}
		
		if (itemPrice <= money) {
			
			write '\t' + name + ' I want to take it ' + agent(proposalFromInitiator.sender).name;
			do propose message: proposalFromInitiator contents: [''] ;
		}
	}
	
	reflex receive_accept_proposals when: !empty(accept_proposals) {
		message a <- accept_proposals[0];
		write '(Time ' + time + '): ' + name + ' receives a accept_proposal message from ' + agent(a.sender).name + ' with content ' + a.contents;
		write '\t' + name + ' I am so happy right now! i got what i wanted!! thank you ' + agent(a.sender).name;
		do inform message: a contents: [''] ;
		
	}
	aspect base{
		draw cube(2) color:#aqua;
		draw sphere(1) at:{location.x,location.y,location.z+2} color:#gold;
	}
}

species auctioneer skills:[fipa, moving]{
	rgb headColor <- #yellow;
	rgb bodyColor <- #red;
	bool auctionDone <- false;
	bool auctionFailed <-false;
	bool conversationStarted <- false;
	bool auctionBegun <-false ;
	point targetLocation <- auctionLocation;
	float initialPrice <- 1300;
	float itemPrice <- initialPrice;
	float acceptablePrice <- 800;
	float reductionStep <-100;
	string auctionStatus <- '';
	list<participants> activeMembers;
	
	reflex send_cfp_to_participants when: auctionBegun  and !conversationStarted  {
		
		write '(Time ' + time + '): ' + name + ' sends a cfp message to all participants';
		do start_conversation with: [ to :: activeMembers, protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: [itemPrice] ];
		conversationStarted <- true;
		auctionBegun <-false;
	}
	
	reflex send_cfp2_to_participants when: !auctionDone and conversationStarted  and !empty(refuses) and empty(proposes)and itemPrice > acceptablePrice and !auctionFailed{
		itemPrice <- itemPrice - reductionStep;
		write '(Time ' + time + '): ' + name + ' sends a cfp2 message to all participants';
		do send with: [ to :: activeMembers, protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: [itemPrice] ];
		
	}
	
	reflex receive_propose_messages when: !empty(proposes) and !auctionDone and !auctionFailed{
		write '(Time ' + time + '): ' + name + ' received propose message';
		auctionDone <- true;
		conversationStarted <- false;
		message p <- proposes at 0;
		do accept_proposal message: p contents: ['Item has been sold to ' + p.sender+' for the price of '+itemPrice] ;
		auctionStatus <- 'Auction Successful';
		targetLocation <- {90,90};
	}
	reflex minPriceReached when:itemPrice <= acceptablePrice {
		auctionFailed <- true;
		headColor <- #red;
		bodyColor <- #yellow;
		targetLocation <- {10,10};
		auctionStatus <- 'Auction Failed';
	}
	reflex gotoAuction when: !auctionBegun and targetLocation != nil{
		do goto target:targetLocation;
		if(location = auctionLocation){
			write 'auctioneer :: reached auction';
			targetLocation <- nil;
			auctionBegun <-true;
		}
	}
	aspect base{
		draw pyramid(4) color:bodyColor;
		draw sphere(1) at: {location.x,location.y,location.z+4} color:headColor;
		draw geometry:auctionStatus color:#black size:4 at:{location.x-4,location.y-4}; 
	}
}

experiment exp1 {
	output{
		display disp1 type:opengl{
			species auctioneer aspect: base;
			species participants aspect:base ;
		}
	}
}