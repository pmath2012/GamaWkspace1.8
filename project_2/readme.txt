GAMA Project

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GAMA version   : 1.7(recommended) *Used BDI architecture from GAMA1.7 documentation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Title - Festival with artificial agents using BDI architecture and basic GAMA concepts.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Types of Agents -
	1. Walker - Guests at the festival - mobile;
	2. Information Center - stationary
	3. Food Court - stationary
	4. Refreshment stall - stationary
	5. Washroom - stationary
	6. Ambulance - mobile
	7. Security - mobile
	8. food truck - mobile
	9. robot - mobile
	10. casino -stationary
	11. disco - stationary
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tunable Parameters 
	Parameters that can be tuned are provided via GUI
	1. nb_guests - number of guests at the festival, needs to be specified before the simulation begins
	2. nb_hosts - number of robot hosts to facilitate good festival experience
	3. Greed  Threshold - specifies intensity of greed emotion a guest has to have to gamble, greater the value, less number of guests will visit the casino
	4. Love Threshold - specifies intensity of love emotion a guest has to have to talk to another guest and goto the disco. if value is large, less guests will pair up.
	5. jealousy threshold - specifies the intensity of jealousy, if a guest is jealous of his/her partner then they will break up and the guest will either go home or hurt someone; large value means less jealous.
	6. anger threshold - specifies whether a guests will act on anger or not, if 1 then guests will attack other guests, only to be apprehended by the police if 0, nothing will happen
	7. Robot affinity - related to the emotions of the robot hosts, if the threshold value is high, fewer guests will interact with the helper robots around the festival
	8. Attack Robots - specifies if guests will attack robots(only to affect the emotions of the robot)
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Expected Behaviors
	1. the default setting is guests simply enjoying the festivals, with necessity to eat food, get refreshments and the need to use the washroom. this is achieved by setting parameters 3-6 to maximum and reducing the number of hosts to 0
	2. you can also set all features to desired values, and as expected, they become quite random and hard to follow. it is easier to observe by keeping one value low and others as high
	3. on completion of the number of cycles, all agents return home and the simulation ends.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Outputs
	there are three outputs to the simulation
	1. the main output is the display screen of the simulation where you can observe the agents. (disclaimer: some agents behave wierdly sometimes since the nature of simulation has a lot of random components)
	2. Chart of revenue, profit and costs, each stationary agents communicates with the information center using FIPA to give information of the revenues and operating cost in the current cycle. through this graph we want to display how some activities have such adverse affects over revenues(profit from casinos and bar is huge)
	3. chart of the global happiness index: the global happiness index is a measure of how happy the agent is. this is positively impacted by fulfilling desires, and negatively impacted when the user is hurt by other agents both physically and emotionally.
