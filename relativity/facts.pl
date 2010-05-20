% first things first, the gender of the cast players
male(dad).
male(man).
male(boy).
male(boytwo).
female(mum).
female(widow).
female(stepdot).

% I married the widow
married(man, widow).
% my father ...
father(dad, man).
% ... married the stepdaughter
daughter(stepdot, widow).
married(dad, stepdot).

% stepdaughter has a boy
son(boy,stepdot).

% my wife also has a boy
son(boytwo,widow).
%
% implicit in the story
mother(mum, man).

% direct child-parent relationships
isdirectchild(Child,Parent) :- son(Child,Parent).
isdirectchild(Child,Parent) :- daughter(Child,Parent).
isdirectchild(Child,Parent) :- father(Parent,Child).
isdirectchild(Child,Parent) :- mother(Parent,Child).

% indirect child-parent relationships
ischild(Child,Parent) :- isdirectchild(Child,Parent).
ischild(Child,Parent) :- isdirectchild(Child,Random), ismarried(Random,Parent).

% and the reverse
isparent(Parent,Child) :- ischild(Child,Parent).

ismarried(Man,Woman) :- married(Man,Woman).
ismarried(Man,Woman) :- married(Woman,Man).

isfather(Man,Child) :- ischild(Child,Man), male(Man).
isfather(Man,Child) :- ischild(Child,Woman), ismarried(Woman,Man), male(Man).

ismother(Woman,Child) :- ischild(Child,Woman), female(Woman).
ismother(Woman,Child) :- ischild(Child,Man), ismarried(Woman,Man), female(Woman).

isgrandfather(X,Y) :- ischild(Z,X), ischild(Y,Z), male(X).
isgrandmother(X,Y) :- ischild(Z,X), ischild(Y,Z), female(X).

isbrother(X,Y) :- male(X), ischild(X,Z), ischild(Y,Z), X \== Y.
issister(X,Y) :- female(X), ischild(X,Z), ischild(Y,Z), X \== Y.

isaunt(X,Y) :- female(X), issister(X,Z), ischild(Y,Z).
isuncle(X,Y) :- male(X), isbrother(X,Z), ischild(Y,Z).

% brotherinlaw B is married to Ps sister
isbrotherinlaw(B,P) :- male(B), issister(Z,P), ismarried(B,Z).

% motherinlaw M is mother of Ps spouse
ismotherinlaw(M,P) :- female(M), ismarried(Z,P), ismother(M,Z).

% daughterinlaw D is a female married to one of Ps children
isdaughterinlaw(D,P) :- female(D), ischild(X,P), ismarried(X,D).
