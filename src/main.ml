open Unix
open Parser
open Printf
open Res

let calculate_timeout tmot = 
	(* if Str.string_match (Str.regexp "[0-9]+") tmot 0 then *)
		
	if Str.string_match (Str.regexp "[0-9]+s") tmot 0 then
		int_of_string (String.sub tmot 0 (String.length tmot - 1))
	else if Str.string_match (Str.regexp "[0-9]+m") tmot 0 then
		60 * (int_of_string (String.sub tmot 0 (String.length tmot - 1)))
	else if Str.string_match (Str.regexp "[0-9]+h") tmot 0 then
		3600 * (int_of_string (String.sub tmot 0 (String.length tmot - 1)))
	else if Str.string_match (Str.regexp "[0-9]+d") tmot 0 then
		24 * 3600 * (int_of_string (String.sub tmot 0 (String.length tmot - 1)))
	else 
	int_of_string tmot
		(* failwith "not a valid timeout" *)

let main () = 
	let result = Hashtbl.create 10 in
	let correct = Hashtbl.create 10 in
	let mode = ref "timememory" in
  let current_dir = Sys.getcwd () in
  let tm = localtime (time ()) in
  let result_file = (Sys.getcwd ())^"/results/result_"^
                    (string_of_int (tm.tm_year+1900))^"-"^
                    (string_of_int tm.tm_mon)^"-"^
                    (string_of_int tm.tm_mday)^"-"^
                    (string_of_int tm.tm_hour)^"-"^
                    (string_of_int tm.tm_min)^"-"^
                    (string_of_int tm.tm_sec) in
  print_endline result_file;
  let exec = ref "" in
  let timeout = ref "" in
  let dir = ref "" in
  let extra = ref "" in
  let surfix = ref "" in
	let command = ref " timeout " in
	let extra_last = ref false in
	let standard = ref "" in
  (* if !mode = "time" then
    command := "time -a -o "^result_file^" timeout "
  else 
    command := ("/usr/bin/time -v -a -o "^result_file^" timeout "); *)
  Arg.parse
    [
      "-exec", Arg.String (fun s -> exec := s), "\tThe executable and argument(s)";
      "-timeout", Arg.String (fun s -> timeout := s), "\tSet timeout";
      "-dir", Arg.String (fun s -> dir := s), "\tTarget directory of the test cases";
      "-surfix", Arg.String (fun s -> surfix := s), "\tSurfix of the test cases";
			"-extra", Arg.String (fun s -> extra := s), "\tExtra argument(s)";
			"-extra-last", Arg.Unit (fun () -> extra_last := true), "\tPut extra argument(s) at last";
			"-standard", Arg.String (fun s -> standard := s), "\tStandard answers of test cases"
    ]
    (fun s -> printf "Unknown argument: %s\n" s; exit 1)
		"Usage: run -exec <command> -timeout <timeout> -dir <targetdir> -surfix <surfix> -extra <filename> -standard <filename> [-extra-last]";
	(* read the standard answer from file*)
	if !standard <> "" then begin
		let standard_in = open_in !standard in
		try while true do
			let s = input_line standard_in in
			let ss = String.split_on_char ':' s in
			let mname = String.trim (List.hd ss)
			and manswer = bool_of_string (String.trim (List.nth ss 1)) in
			Hashtbl.add correct mname manswer
		done with _ -> ()
	end;
	(* calculate the timeout seconds*)
	let timeout_secs = float_of_int (calculate_timeout !timeout) in
  let extra_arguments = 
    try
      input_line (open_in !extra)
    with _ -> "" in 
  let files = Sys.readdir !dir in
  (* if !mode = "time" then
    ignore (Sys.command ("script -a "^result_file)); *)
	Array.sort (Pervasives.compare) files;
	let error_cases = ref [] in
  Array.iter ( fun file ->
      if (List.nth (String.split_on_char '.' file) 1) = !surfix then begin
        let exec_path_items = String.split_on_char '/' !exec in
        let exec_dir = ref "/" in
        for i = 0 to List.length exec_path_items - 2 do
          let tmp_item = List.nth exec_path_items i in
          if  tmp_item <> "" then
            exec_dir := !exec_dir ^ tmp_item ^ "/"
        done;
        Sys.chdir !exec_dir;
        let exec_name = "./"^ (List.nth exec_path_items (List.length exec_path_items - 1)) in
        let dir_items = String.split_on_char '/' !dir in
        let new_dir = ref "/" in
        List.iter (fun item -> if item <> "" then new_dir := !new_dir ^ item ^ "/") dir_items;
        let new_command = ref "" in
        if !mode = "time" then begin
          new_command := "time "^ !command ^ !timeout ^ " " ^ exec_name ^ " " ^ extra_arguments ^ " " ^ !new_dir ^ file
				end else begin 
					if !extra_last then
						new_command := "/usr/bin/time -v -a -o "^result_file ^" "^ !command ^ !timeout ^ " " ^ exec_name ^ " " ^ !new_dir ^ file ^ " " ^ extra_arguments ^ " > " ^ current_dir ^ "/test.out"
					else
          	new_command := "/usr/bin/time -v -a -o "^result_file ^" "^ !command ^ !timeout ^ " " ^ exec_name ^ " " ^ extra_arguments ^ " " ^ !new_dir ^ file ^ " > " ^ current_dir ^ "/test.out"
        end;
				(* print_endline ("command: "^ !new_command); *)
				print_endline ("************************"^file^"*************************");
				(* print_endline(!new_command); *)
				ignore(Sys.command !new_command);
				begin
					let flag = ref true in
					try 
						let tmp_res = open_in (current_dir^"/test.out") in
						let error_regexps = ["exception encountered"; "Terminated"; "terminated by a signal"; "Fatal error"] in
						(* let solvable_regexps = [""] in *)
						while !flag do
							let s = input_line tmp_res in
							(* When a test is not solvable *)
							if List.fold_left (fun b e -> if not b then Str.string_match (Str.regexp e) s 0 else b) false error_regexps then begin
								error_cases := file :: !error_cases;
								flag := false
							end else begin (* when a test case is solvable *)
								let sctltrue = Str.regexp ".*: true"
								and sctlfalse = Str.regexp ".*: false"
								and verdstrue = Str.regexp "CONCLUSION: TRUE"
								and verdsfalse = Str.regexp "CONCLUSION: FALSE"
								and smvtrue = Str.regexp "-- specification.* is true"
								and smvfalse = Str.regexp "-- specification.* is false" 
								and cadptrue = Str.regexp "TRUE"
								and cadpfalse = Str.regexp "FALSE" in
								let mname = List.hd (String.split_on_char '.' file) in
								if Str.string_match sctltrue s 0 || Str.string_match verdstrue s 0 || Str.string_match smvtrue s 0 || (!surfix = "bcg" && (Str.string_match cadptrue s 0)) then begin
									Hashtbl.add result mname true;
									flag := false
								end else if Str.string_match sctlfalse s 0 || Str.string_match verdsfalse s 0 || Str.string_match smvfalse s 0 || (!surfix = "bcg" && (Str.string_match cadpfalse s 0)) then begin
									Hashtbl.add result mname false;
									flag := false
								end
							end
						done
					with _ -> flag := false
				end;
        Sys.chdir current_dir
      end
		) files;
	ignore (Sys.command ("rm -f "^current_dir^"/test.out"));
	let file_list = ref [] in
	Array.iter (fun f -> if List.nth (String.split_on_char '.' f) 1 = !surfix then file_list := !file_list @ [f]) files;
	try
		let filename = result_file in
		let res_list = Parser.input Lexer.token (Lexing.from_channel (open_in filename)) in
		(* let out = open_out (filename^"_time_list") in
		List.iter (fun a -> output_string out ((string_of_float a)^"\n")) time_list; *)
		let out = open_out (result_file^"_data") in
		(* output_string out "Filename\t\tStatus\t\tTime(s)\t\tMemory(MB)\n"; *)
		let index = ref 0 in
		List.iter (fun r -> 
			let file = (List.nth !file_list (!index)) in
			output_string out file; 
			(*output the status of test case*)
			if !standard = "" then
				Hashtbl.clear result;
			if Hashtbl.length result <> 0 then begin
				if List.exists (fun f -> f=file) !error_cases || r.clock_time >= timeout_secs then
						output_string out "\t\tNotSolvable"
				else begin
					let mname = List.hd (String.split_on_char '.' file) in
					if (Hashtbl.mem correct mname) && (Hashtbl.find result mname) = (Hashtbl.find correct mname) then
						output_string out "\t\tPass       "
					else if (Hashtbl.mem correct mname) && (Hashtbl.find result mname) <> (Hashtbl.find correct mname) then
						output_string out "\t\tNotPass    "
					else 
						output_string out "\t\tNoAnswer   "
				end
			end;
			(*output time usage*)
			output_string out "\t\tTime: "; 
			begin
				if List.exists (fun f -> f=file) !error_cases || r.clock_time >= timeout_secs then
					output_string out "-"
				else 
					output_string out (string_of_float r.clock_time)
			end;
			(* output_string out " s"; *)
			output_string out "\t\tMemory: "; 
			begin
				if List.exists (fun f -> f=file) !error_cases || r.clock_time >= timeout_secs then
					output_string out "-"
				else 
				output_string out (string_of_float ((float_of_int r.max_res_size)/.1024.0))
			end;
			(* output_string out " MB"; *)
			output_string out "\n"; 
			incr index) res_list;
		printf "Result: see file %s\n" result_file;
		printf "Data: see file %s\n" (result_file^"_data");
		flush out;
		close_out out
	with _ -> print_endline ("exception at line: "^(string_of_int (!(Lexer.line_num))))
	
let _ = 
	Printexc.print main ()
