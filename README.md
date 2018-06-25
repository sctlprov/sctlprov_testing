# Testing program for SCTLProV

This program can be used to automatically test the proving result of test cases (input files), and generate the test result in files. 

The testing program consists of the following 3 parts:

1. The executable to be tested, and the argument(s);
  
    The executable is specified by the `-exec` argument of the testing program, and the argument(s) of the executable is specified by the `-extra` argument of the testing program, and optionally, by the `-extra-last` argument of the testing program. In addition, we can also specify the limit of running time of the executable by the `-timeout` argument of the testing program.

2. The test cases;

    Usually, we put each set of test cases in a directory, and the path the directory is specified by the `-dir` argument of the testing program, and to make sure that we are running on the right input files, we specify the file extension of the input files by the `-surfix` argument of the testing program.
3. The standard answer (`true`/`false`) for each test case. 

    The standard answers of test cases are usually stored in a file, and after a result is obtained by the executable, we compare the result of the test case with its corresponding standard answer, and if they are the same, then the test `Pass`, otherwise `NotPass`. The file containing the standard answer of test cases is specified by the `-standard` argument of the testing program.

<!-- The basic workflow of the testing program is as follows:
1. For a set of given test cases (input files for SCTLProV), specify the standard answer (`true` or `false`) for the proving result of each test case in a file (see the explanation of the `-standard` argument below);
2. Run the tesing program (also see the explanation below);
3. After the testing process terminates, see the result file for detailed proving result for each test case (see the explanation below). -->

## How to compile?

`make` or `make all`

## How to run?

The usage of the testing program is as follows, where `run` is the name of the testing program.

   `run -exec <command> -timeout <tmot> -dir <targetdir> -surfix <sfx> [-extra <filename>] [-extra-last] -standard <filename>`

   Each argument of the testing program is explained in detail as follows:

 1.  `-exec <command>`:  This argument specifies the provers or model checker to run, where `command` is the **absolute** file path of the executable of the provers or model checker, for instance:
    
      `-exec /home/jian/SCTLProV/sctl`

 2.  `-timeout <tmot>`:  This argument specifies the limit of the running time of the provers or model checkers, where `tmot` is the amout of time, the format of `tmot` is the same as in the linux shell. For instance, `-timeout 20m` specifies the limit of running time is 20 minutes;

 3.  `-dir <targetdir>`: This argument specifies the target directory where the files of test cases is. `targetdir` is the **absolute** file path of the target dir, for instance:

     `-dir /home/jian/benchmark1/p1/p01/sctl/`

 4. `-surfix <sfx>`: This argument specifies the surfix of each test cases. For instance, the surfix of test cases for SCTLProV is "model", which can be specifies as `-surfix model`.

 5. `-extra <filename>`: This argument is optional, which specifies the extra arguments of the provers or model checkers. Extra arguments are in the file `filename` which is in text format. For instance, to evaluate test cases in NuSMV, the extra argument `-dcx` is specifies in order to improve efficiency. In this case, we put `-dcx` as the first line in the file `nusmv_extra`, and when running NuSMV using the script, we use `-extra nusmv_extra` as an argument of the script. 
  
    In our repository, files of extra argument(s) are contained in the folder `extra_args`, and are listed as follows.

    |File Name|Content|
    |:-|:-|
    |`iprover_extra`| Extra arguments when running iProver Modulo|
    |`nusmv_extra`| Extra argument when running either NuSMV or NuXMV|
    |`verds_extra`| Extra argument when running Verds|
    |`cadp_deadlock_extra`| Extra arguments when using CADP to detect deadlocks for BCG files|
    |`cadp_livelock_extra`| Extra arguments when using CADP to detect livelocks for BCG files|
    | `sctl_bcg_deadlock_extra`| Extra arguments when using SCTLProV to detect deadlocks for BCG files|
    | `sctl_bcg_livelocklock_extra`| Extra arguments when using SCTLProV to detect livelocks for BCG files|
    
 6. `-extra-last`: Put the extra argument(s) at last. This is an optional argument. Currently, this option is used when running CADP.
 
 7. `-standard <filename>`: Specifies the file containing the standard answers for test cases.

    In our repository, files containing the standard answers of test cases are in the folder `answers`, and are listed as follows.

    |File Name|Content|
    |:-|:-|
    |`cp_answer`| Standard answers of test cases with Concurrent Processes|
    |`csp_answer`| Standard answers of test cases with Concurrent Sequential Processes|
    |`mutual_answer`| Standard answers of test cases with Mutual Exclusion Algorithms|
    |`ring_answer`| Standard answers of test cases with Ring Algorithms|
    |`bcg_deadlock_answer`| Standard answers of BCG test cases when detecting deadlocks|
    |`bcg_livelock_answer`| Standard answers of BCG test cases when detecting livelocks|

**Examples：**

Let us illustrate the usage of the testing program by an example:

  `run -exec /home/jian/SCTLProV/sctl -timeout 20m -dir /home/jian/benchmark1/p1/p01/sctl/ -surfix model -standard ./answers/cp_answer`

This example is explained as follows:
- The executable to be tested is `/home/jian/SCTLProV/sctl`;
- The timeout limit is `20` minutes;
- The directory containing the test cases is `/home/jian/benchmark1/p1/p01/sctl/`;
- Each test case is a `*.model` file;
- The standard answers of test cases are in the file `./answers/cp_answer`.


## How to read the result file?

After the testing program terminates, the testing results are listed in the auto-generated files `result_<timestamp>` and `result_<timestamp>_data`.

The file `result_<timestamp>` contains the detailed usage of computer resources for test cases, which are generated by the command `/usr/bin/time -v`.

For the file `result_<timestamp>_data`, each line of it has the following form

```
<filename> <status> Time:<time> Memory:<memory>
```
which is explained as follows.
* `filename`: name of the input file (test case).
* `status`: may be one of the following options: 
    - `NotSolvable`: the test case is not solvable, due to either timeout or out of memory;
    - `Pass`: result of the test case is equal to the standard answer;
    - `NotPass`: result of the test case is NOT equal to the standard answer, which indicates an failure;
    - `NoAnswer`: cannot find the standard answer of the test case.
* `time`: in seconds.
* `memory`: in MB.

**Note:**

Inside the script, `/usr/bin/time -v` is used to generate the time and memory usage for each test cases. For test cases where more accurate time usage is needed, please use `time` instead of `/usr/bin/time`.


## For other tools

This testing program can also be used for other tools, see the following examples. 

- Verds:

  `run -exec /home/jian/verds/verds -timeout 20m -dir /home/jian/benchmark1/p1/p01/verds/ -surfix vvm -extra ./extras/verds_extra`

- iProver Modulo:

  `run -exec /home/jian/iprover/iproveropt -timeout 20m -dir /home/jian/benchmark1/p1/p01/iprover/ -surfix p -extra ./extras/iprover_extra`

- NuSMV/NuXMV:

  `run -exec /home/jian/nusmv/bin/NuSMV -timeout 20m -dir /home/jian/benchmark1/p1/p01/smv/ -surfix smv -extra ./extras/nusmv_extra`
- CADP:

  `run -exec /home/jian/cadp/com/bcg_open -timeout 20m -dir /home/jian/bcg_benchmark/ -surfix bcg -extra ./extras/cadp_deadlock_extra -extra-last`

