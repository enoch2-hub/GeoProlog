%---------------------------------------------
% COMPARISON & RESULTS DISPLAY
%---------------------------------------------

compare_routes(Start, Goal)
	nl, write('===GEOPROLOG ROUTE COMPARISON RESULTS ===') , nl ,
	format('From: ~w --> To; ~w~n' , [Start, Goal]),
	write('---------------------------------------------') , nl,

	%Execute DFS
	(dfs_path(Start, Goal, P_dfs, C_dfs) ->
		format('DFS Route : ~w | Cost: ~w km~n' , [P_dfs, C_dfs]) ;
		write('DFS Route : No path found!') , nl),

	
	%Execute BFS
	(bfs(Start, Goal, P_bfs, C_bfs) ->
		format('BFS Route : ~w | Cost: ~w km~n' , [P_bfs, C_bfs]) ;
		write('BFS Route : No path found!'),  nl) , 


	%Execute A*
	(astar(Start, Goal, P_a, C_a) ->
		format('A* Route : ~w | Cost: ~w km (OPTIMAL)~n' , [P_a, C_a]) ;
		write('A* Route : No path found!') , nl),
	write('-------------------------------------------------'), nl. 
 
%-----------------------------------------
% INTERACTIVE CLI MENU
%-----------------------------------------

start
	nl, write('================================================'), nl,
	write(' GeoProlog: Smart Urban Waste Collection System   '), nl,
	write('==============================================='), nl,
	write('1. Find Route (Compare DFS, BFS, A*)'), nl,
	write('2. Block a Road'), nl,
	write('3. Unblock a Road'), nl,
	write('4. Show Blocked Roads'), nl,
	write('5. Exit'), nl, nl,
	write('Choose an option (1-5): '),
	read(Choice) ,
	handle_choice(Choice) .


	handle_choice(1)
	nl, write('Enter start location (e.g., depot.): '), read(Start),
	write('Enter Goal Location(e.g., landfill.): '), read(Goal),
	compare_routes(Start, Goal),
	start.


	handle_choice(2)
	nl, write('Enter Start Node of Road to Block (e.g. , zone_a_hub.): '), read(A),
	write('Enter End Node of Road to Block (e.g., bin_2.): '), read(B),
	assert(blocked(A, B)),
	format('Road blocked: ~w <-> ~w~n', [A, B]),
	start.

