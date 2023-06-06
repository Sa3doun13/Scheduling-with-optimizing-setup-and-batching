# FJSP-SMT2020-multishot

This work investigates solving semiconductor manufacturing scheduling tasks using Answer Set Programming (ASP). We tested our work (in progress) with small examples derived from the SMT2020 dataset.

- The following features have been considered in this work:
    - Machine Maintenance
    - Machine Setup
    - Batching
- Our main objectives are to minimize the total completion time (makespan) of schedules, the machine-setup changes and batching.

This repository includes the following files/folders:

<table>
<tr><th>File/Folder</th><th>Description</th></tr>
<tr><td style="font-family:'Courier New'">README.md</td><td>this file</td></tr>
<tr><td style="font-family:'Courier New'">encoding_batch.lp</td><td>main scheduling encoding</td></tr>
<tr><td style="font-family:'Courier New'">dlO_multi-obj.py</td><td>the python api script</td></tr>
<tr><td style="font-family:'Courier New'">parsing.lp</td><td>a file creates some atom to be used in the schedule</td></tr>
<tr><td style="font-family:'Courier New'">instance05.lp</td><td>instance number 05</td></tr>
<tr><td style="font-family:'Courier New'">instance06.lp</td><td>instance number 06</td></tr>
</table>

## Usage

Our scheduling encoding and instances can be run with [Clingo[DL]](https://potassco.org/labs/clingodl/) as illustrated by the following example calls.

We have two python versions for different packages:

- Package[5.5.2]
	- Fixed machine assignment:
        - ``python dlO_multi-obj.py encoding_batch.lp instance05.lp``
