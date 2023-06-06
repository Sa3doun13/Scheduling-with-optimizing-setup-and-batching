#const sub_size = 1.
#const setup_strg = 0.
#const stepid=0.
#include "parsing.lp".

#program base.

step_pro(L, P, S, Prio, A, G, Pro_t) :- stephas_setup((L, P, S, Prio), A, G, Setup_n),
                                        operation_step(P, S, A, G, Pro_t, Pro_unit, Min_b, Max_b, Setup_t, Setup_n).

stephas_setup((L, P, S, Prio), A, G, Setup_n)  :- operation_step(P, S, A, G, Pro_t, Pro_unit, Min_b, Max_b, Setup_t, Setup_n),
                                                  wip(L, P, Cur_s, Prio, W, R, D),
                                                  step_prio(L, P, Prio), S >= Cur_s.

total_steps_machines(Jobs, Steps,Machines) :-  Steps = #count{S, L, P, Prio : wip(L, P, Cur_s, Prio, W, R, D), 
                                                   operation_step(P, S, A, G, Pro_t, Pro_unit, Min_b, Max_b, Setup_t, Setup_n),
                                                                 S >= Cur_s}>0,
                                         Machines = #count{Machine, G: tool(A, G, Machine)}>0,
                                         Jobs = #count{L,P : wip(L, P, Cur_s, Prio, W, R, D)}.


step_setup(L, P, S, Prio, Setup) :- stephas_setup((L, P, S, Prio), A, G, Setup).
step_setup(P, S, Setup) :- step_setup(L, P, S, Prio, Setup).

lot(L, P, Prio, W, R, D) :- wip(L, P, Cur_s, Prio, W, R, D).

step_prio(L, P, Prio)   :- lot(L, P, Prio, W, R, D).
lot_release(L, R)       :- lot(L, P, Prio, W, R, D).
num_wafer(L, W)         :- lot(L, P, Prio, W, R, D).

sub_size_grp(Size) :- Size = sub_size, Size > 0.

step_lot(L, P, S, Prio) :- step_pro(L, P, S, Prio, A, G, Pro_t).
pro(P, S, Pro_t)        :- step_pro(L, P, S, Prio, A, G, Pro_t).

tool_grp(G, M) :- tool(A, G, M),
                  not tool(A, G, M + 1).

step_index(L, P, S, Prio, G, I) :- step_pro(L, P, S, Prio, A, G, Pro_t),
                                       step_prio(L, P, Prio), 
                                       lot_release(L, R), 
                                       I = #count{L1, P1, Prio1, S1 * stepid : 
                                                    step_pro(L1, P1, S1, Prio1, A1, G, Pro_t1),
                                                    step_prio(L1, P1, Prio1), 
                                                    lot_release(L1, R1),
                                                        (R1, Prio, S1 * stepid, Pro_t1 * stepid, P1, L1) < 
                                                             (R, Prio1, S * stepid, Pro_t * stepid, P, L)}.

     
                                                        
% *************************************** assign machines to sub-group ***************************************
sub_grp(G, 1, 1) :- tool_grp(G, T).
sub_grp(G, M, I) :- tool_grp(G, T), tool(A, G, M),
                    sub_grp(G, M-1, I),
                    sub_size_grp(Size),
                    ((M-1) \ Size) != 0.

sub_grp(G, M, I + 1) :- tool_grp(G, T), tool(A, G, M),
                        sub_grp(G, M-1, I),
                        sub_size_grp(Size),
                        ((M-1) \ Size) = 0.

sub_grp(G, M, 1) :- tool(A, G, M), sub_size = 0. 

last_m_sub_grp(G, M, I) :- sub_grp(G, M, I),
                           not sub_grp(G, M + 1, I).
first_m_sub_grp(G, M, I) :- sub_grp(G, M, I),
                            not sub_grp(G, M-1, I).

sub_grp(G, I)     :- sub_grp(G, M, I).
num_sub_grp(G, I) :- sub_grp(G, I),
                     not sub_grp(G, I+1).

step_s_grp((L, P, S, Prio), G, D) :- step_index(L, P, S, Prio, G, I),
                                     num_sub_grp(G, N),
                                     D = (I \ N) + 1.


% *************************************** partial assignment ***************************************

assignable((L, P, S, Prio), G, M) :- step_s_grp((L, P, S, Prio), G, D), sub_grp(G, M, D), setup_strg = 0.

assignable((L, P, S, Prio), G, M) :- step_s_grp((L, P, S, Prio), G, D), setup_to_machines(G, M, D, Setup),
                                     step_setup(P, S, Setup).

{mach_assign(L, P, S, Prio, G, M): assignable((L, P, S, Prio), G, M)} = 1 :- step_s_grp((L, P, S, Prio), G, D).


% *************************************** flexible assignment ***************************************

poss_tool((L, P, S, Prio), Pro_t, G, M) :- assignable((L, P, S, Prio), G, M),
                                           pro(P, S, Pro_t).

poss_same(O1, O2, Pro_t1, Pro_t2, G, M) :- poss_tool(O1, Pro_t1, G, M),
                                           poss_tool(O2, Pro_t2, G, M),
                                           O1 = (L1, P1, S1, Prio1),
                                           O2 = (L2, P2, S2, Prio2),
                                           (L1, P1, Prio1, S1) < (L2, P2, Prio2, S2).

poss_diff((L1, P1, S1, Prio1), (L2, P2, S2, Prio2), Pro_t1, Pro_t2, G, M) :-
    poss_same((L1, P1, S1, Prio1), (L2, P2, S2, Prio2), Pro_t1, Pro_t2, G, M),
    (L1, P1, Prio1) < (L2, P2, Prio2).

same_tool((L1, P1, S1, Prio1), (L2, P2, S2, Prio2), Pro_t1, Pro_t2) :- 
    poss_diff((L1, P1, S1, Prio1), (L2, P2, S2, Prio2), Pro_t1, Pro_t2, G, M),
    mach_assign(L1, P1, S1, Prio1, G, M),
    mach_assign(L2, P2, S2, Prio2, G, M).

% *********************************** consider the first step in each batch ************************************
                                                         

unbatched(O1, O2, Pro_t1, Pro_t2) :- same_tool(O1, O2, Pro_t1, Pro_t2), not batch(O1, O2).

{diff_order(O1, O2, Pro_t1)} :- unbatched(O1, O2, Pro_t1, Pro_t2). 
 diff_order(O2, O1, Pro_t2)  :- unbatched(O1, O2, Pro_t1, Pro_t2), 
                                not diff_order(O1, O2, Pro_t1).

order(O1, O2, Pro_t1) :- diff_order(O1, O2, Pro_t1).

% ************************************ order steps belong to same product ************************************
order((L, P, S1, Prio), (L, P, S2, Prio), Pro_t1) :- step_lot(L, P, S1, Prio),
                                                     step_lot(L, P, S2, Prio),
                                                     pro(P, S1, Pro_t1),
                                                     S2 = S1 + 1.

% ************************* steps belong to same product and assigned to same machine ************************
pair((L, P, S1, Prio), (L, P, S2, Prio), Pro_t1, G, M) :-
    poss_same((L, P, S1, Prio), (L, P, S2, Prio), Pro_t1, Pro_t2, G, M),
    pm(E, G, Type, Max, Dur, Min).
pair((L, P, S1, Prio), (L, P, S2, Prio), Pro_t1, G, M) :-
    poss_same((L, P, S1, Prio), (L, P, S2, Prio), Pro_t1, Pro_t2, G, M),
    setup_change(G, Setup_n, Setup_t, Min_r).

same_tool((L, P, S1, Prio), (L, P, S2, Prio), Pro_t1) :- 
    pair((L, P, S1, Prio), (L, P, S2, Prio), Pro_t1, G, M),
    mach_assign(L, P, S1, Prio, G, M),
    mach_assign(L, P, S2, Prio, G, M).

% ************************************* handling the maintenance & setup *************************************
pair(G, O1, O2, Pro_t1) :- pair(O1, O2, Pro_t1, G, M).

pair(G, O1, O2, Pro_t1) :- poss_diff(O1, O2, Pro_t1, Pro_t2, G, M),
                           pm(E, G, Type, Max, Dur, Min).
pair(G, O2, O1, Pro_t2) :- poss_diff(O1, O2, Pro_t1, Pro_t2, G, M),
                           pm(E, G, Type, Max, Dur, Min).
pair(G, O1, O2, Pro_t1) :- poss_diff(O1, O2, Pro_t1, Pro_t2, G, M),
                           setup_change(G, Setup_n, Setup_t, Min_r).
pair(G, O2, O1, Pro_t2) :- poss_diff(O1, O2, Pro_t1, Pro_t2, G, M),
                           setup_change(G, Setup_n, Setup_t, Min_r).

tool_order(O1, O2, Pro_t1) :- same_tool(O1, O2, Pro_t1).
tool_order(O1, O2, Pro_t1) :- diff_order(O1, O2, Pro_t1), pair(G, O1, O2, Pro_t1).

no_first(O2) :- tool_order(O1, O2, Pro_t1).
% no_first(O)  :- follower_batch(G, M, O).

no_consecutive(O1, O2) :- pair(G, O1, O2, Pro_t1),
                          tool_order(O1, O, Pro_t1),
                          tool_order(O, O2, Pro_t).

% ************************* determining the ignored operations *************************
ignore(E, G, O1, O2)  :- pair(G, O1, O2, Pro_t1),
                         assign_m_s(E, G, O),
                         tool_order(O1, O, Pro_t1),
                         tool_order(O, O2, Pro_t).

ignore(E, G, O1, O2)  :- pair(G, O1, O2, Pro_t1),
                         assign_m_s(E, G, O2).

ignore(E, G, O1, O2)  :- pair(G, O1, O2, Pro_t1),
                         pm(E, G, Type, Max, Dur, Min),
                         not tool_order(O1, O2, Pro_t1).

ignore(setup, G, O1, O2) :- pair(G, O1, O2, Pro_t1),
                            stephas_setup(O1, A, G, S1),
                            stephas_setup(O2, A, G, S2),
                            not tool_order(O1, O2, Pro_t1).

no_last(E, G, O1) :- assign_m_s(E, G, O2),
                     tool_order(O1, O2, Pro_t1).

% ************************* assigning the maintenance and setup ************************
{assign(E, G, (L, P, S, Prio))} :- pm(E, G, Type, Max, Dur, Min),
                                   step_pro(L, P, S, Prio, A, G, Pro_t).
:- assign(E, G, O1), batched(O1, O2), not assign(E, G, O2).

assign_setup(Setup_n2, G, O2) :- pair(G, O1, O2, Pro_t1), 
                                 not no_consecutive(O1, O2),
                                 tool_order(O1, O2, Pro_t1),
                                 use_setup(O1, Setup_n1),
                                 use_setup(O2, Setup_n2),
                                 Setup_n1 != Setup_n2,
                                 Setup_n2 != 0.

assign_setup(Setup_n1, G, O1) :- not no_first(O1),
                                 use_setup(O1, Setup_n1),
                                 stephas_setup(O1, A, G, Setup_n1),
                                 Setup_n1 != 0.

% ******************** merging the maintenance and setup in one atom *******************
assign_m_s(E, G, O) :- assign(E, G, O).
assign_m_s(setup, G, O) :- assign_setup(S, G, O).
% ************************ handling the maintenance constraints ************************
:- pm(E, G, Type, Max, Dur, Min), poss_tool((L, P, S, Prio), Pro_t, G, M),
   not no_first((L, P, S, Prio)), not assign_m_s(E, G, (L, P, S, Prio)).

:- pm(E, G, counter_based, Max, Dur, Min), poss_tool((L1, P1, S1, Prio1), Pro_t1, G, M), num_wafer(L1, W1),
   #sum+{W, L2, P2, S2, Prio2 : pair(G, (L1, P1, S1, Prio1), (L2, P2, S2, Prio2), Pro_t1), 
                                num_wafer(L2, W),
                                not ignore(E, G, (L1, P1, S1, Prio1), (L2, P2, S2, Prio2));
         W, L2, P2, S2, Prio2 : batched((L1, P1, S1, Prio1), (L2, P2, S2, Prio2)),
                                num_wafer(L2, W)} > Max-W1.

:- pm(E, G, counter_based, Max, Dur, Min), assign_m_s(E, G, (L1, P1, S1, Prio1)), num_wafer(L1, W1),
   no_last(E, G, (L1, P1, S1, Prio1)),
   #sum+{W, L2, P2, S2, Prio2 : pair(G, (L1, P1, S1, Prio1), (L2, P2, S2, Prio2), Pro_t1),
                                num_wafer(L2, W),
                                not ignore(E, G, (L1, P1, S1, Prio1), (L2, P2, S2, Prio2));
         W, L2, P2, S2, Prio2 : batched((L1, P1, S1, Prio1), (L2, P2, S2, Prio2)),
                                num_wafer(L2, W)} < Min-W1.

:- pm(E, G, time_based, Max, Dur, Min), poss_tool((L1, P1, S1, Prio1), Pro_t1, G, M),
   #sum+{Pro_t2, L2, P2, S2, Prio2 : pair(G, (L1, P1, S1, Prio1), (L2, P2, S2, Prio2), Pro_t1), 
                                     pro(P2, S2, Pro_t2),
                                     not ignore(E, G, (L1, P1, S1, Prio1), (L2, P2, S2, Prio2)),
                                     not batched((L2, P2, S2, Prio2))} > Max-Pro_t1.

:- pm(E, G, time_based, Max, Dur, Min), assign_m_s(E, G, (L1, P1, S1, Prio1)), pro(P1, S1, Pro_t1),
   no_last(E, G, (L1, P1, S1, Prio1)),
   #sum+{Pro_t2, L2, P2, S2, Prio2 : pair(G, (L1, P1, S1, Prio1), (L2, P2, S2, Prio2), Pro_t1),
                                     pro(P2, S2, Pro_t2),
                                     not ignore(E, G, (L1, P1, S1, Prio1), (L2, P2, S2, Prio2)),
                                     not batched((L2, P2, S2, Prio2))} < Min-Pro_t1.

pm_index(E, G, Dur, I) :- pm(E, G, Type, Max, Dur, Min), 0 < Dur,
                            I = #count{E' : pm(E', G, Type', Max', Dur', Min'),
                                            0 < Dur', (Dur,E) <= (Dur',E')}.

% ****************** handling two maintenances occur at the same time ******************
pm_duration(O, I, Dur) :- pm_index(E, G, Dur, I), assign_m_s(E, G, O).
pm_duration(O, I, Dur) :- pm_index(E, G, Dur1, I), assign_m_s(E, G, O),
                          pm_duration(O, I + 1, Dur2), Dur = Dur1 + Dur2.
pm_duration(O, I, Dur) :- pm_duration(O, I + 1, Dur), 0 < I.

% ***************************************** handling setup *****************************************
no_direct(O1, O2) :- pair(G, O1, O2, Pro_t1), 
                     tool_order(O1, O, Pro_t1),
                     tool_order(O, O2, Pro_t),
                     stephas_setup(O1, A, G, Setup_n1),
                     stephas_setup(O, A, G, Setup_n),
                     stephas_setup(O2, A, G, 0),
                     Setup_n1 != 0, Setup_n != 0, Setup_n1 != Setup_n.

reuse_setup(O2, Setup_n1) :- tool_order(O1, O2, Pro_t1), 
                             stephas_setup(O1, A, G, Setup_n1),
                             stephas_setup(O2, A, G, 0), 
                             not no_direct(O1, O2),
                             Setup_n1 != 0.

use_setup(O, 0)       :- stephas_setup(O, A, G, 0), not reuse_setup(O, _). % to handle that the first operation needs no setup
use_setup(O, Setup_n) :- stephas_setup(O, A, G, Setup_n), Setup_n != 0. % to handle that the current operation - either the first one or no - needs a setup
use_setup(O, Setup_n) :- reuse_setup(O, Setup_n). % to handle that the next operation needs setup zero

setup_duration(O, G, Setup_t) :- assign_setup(Setup, G, O),
                                 setup_change(G, Setup, Setup_t, Min_r).

% ********************* Same operation has a maintenance and setup *********************
pm_and_setup(O, Dur) :- setup_duration(O, G, Dur1),
                        pm_duration(O, 1, Dur2),
                        Dur = Dur1 + Dur2.

% *************** Merging the maintenance and setup (duration) in one atom *************
pm_setup(O, Dur) :- setup_duration(O, G, Dur).
pm_setup(O, Dur) :- pm_duration(O, 1, Dur).
pm_setup(O, Dur) :- pm_and_setup(O, Dur).

first_step((L, P, Cur_s, Prio), R) :- step_lot(L, P, Cur_s, Prio), lot_release(L, R), not setup_duration((L, P, Cur_s, Prio), _, _),
                                      wip(L, P, Cur_s, Prio, W, R, D).

first_step((L, P, Cur_s, Prio), R + Setup_t) :- lot_release(L, R), 
                                                step_lot(L, P, Cur_s, Prio), O = (L, P, Cur_s, Prio),
                                                setup_duration(O, G, Setup_t), 
                                                wip(L, P, Cur_s, Prio, W, R, D).

% ********************************* handling batching **********************************
batch_tool(G, M) :- tool(diffusion, G, M).

step_batch((L, P, S, Prio), Min_b, Max_b, G, M) :- 
    step_pro(L, P, S, Prio, A, G, Pro_t),
    operation_step(P, S, A, G, Pro_t, batch, Min_b, Max_b, Setup_t, Setup_n),
    batch_tool(G, M),
    assignable((L, P, S, Prio), G, M).

poss_batch((L1, P, S, Prio1), (L2, P, S, Prio2)) :- 
    step_batch((L1, P, S, Prio1), Min_b, Max_b, G, M),
    step_batch((L2, P, S, Prio2), Min_b, Max_b, G, M),
    (L1, Prio1) < (L2, Prio2).

{batch((L1, P, S, Prio1), (L2, P, S, Prio2)) : 
 poss_batch((L1, P, S, Prio1), (L2, P, S, Prio2))} 1 :- 
    step_batch((L2, P, S, Prio2), Min_b, Max_b, G, M).

batched(O1, O2) :- batch(O1, O2).
batched(O2, O1) :- batch(O1, O2).

batched(O2) :- batch(O1, O2).
:- batch(O1, O2), batched(O1).

:- batch(O1, O2), not same_tool(O1, O2, _, _).

:- step_batch((L1, P, S, Prio1), Min_b, Max_b, G, M), num_wafer(L1, W1),
   #sum+{W2, L2, Prio2 : batch((L1, P, S, Prio1), (L2, P, S, Prio2)),
                         num_wafer(L2, W2)} > Max_b - W1.

% ************************************ Difference logic for scheduling ************************************
&diff{0 - (L, P, S, Prio)} <= -T :- first_step((L, P, S, Prio), T).

&diff{0  -  O} <= -Setup_t :- tool_order(O, _, Pro_t), not no_first(O),
                              setup_duration(O, G, Setup_t).

&diff{O1 - O2} <= -Pro_t1 :- order(O1, O2, Pro_t1).

&diff{O1 - O2} <= -Pro_t1 - Dur :- tool_order(O1, O2, Pro_t1),
                                   pm_setup(O2, Dur).

&diff{(L, P, S, Prio) - makespan} <= -Pro_t :- pro(P, S, Pro_t),
                                               step_lot(L, P, S, Prio),
                                               not step_lot(L, P, S+1, Prio).

&diff{O1 - O2} <= 0 :- batch(O1, O2).
&diff{O2 - O1} <= 0 :- batch(O1, O2).

#program opt(b).
#external bound(b).
&diff{ makespan - 0} <= b :- bound(b).


#program weak(b).
#external bound(b).
&diff{ makespan - 0} <= b :- bound(b).

:~ assign_setup(Setup_n1, G, O1), no_last(setup, G, O1),
   setup_change(G, Setup_n1, Setup_t1, Min_r1),
   #count{O2 : pair(G, O1, O2, Pro_t1), not ignore(setup, G, O1, O2)}  < Min_r1 - 1 . [1@2, O1]

:~ step_batch(O1, Min_b, Max_b, G, M), not batched(O1),
   #count{O2 : batch(O1,O2)} < Min_b - 1. [1@1, O1]


%penalty@priority

#show.
%#show assign_setup/3.
%#show assign/3.
%#show mach_assign/6.
%#show total_steps_machines/3.
%#show batch_vio_soft/1.
%#show violation/2.
