:- dynamic
	panel/3.
	turn/3.

/* Facts
panel(_,_,start).
panel(_,_,gold).
panel(_,_,pit).
panel(_,_,wumpus).
panel(_,_,glitter).
panel(_,_,breeze).
panel(_,_,stench).
panel(_,_,solution).
bounds(_,_).
hasGold(yes).
turn(_,_,_).
*/

%/* Test Map

%*/

% Used for playing
mapFeatures :-
	findBreeze;
	findStench;
	findGlitter.

% Used for playing and maybe for solving later
findBreeze :-
	panel(X,Y,pit),
	assertFeature(X,Y,breeze).

% Used for playing and maybe for solving later
findStench :-
	panel(X,Y,wumpus),
	assertFeature(X,Y,stench).

% Used for playing and maybe for solving later
findGlitter :-
	panel(X,Y,gold),
	assertFeature(X,Y,glitter).

% Used for playing and maybe for solving later
assertFeature(X,Y,Feature):-
	(Feature=glitter ->
		assert(panel(X,Y,Feature))
	;
		A is (X+1),
		not(panel(A,Y,Feature)),
		assert(panel(A,Y,Feature)),false;
		B is (X-1),
		not(panel(B,Y,Feature)),
		assert(panel(B,Y,Feature)),false;
		C is (Y+1),
		not(panel(X,C,Feature)),
		assert(panel(X,C,Feature)),false;
		D is (Y-1),
		not(panel(X,D,Feature)),
		assert(panel(X,D,Feature)),false).

% Used for playing
start :-
	reset,
	mapFeatures,
	panel(X,Y,start),
	!,
	game(X,Y).

% Used for playing
game(X,Y):-
	(hasWon(X,Y) ->
		format('You won!~n'),
		!
	;isDead(X,Y) ->
		format(' and died.'),
		!
	);
	write('Has: '),
	(panel(X,Y,glitter) ->
		format('[Glitter]')
	;
		format('[No glitter]')),

	(panel(X,Y,stench) ->
		format('[Stench]')
	;
		format('[No stench]')),

	(panel(X,Y,breeze) ->
		format('[Breeze]')
	;
		format('[No breeze]')),
	nl,
	showMoves(X,Y);
	nl,
	read(Move),
	(Move == n ->
		NX is (X+1),NY is Y
	;Move == e ->
		NX is X,NY is (Y+1)
	;Move == s ->
		NX is (X-1),NY is Y
	;Move == w ->
		NX is X,NY is (Y-1)
	;Move == p,panel(X,Y,glitter) ->
		NX is X,NY is Y,retract(panel(X,Y,glitter)),assert(hasGold(yes))
	;
		format('~nInvalid command.~n'),game(X,Y)),
	(isValid(NX,NY) ->
		write('')
	;
		format('~nInvalid direction.~n'),game(X,Y)),
	nl,
	game(NX,NY).

% Used for playing
showMoves(X,Y):-
	format('You can move: ~n'),
	bounds(_,Max),
	(X < Max ->
		format('~w~n',['North'])),false;
	bounds(_,Max),
	(Y < Max ->
		format('~w~n',['East'])),false;
	bounds(Min,_),
	(X > Min ->
		format('~w~n',['South'])),false;
	bounds(Min,_),
	(Y > Min ->
		format('~w~n',['West'])),false.

% Used for playing
isDead(X,Y):-
	panel(X,Y,pit),
	write('You fell in a pit');
	panel(X,Y,wumpus),
	write('You found the wumpus').

% Used for playing
hasWon(X,Y):-
	panel(X,Y,start),
	hasGold(yes).

% Used for solving and playing
isValid(X,Y):-
	bounds(Min,Max),
	NMax is (Max+1),
	NMin is (Min-1),
	X<NMax,
	Y<NMax,
	X>NMin,
	Y>NMin.

% Used for solving
canSolve :-
	reset,
	panel(X,Y,start),
	tPanels(TP), % Remove if needed
	canSolveHelper(X,Y,1,TP).

% Used for solving
canSolveHelper(X,Y,T,TP):-
	T < TP, % Remove if needed
	once(
		(
			panel(X,Y,gold),
			not(isDeadSolver(X,Y)),
			Z is (T-1),
			assert(movesNeeded(Z))
		);
		(
			A is (X+1),
			not(isDeadSolver(A,Y)),
			not(turn(A,Y,_)),
			move(A,Y,T,TP)
		);
		(
			B is (Y+1),
			not(isDeadSolver(X,B)),
			not(turn(X,B,_)),
			move(X,B,T,TP)
		);
		(
			C is (X-1),
			not(isDeadSolver(C,Y)),
			not(turn(C,Y,_)),
			move(C,Y,T,TP)
		);
		(
			D is (Y-1),
			not(isDeadSolver(X,D)),
			not(turn(X,D,_)),
			move(X,D,T,TP)
		)
		).

% Used for solving
move(X,Y,T,TP):-
	isValid(X,Y),
	assert(turn(X,Y,T)),
	Z is (T+1),
	canSolveHelper(X,Y,Z,TP);
	retract(turn(X,Y,T)),false.

% Used for solving
isDeadSolver(X,Y):-
	panel(X,Y,pit);
	panel(X,Y,wumpus).

% Used for solving
movesNeeded :-
	aggregate_all(count,turn(_,_,_),Moves),
	format('Moves needed: ~w~n',[Moves]).

% Used for solving
showSolution :-
	sSH(1).

sSH(T):-
	turn(X,Y,T),
	format('~w [~w,~w]~n',[T,X,Y]),
	Z is (T+1),
	sSH(Z).

% Used for solving and playing
reset :-
	retractall(panel(_,_,breeze)),
	retractall(panel(_,_,stench)),
	retractall(panel(_,_,glitter)),
	retractall(hasGold(_)),
	retractall(movesNeeded(_)),
	retractall(turn(_,_,_)).
