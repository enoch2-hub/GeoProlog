




























%-----------------------------------------------------------------------------------------------------------------------
% 2. Road Connectivity & Dynamic Blockage Rules
%-------------------------------------------------------------------------------------------------------------------------

% connected predicate ensures bidirsctional traffic
connected(A,B,D) :- edge(A,B,D), \+ blocked(A,B).
connected(A,B,D) :- edge(B,A,D), \+ blocked(B,A).



