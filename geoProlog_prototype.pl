% =================================
% PROJECT: GeoProlog - Smart Urban Waste Collection & Vehicle Routing System
% COURSE:  COU4303 - Artificial Intelligence
% =====================




% --------------------------------------------
% 1. KNOWLEDGE BASE: Nodes & Road Connections
% --------------------------------

% Node Coordinates: loc(NodeName, X_Coordinate, Y_Coordinate)
location(depot,         0,  0).
location(zone_a_hub,   10, 15).
location(zone_b_hub,   25, 10).
location(bin_1,        12, 30).
location(bin_2,        28, 25).
location(bin_3,        35, 35).
location(landfill,     50, 40).

% Road Connections: edge(StartNode, EndNode, Distance_In_KM)
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
	Distance is sqrt(Dx^2 + Dy^2).





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





% --- Breadth First Search Implemntation---
bfs(StartNode, GoalNode, Path, TotalCost ) :-
    bfs_search_queue([[StartNode]], GoalNode, RevPath),
    reverse(RevPath, Path),
    path_cost(Path, TotalCost).

% Base case: Target reached at the front of a path queue
bfs_search_queue([[Goal|PathRest]|_], Goal, [Goal|PathRest]).

% Recursive step: Expand all adjacent unvisited nodes
bfs_search_queue([[Current|VisitedRest]|RemainingQueue], Goal, FinalPath) :-
    findall(
        [Next, Current|VisitedRest],
        ( connected(Current, Next, _), \+ member(Next, [Current|VisitedRest])),
        BranchPaths
    ),
    append(RemainingQueue, BranchPaths, NextQueue),
    bfs_search_queue(NextQueue, Goal, FinalPath).






% --- A* Heuristic Search Implemntation---
astar(StartNode, GoalNode, Path, Cost) :-
    h(StartNode, GoalNode, InitialH),
    astar_queue([[InitialH, 0, [StartNode]]], GoalNode, RevPath, Cost),
    reverse(RevPath, Path).

% Stop when the first path inthe queue reaches the goal
astar_queue([[_, Cost, [GoalNode|Rest]]|_], GoalNode, [GoalNode|Rest], Cost).

% Expand the current path and calculate the new A* cost
astar_queue([[_, DistSoFar, [Current|Rest]]|OtherPaths], 
	Goal, Path, TotalCost) :-
    findall(
        [F_Val, NewG, [NextNode, Current|Rest]],
        (
            connected(Current, NextNode, EdgeDist),
            \+ member(NextNode, [Current|Rest]),
            NewG is DistSoFar + EdgeDist,
            h(NextNode, Goal, H_Val),
            F_Val is NewG + H_Val
        ),
        DiscoveredNodes
    ),
    append(OtherPaths, DiscoveredNodes, CombinedQueue),
    sort(CombinedQueue, SortedQueue),
    astar_queue(SortedQueue, Goal, Path, TotalCost).







% --- Helper Predicate: Calculate Cumulative Path Distance ---
path_cost([_], 0).
path_cost([NodeA, NodeB|RestNodes], TotalDistance) :-
    connected(NodeA, NodeB, StepDistance),
    path_cost([NodeB|RestNodes], RemDistance),
    TotalDistance is StepDistance + RemDistance.






% --------------------------------
% 6. COMPARISON & RESULTS DISPLAY
% -------------------------

compare_routes(Start, Goal) :-
    nl, write('=== GEOPROLOG ROUTE COMPARISON RESULTS ==='), nl,
    format('From: ~w  -->  To: ~w~n', [Start, Goal]),
    write('------------------------------------------'), nl,
    
    % Execute DFS
    (dfs_path(Start, Goal, P_dfs, C_dfs) -> 
        format('DFS Route : ~w | Cost: ~w km~n', [P_dfs, C_dfs]) ; 
        write('DFS Route : No path found!'), nl),
    
    % Execute BFS
    (bfs(Start, Goal, P_bfs, C_bfs) -> 
        format('BFS Route : ~w | Cost: ~w km~n', [P_bfs, C_bfs]) ; 
        write('BFS Route : No path found!'), nl),

    % Execute A*
    (astar(Start, Goal, P_a, C_a) -> 
        format('A*  Route : ~w | Cost: ~w km (OPTIMAL)~n', [P_a, C_a]) ; 
        write('A*  Route : No path found!'), nl),
    write('------------------------------------------'), nl.







% --------------------------
% 7. INTERACTIVE CLI MENU
% --------------------

start :-
	nl, write('=================================================='), nl,
	write('   GeoProlog: Smart Urban Waste Collection System   '), nl,
	write('=================================================='), nl,
	write('1. Find Route (Compare DFS, BFS, A*)'), nl,
	write('2. Block a Road'), nl,
	write('3. Unblock a Road'), nl,
	write('4. Show Blocked Roads'), nl,
	write('5. Exit'), nl, nl,
	write('Choose any option (From 1 to 5): '),
	read(Choice),
	handle_choice(Choice).

handle_choice(1) :-
	nl, write('Enter Start Location (e.g., depot.): '), read(Start),
	write('Enter Goal Location (e.g., landfill.): '), read(Goal),
	compare_routes(Start, Goal),
	start.

handle_choice(2) :-
	nl, write('Enter Start Node of Road to Block (e.g., zone_a_hub.): '), read(A),
	write('Enter End Node of Road to Block (e.g., bin_2.): '), read(B),
	assert(blocked(A, B)),
	format('Road blocked: ~w <-> ~w~n', [A, B]),
	start.

handle_choice(3) :-
	nl, write('Enter Start Node to Unblock (e.g., zone_a_hub.): '), read(A),
	write('Enter End Node to Unblock (e.g., bin_2.): '), read(B),
	(retract(blocked(A, B)) -> 
		format('Road unblocked: ~w <-> ~w~n', [A, B]) ; 
		write('No such blocked road found.'), nl),
	start.

handle_choice(4) :-
	nl, write('Currently Blocked Roads:'), nl,
	(blocked(A, B) -> list_blocked ; write('None'), nl),
	start.

handle_choice(5) :-
	write('Exiting GeoProlog. Goodbye!'), nl.

handle_choice(_) :-
	write('Invalid choice, try again.'), nl,
	start.

list_blocked :- 
	forall(
		blocked(Start, End),
		format(' - ~w <-> ~w~n', [Start, End])
	).
