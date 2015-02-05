:- dynamic
	panel/3,
	bounds/2,
	hasGold/1.

/* Uncomment out and change FD to a directory
:- working_directory(_,FD).
*/

/* Facts
panel(_,_,start).
panel(_,_,gold).
panel(_,_,pit).
panel(_,_,wumpus).
panel(_,_,glitter).
panel(_,_,breeze).
panel(_,_,stench).
panel(_,_,solution).
panel(_,_,invalid).
bounds(_,_).
hasGold(yes).
*/

% Default facts if importFacts fails
defaultAssert :-
	assert(bounds(1,3)),
	assert(panel(1,1,start)),
	assert(panel(2,2,gold)),
	assert(panel(2,3,pit)),
	assert(panel(3,2,wumpus)),
	assert(panel(3,3,pit)).

% Used for playing and solving
importFacts :-
	exists_file('WumpusWorldBoard.txt'),
	seeing(Old),
	see('WumpusWorldBoard.txt'),
	repeat,
	read(Data),
	assertFact(Data),
	seen,
	see(Old),
	!.

assertFact(Data):-
	assert(Data),
	fail.

assertFact(end_of_file):-
	!.

% Completely resets map/Used for playing and solving
fullReset :-
	once(
		(retractall(panel(_,_,_)),
		retractall(hasGold(_)),
		retractall(bounds(_,_)),
		importFacts);
		(retractall(panel(_,_,_)),
		retractall(hasGold(_)),
		retractall(bounds(_,_)),
		defaultAssert)
		).

% Used for playing
mapFeatures :-
	findBreeze;
	findStench;
	findGlitter.

% Used for playing
findBreeze :-
	panel(X,Y,pit),
	assertFeature(X,Y,breeze).

% Used for playing
findStench :-
	panel(X,Y,wumpus),
	assertFeature(X,Y,stench).

% Used for playing
findGlitter :-
	panel(X,Y,gold),
	assertFeature(X,Y,glitter).

% Used for playing
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
	fullReset,
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
	fullReset,
	panel(X,Y,start),
	!,
	canSolveHelper(X,Y).

% Used for solving
canSolveHelper(X,Y):-
	once(
		(	
			panel(X,Y,gold),
			not(isDeadSolver(X,Y))
		);
		(
			A is (X+1),
			not(isDeadSolver(A,Y)),
			not(panel(A,Y,solution)),
			not(panel(A,Y,invalid)),
			move(A,Y)
		);
		(
			B is (Y+1),
			not(isDeadSolver(X,B)),
			not(panel(X,B,solution)),
			not(panel(X,B,invalid)),
			move(X,B)
		);
		(
			C is (X-1),
			not(isDeadSolver(C,Y)),
			not(panel(C,Y,solution)),
			not(panel(C,Y,invalid)),
			move(C,Y)
		);
		(
			D is (Y-1),
			not(isDeadSolver(X,D)),
			not(panel(X,D,solution)),
			not(panel(X,D,invalid)),
			move(X,D)
		)
		).

% Used for solving
move(X,Y):-
	isValid(X,Y),
	assert(panel(X,Y,solution)),
	canSolveHelper(X,Y);
	retract(panel(X,Y,solution)),
	assert(panel(X,Y,invalid)),
	false.

% Used for solving
isDeadSolver(X,Y):-
	panel(X,Y,pit);
	panel(X,Y,wumpus).

% Used for solving
movesNeeded :-
	canSolve,
	aggregate_all(count,panel(_,_,solution),Moves),
	format('Moves needed: ~w~n',[Moves]).

% Used for solving
showSolution :-
	canSolve,
	panel(X,Y,solution),
	format('Move: [~w,~w]~n',[X,Y]).

commands :-
	format('canSolve~nmovesNeeded~nshowSolution~nstart').
