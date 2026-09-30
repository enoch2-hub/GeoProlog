% ==============================================================================
% PROJECT: GeoProlog - Smart Urban Waste Collection & Vehicle Routing System
% COURSE:  COU4303 - Artificial Intelligence (BSc IT - OUSL)
% ==============================================================================

:- dynamic(blocked/2).
:- dynamic(bin_status/2). % Dynamic bin fill levels: bin_status(BinID, FillPercentage)

% ------------------------------------------------------------------------------
% 1. KNOWLEDGE BASE: MAP GRAPH & SPATIAL COORDINATES
% ------------------------------------------------------------------------------

% Node Coordinates: loc(NodeName, X_Coordinate, Y_Coordinate)
loc(depot,         0,  0).
loc(zone_a_hub,   10, 15).
loc(zone_b_hub,   25, 10).
loc(bin_1,        12, 30).
loc(bin_2,        28, 25).
loc(bin_3,        35, 35).
loc(landfill,     50, 40).

% Road Graph Connections: edge(StartNode, EndNode, Distance_In_KM)
edge(depot, zone_a_hub, 8).
edge(depot, zone_b_hub, 12).
edge(zone_a_hub, bin_1, 6).
edge(zone_a_hub, bin_2, 10).
edge(zone_b_hub, bin_2, 5).
edge(zone_b_hub, bin_3, 9).
edge(bin_1, bin_2, 7).
edge(bin_2, landfill, 14).
edge(bin_3, landfill, 8).

% ------------------------------------------------------------------------------
% 2. ROAD CONNECTIVITY & DYNAMIC BLOCKAGE RULES
% ------------------------------------------------------------------------------

% Connected predicate ensures bidirectional traffic unless the road is blocked
connected(A, B, D) :- edge(A, B, D), \+ blocked(A, B).
connected(A, B, D) :- edge(B, A, D), \+ blocked(B, A).

% ------------------------------------------------------------------------------
% 3. DYNAMIC EUCLIDEAN HEURISTIC FUNCTION
% Calculates h(n) dynamically based on 2D straight-line distance to the Goal
% ------------------------------------------------------------------------------

h(CurrentNode, GoalNode, H) :-
    loc(CurrentNode, X1, Y1),
    loc(GoalNode, X2, Y2),
    H is sqrt((X2 - X1)^2 + (Y2 - Y1)^2).

% ------------------------------------------------------------------------------
% 4. SEARCH ALGORITHMS (BFS, DFS, A*)
% ------------------------------------------------------------------------------

% --- Depth-First Search (DFS) ---
dfs_path(Start, Goal, Path, Cost) :-
    dfs_travel(Start, Goal, [Start], RevPath, 0, Cost),
    reverse(RevPath, Path).

dfs_travel(Goal, Goal, Visited, Visited, Cost, Cost).
dfs_travel(Current, Goal, Visited, Path, CostSoFar, TotalCost) :-
    connected(Current, Next, StepCost),
    \+ member(Next, Visited),
    NewCost is CostSoFar + StepCost,
    dfs_travel(Next, Goal, [Next|Visited], Path, NewCost, TotalCost).

% --- Breadth-First Search (BFS) ---
bfs(Start, Goal, Path, Cost) :-
    bfs_queue([[Start]], Goal, RevPath),
    reverse(RevPath, Path),
    path_cost(Path, Cost).

bfs_queue([[Goal|Rest]|_], Goal, [Goal|Rest]).
bfs_queue([[Current|Rest]|Others], Goal, Path) :-
    findall([Next, Current|Rest],
            (connected(Current, Next, _), \+ member(Next, [Current|Rest])),
            NewPaths),
    append(Others, NewPaths, UpdatedQueue),
    bfs_queue(UpdatedQueue, Goal, Path).

% --- A* Search (Informed Heuristic Search) ---
astar(Start, Goal, Path, Cost) :-
    h(Start, Goal, H0),
    astar_search([[H0, 0, [Start]]], Goal, RevPath, Cost),
    reverse(RevPath, Path).

astar_search([[_, Cost, [Goal|Rest]]|_], Goal, [Goal|Rest], Cost).
astar_search([[_, G, [Current|Rest]]|Others], Goal, Path, Cost) :-
    findall([F2, G2, [Next, Current|Rest]],
            (connected(Current, Next, StepCost),
             \+ member(Next, [Current|Rest]),
             G2 is G + StepCost,
             h(Next, Goal, H),
             F2 is G2 + H),
            Children),
    append(Others, Children, AllNodes),
    sort(AllNodes, SortedNodes),
    astar_search(SortedNodes, Goal, Path, Cost).

% --- Helper Predicate: Calculate Total Path Distance ---
path_cost([_], 0).
path_cost([A, B|Rest], TotalCost) :-
    connected(A, B, D),
    path_cost([B|Rest], RestCost),
    TotalCost is D + RestCost.

% ------------------------------------------------------------------------------
% 5. COMPARISON & RESULTS DISPLAY
% ------------------------------------------------------------------------------

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

% ------------------------------------------------------------------------------
% 6. INTERACTIVE CLI MENU
% ------------------------------------------------------------------------------

start :-
    nl, write('=================================================='), nl,
    write('   GeoProlog: Smart Urban Waste Collection System   '), nl,
    write('=================================================='), nl,
    write('1. Find Route (Compare DFS, BFS, A*)'), nl,
    write('2. Block a Road'), nl,
    write('3. Unblock a Road'), nl,
    write('4. Show Blocked Roads'), nl,
    write('5. Exit'), nl, nl,
    write('Choose an option (1-5): '), read(Choice),
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
    forall(blocked(A, B), format(' - ~w <-> ~w~n', [A, B])).