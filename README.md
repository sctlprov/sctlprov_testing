# Testing program for SCTLProV

This program can generate the result of SCTLProV on test cases automatically.

## How to compile

1. `make` or `make all`;
2. The executable file `run` is generated.

## How to run

   `run -exec <command> -timeout <tmot> -dir <targetdir> -surfix <sfx> [-extra <filename>] [-extra-last] -standard <filename>`

   Each argument of the command is explained as follows:

 1.  `-exec <command>`:  This argument specifies the provers or model checker to run, where `command` is the **absolute** file path of the executable of the provers or model checker, for instance `-exec /home/jian/SCTLProV/sctl`;

 2.  `-timeout <tmot>`:  This argument specifies the limit of the running time of the provers or model checkers, where `tmot` is the amout of time, the format of `tmot` is the same as in the linux shell. For instance, `-timeout 20m` specifies the limit of running time is 20 minutes;

 3.  `-dir <targetdir>`: This argument specifies the target directory where the files of test cases is. `targetdir` is the **absolute** file path of the target dir, for instance:

     `-dir /home/jian/benchmark1/p1/p01/sctl/`

 4. `-surfix <sfx>`: This argument specifies the surfix of each test cases. For instance, the surfix of test cases for SCTLProV is "model", which can be specifies as `-surfix model`.

 5. `-extra <filename>`: This argument is optional, which specifies the extra arguments of the provers or model checkers. Extra arguments are in the file `filename` which is in text format. For instance, to evaluate test cases in NuSMV, the extra argument `-dcx` is specifies in order to improve efficiency. In this case, we put `-dcx` as the first line in the file `nusmv_extra`, and when running NuSMV using the script, we use `-extra nusmv_extra` as an argument of the script. 

 6. `-extra-last`: Put the extra argument(s) at last.
 
 7. `-standard <filename>`: Specifies the file containing the standard answers for test cases. 

**Examples：**

- SCTLProV: 

  `run -exec /home/jian/SCTLProV/sctl -timeout 20m -dir /home/jian/benchmark1/p1/p01/sctl/ -surfix model -standard ./answers/cp_answer`

- Verds:

  `run -exec /home/jian/verds/verds -timeout 20m -dir /home/jian/benchmark1/p1/p01/verds/ -surfix vvm -extra ./extras/verds_extra -standard ./answers/cp_answer`

- iProver Modulo:

  `run -exec /home/jian/iprover/iproveropt -timeout 20m -dir /home/jian/benchmark1/p1/p01/iprover/ -surfix p -extra ./extras/iprover_extra -standard ./answers/cp_answer`

- NuSMV/NuXMV:

  `run -exec /home/jian/nusmv/bin/NuSMV -timeout 20m -dir /home/jian/benchmark1/p1/p01/smv/ -surfix smv -extra ./extras/nusmv_extra -standard ./answers/cp_answer`

**How to read the result file:**

The experimental results is in the auto-generated file `result_<timestamp>` and `result_<timestamp>_data`.
Each line in the file `result_<timestamp>_data` has the form:

```
<filename> <status> Time:<time> Memory:<memory>
```

* `status`: may be one of the following options: 
    - `NotSolvable`: the test case is not solvable, due to either timeout or out of memory;
    - `Pass`: result of the test case is equal to the standard answer;
    - `NotPass`: result of the test case is NOT equal to the standard answer, which indicates an failure;
    - `NoAnswer`: cannot find the standard answer of the test case.
* `time`: in seconds.
* `memory`: in MB.

**Note:**

Inside the script, `/usr/bin/time -v` is used to generate the time and memory usage for each test cases. For test cases where more accurate time usage is needed, please use `time` instead of `/usr/bin/time`.
