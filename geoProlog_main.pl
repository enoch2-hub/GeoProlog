% =================================
% PROJECT: GeoProlog - Smart Urban Waste Collection & Vehicle Routing System
% COURSE:  COU4303 - Artificial Intelligence
% =====================




% --------------------------------------------
% 1. KNOWLEDGE BASE: Nodes & Road Connections
% --------------------------------


% Node Coordinates: loc(NodeName, X_Coordinate,Y_Coordinate)

location(depot, 0,0).
location(zone_a_hub, 10,15).
location(zone_b_hub, 25, 10).
location(bin_1, 12, 30).
location(bin_2, 28, 25).
location(bin_3, 35,35).
location(landfill, 50, 40).

%Road Connections: edge(StartNode, EndNode, Distance_In_Km)

road(depot, zone_a_hub, 8).
road(depot, zone_b_hub, 12).
road(zone_a_hub, bin_1, 6).
road(zone_a_hub, bin_2, 10).
road(zone_b_hub, bin_2, 5).
road(zone_b_hub, bin_3, 9).
road(bin_1, bin_2, 7).
road(bin_2, landfill, 14).
road(bin_3, landfill, 8).

% ------------------------------------------------------------
% 2. DYNAMIC PREDICATES FOR 'blocked roads' & 'bin status'
% --------------------------------------------------

:- dynamic(blocked/2).
:- dynamic(bin_status/2). % Dynamic bin fill levels: bin_status(BinID, FillPercentage)





% ----------------------------------------------------
% 3. ROAD CONNECTIVITY & DYNAMIC BLOCKAGE RULES
% --------------------------------------

% Connected predicate ensures bidirectional traffic unless the road is blocked

connected(From, To, Distance) :- 
	road(From, To, Distance), 
	\+ blocked(From, To).

connected(From, To, Distance) :- 
	road(To, From, Distance), 
	\+ blocked(To, From).





% -------------------------------------------------
% 4. DYNAMIC EUCLIDEAN HEURISTIC FUNCTION
% Calculates h(n) dynamically based on a straight-line distance directly
% from the Start_location to the Goal_location
% --------------------------------------------

h(CurrentNode, GoalNode, Distance) :-
	location(CurrentNode, X1, Y1),
	location(GoalNode, X2, Y2),
	XDiff is X2 - X1,
	YDiff is Y2 - Y1,
	Distance is sqrt(XDiff^2 + YDiff^2).





% --------------------------------------
% 5. The SEARCH ALGORITHMS (The 3 algo's -> BFS, DFS and A*)
% ----------------------------


% ---Depth First Search Implemntation ---
dfs_path(StartNode, GoalNode, SolutionPath, TotalDistance) :-
    traverse_dfs(StartNode, GoalNode, [StartNode], ReversedPath, 0, TotalDistance),
    reverse(ReversedPath, SolutionPath).

% Stop search when we reach the target location
traverse_dfs(GoalNode, GoalNode, VisitedNodes, VisitedNodes, Cost, Cost).


% Keep traversing adjacent unvisited locations
traverse_dfs(CurrentNode, GoalNode, Visited, Path, Cost, FinalCost ) :-
    connected(CurrentNode, NextNode, Distance),
    \+ member(NextNode, Visited),
    NewCost is Cost + Distance,
    traverse_dfs(NextNode, GoalNode, [NextNode|Visited], Path, NewCost, FinalCost).
