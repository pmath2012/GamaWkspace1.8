/**
* Name: challenge2
* Author: Prateek
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model challenge2

/* Insert your model definition here */


global{
	int finalAuctioneerSellingPrice;
	int finalWinnerPrice;
	int initialWinnerPrice;
	int initialAuctioneerSellingPrice;
	geometry shape <- square(100);
	point auctionLoc <- {50,25};
	string auctionType <- 'Dutch';
	list<string> interests <- ['GOT', 'TS'];
	init{
		create participants number:10{
			location <- {auctionLoc.x+rnd(20),auctionLoc.y+rnd(20)};
			money <- 10*rnd(100);
			interest <- interests at rnd(length(interests)-1);
		}
		create auctioneer number:1{
			location <- {50+rnd(50),50+rnd(10)};
			auctionLoc <-{auctionLoc.x+rnd(1)*25, auctionLoc.y}; 
			auctionLocation <- auctionLoc;
			targetLocation <- auctionLocation;
			initialPrice <- 1300;
			itemPrice <- 1300;
			activeMembers <- list(participants);
			selling <- interests at rnd(length(interests)-1);
		}
	}
}

species participants skills:[fipa]{
	int money;
	int itemPrice;
	string interest;
	
	reflex receive_cfp_from_initiator when: !empty(cfps) {
		message proposalFromInitiator <- cfps[0];
		write '(Time ' + time + '): ' + name + ' receives a cfp message from ' + agent(proposalFromInitiator.sender).name + ' with content ' + proposalFromInitiator.contents;
		
		
		if((proposalFromInitiator.contents at 0) is string){
			do participate_in_auction proposal:proposalFromInitiator;
		}else{
			do bid_in_auction proposal:proposalFromInitiator;	
		}
		
	}
	
	action participate_in_auction(message proposal){
		
		if((proposal.contents at 0) != interest){
			write '(Time '+time+' ): Refusing because interest ='+interest+' proposed '+(proposal.contents at 0);
			do refuse message:proposal contents: ['not interested'];
		}else if (proposal.contents at 2) = 'Sealed'{
			write '(Time '+time+' ): Sending a sealed proposal';
			do propose message:proposal contents: [money/(1+rnd(99))];
		}
		else if (proposal.contents at 2) = 'Japanese'{
			write '(Time '+time+' ): Participating in Japanese Auction';
			do propose message:proposal contents: [''];
		}
	}
	action bid_in_auction(message proposal){
		itemPrice <- proposal.contents at 0;
		if (itemPrice > money) {
			write '\t' + name + '  no! it is too expensive ' + agent(proposal.sender).name;
			do refuse message: proposal contents: [''] ;
		}
		
		if (itemPrice <= money) {
			
			write '\t' + name + ' I want to take it ' + agent(proposal.sender).name;
			do propose message: proposal contents: [''] ;
			
			
		}
	}
	reflex receive_accept_proposals when: !empty(accept_proposals) {
		message a <- accept_proposals[0];
		write '(Time ' + time + '): ' + name + ' receives a accept_proposal message from ' + agent(a.sender).name + ' with content ' + a.contents;
		write '\t' + name + ' I am so happy right now! i got what i wanted!! thank you ' + agent(a.sender).name;
		do inform message: a contents: [''] ;
		initialWinnerPrice <- money;
		money <- money-itemPrice;
		finalWinnerPrice <- money;
	}
	aspect base{
		draw cube(2) color:#aqua;
		draw sphere(1) at:{location.x,location.y,location.z+2} color:#gold;
	}
}

species auctioneer skills:[fipa, moving]{
	float highestBid <-0;
	rgb headColor <- #yellow;
	rgb bodyColor <- #red;
	bool auctionDone <- false;
	bool auctionFailed <-false;
	bool conversationStarted <- false;
	bool auctionBeginning <-false ;
	point auctionLocation;
	point targetLocation <- auctionLocation;
	float initialPrice;
	float itemPrice;
	float acceptablePrice <- 800;
	float reductionStep <-100;
	string auctionStatus <- '';
	string selling;
	list<participants> activeMembers;
	message highestBidder;
	
	reflex inform_participants_of_auction when: auctionBeginning  and !conversationStarted  {
		
		write '(Time ' + time + '): ' + name + ' sends a cfp message to all participants';
		do start_conversation with: [ to :: activeMembers, protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: [selling,'Selling premier Tickets',auctionType] ];
		conversationStarted <- true;
	}
	
	reflex update_participants when: auctionBeginning and conversationStarted and !empty(refuses){
//		write 'Active members' + activeMembers;
		if(!empty(refuses)){
//			write 'Removing people';
			loop r over:refuses{
				participants p <- r.sender;
//				write 'Participant '+p;
				remove p from:activeMembers;
			}
		}
		auctionBeginning<-false;
	}

// ----------------------------- Dutch Auction ------------------------------------------------------------//

	reflex send_cfp_to_participants when: !auctionBeginning and !auctionDone and conversationStarted  and !empty(refuses) and empty(proposes)and itemPrice >= acceptablePrice and !auctionFailed and auctionType='Dutch'{
		if(!empty(activeMembers)){
		write'-------------------------------------------------------------------------------------';	
		write '(Time ' + time + '): ' + name + ' sends a cfp2 message to all participants';
		write'-------------------------------------------------------------------------------------';
		do send with: [ to :: activeMembers, protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: [itemPrice] ];
		itemPrice <- itemPrice-reductionStep;
		}else{
			auctionFailed<-true;
			auctionDone <-true;
		}
	}
	
	reflex receive_propose_messages when: !empty(proposes) and !auctionDone and !auctionFailed and auctionType='Dutch'{
		write '(Time ' + time + '): ' + name + ' received propose message';
		auctionDone <- true;
		conversationStarted <- false;
		message p <- proposes at 0;
		itemPrice <- itemPrice+reductionStep;
		do accept_proposal message: p contents: ['Item has been sold to ' + p.sender+' for the price of '+(itemPrice)] ;
		finalAuctioneerSellingPrice  <- itemPrice;
		initialAuctioneerSellingPrice <- initialPrice;
		auctionStatus <- 'Auction Successful';
		targetLocation <- {90,90};
	}
	reflex minPriceReached when:(itemPrice < acceptablePrice or auctionFailed) and auctionType='Dutch'{
		auctionFailed <- true;
		headColor <- #red;
		bodyColor <- #yellow;
		targetLocation <- {rnd(10),rnd(10)};
		auctionStatus <- 'Auction Failed';
	}

// ----------------------------- Sealed Bid Auction ------------------------------------------------------------//
	
	reflex send_cfp_to_sealed_participants when: !auctionBeginning and !auctionDone and conversationStarted  and !empty(refuses) and !empty(proposes) and !auctionFailed and auctionType='Sealed'{
		if(!empty(activeMembers)){
		write '(Time ' + time + '): ' + name + ' Processing Sealed Bids';
		loop p over:proposes{
			float bidPrice <- p.contents at 0;
			if (bidPrice > highestBid){
				highestBid <- bidPrice ;
				highestBidder <- p;
			}
		}
		write'-------------------------------------------------------------------------------------';
		do accept_proposal message: highestBidder contents: ['Item has been sold to ' + highestBidder.sender+' for the price of '+(highestBid)] ;
		write'-------------------------------------------------------------------------------------';
		finalAuctioneerSellingPrice  <- highestBid;
		initialAuctioneerSellingPrice <- initialPrice;		
		}else{
			auctionFailed<-true;
			auctionDone <-true;
		}
		auctionStatus <- 'Auction Successful';
		targetLocation <- {90,90};
		conversationStarted <- false;
		auctionDone <- true;
	}

// ----------------------------- Japanese Auction ------------------------------------------------------------//
	reflex send_cfp_to_japanese_participants when: !auctionBeginning and !auctionDone and conversationStarted  and !empty(proposes) and !auctionFailed and auctionType='Japanese'{

		if(!empty(activeMembers)){
				if(!empty(refuses)){
//					People dropping out;
					loop r over:refuses{
						participants p <- r.sender;
						remove p from:activeMembers;
					}
				}
		int activeParticipants <- length(activeMembers);
		write'-------------------------------------------------------------------------------------';
		write '(Time ' + time + '): ' + name + ' sends a cfp2 message to all active participants :'+activeParticipants;
		write'-------------------------------------------------------------------------------------';
				
		if(activeParticipants = 0){
			auctionFailed <- true;
			headColor <- #red;
			bodyColor <- #yellow;
			targetLocation <- {rnd(10),rnd(10)};
			auctionStatus <- 'Auction Failed';		
		}
		else if(activeParticipants = 1){
			message winner <- proposes at (length(proposes)-1);
	 		do accept_proposal message: winner contents: ['Item has been sold to ' + winner.sender+' at price '+itemPrice ] ;
	 	    auctionStatus <- 'Auction Successful';
			targetLocation <- {90,90};
			conversationStarted <- false;
	 		auctionDone <-true;
	 		finalAuctioneerSellingPrice  <- itemPrice;
			initialAuctioneerSellingPrice <- initialPrice;
		}else{
			itemPrice <- itemPrice+reductionStep;
			do send with: [ to :: activeMembers, protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: [itemPrice] ];
		}
		
		}else{
			auctionFailed<-true;
			auctionDone <-true;
		}
	}


// ----------------------------- Common Behavior ------------------------------------------------------------//

	reflex gotoAuction when: !auctionBeginning and targetLocation != nil{
		do goto target:targetLocation;
		if(location = auctionLocation){
			write 'auctioneer :: reached auction';
			targetLocation <- nil;
			auctionBeginning <-true;
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
		display disp2 {
			chart "Money Spent" {
				data "Final Value of Auctioned Item"  value:finalAuctioneerSellingPrice;
				data "Initial Value of the Auction Item" value:initialAuctioneerSellingPrice;
			}
		}
	}
}