







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
	(	blocked(_,_)
	->	list_blocked
	;	write('None'), nl
	),
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
