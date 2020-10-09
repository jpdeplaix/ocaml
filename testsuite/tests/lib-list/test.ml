(* TEST
*)

let is_even x = (x mod 2 = 0)

let string_of_even_opt x =
  if is_even x then
    Some (string_of_int x)
  else
    None

let string_of_even_or_int x =
  if is_even x then
    Either.Left (string_of_int x)
  else
    Either.Right x

(* Standard test case *)
let () =
  let l = List.init 10 (fun x -> x) in
  let sl = List.init 10 string_of_int in
  assert (List.exists (fun a -> a < 10) l);
  assert (List.exists (fun a -> a > 0) l);
  assert (List.exists (fun a -> a = 0) l);
  assert (List.exists (fun a -> a = 1) l);
  assert (List.exists (fun a -> a = 2) l);
  assert (List.exists (fun a -> a = 3) l);
  assert (List.exists (fun a -> a = 4) l);
  assert (List.exists (fun a -> a = 5) l);
  assert (List.exists (fun a -> a = 6) l);
  assert (List.exists (fun a -> a = 7) l);
  assert (List.exists (fun a -> a = 8) l);
  assert (List.exists (fun a -> a = 9) l);
  assert (not (List.exists (fun a -> a < 0) l));
  assert (not (List.exists (fun a -> a > 9) l));
  assert (List.exists (fun _ -> true) l);

  assert (List.equal (=) [1; 2; 3] [1; 2; 3]);
  assert (not (List.equal (=) [1; 2; 3] [1; 2]));
  assert (not (List.equal (=) [1; 2; 3] [1; 3; 2]));

  (* The current implementation of List.equal calls the comparison
     function even for different-size lists. This is not part of the
     specification, so it would be valid to change this behavior, but
     we don't want to change it without noticing so here is a test for
     it. *)
  assert (let c = ref 0 in
          not (List.equal (fun _ _ -> incr c; true) [1; 2] [1; 2; 3])
          && !c = 2);

  assert (List.compare compare [1; 2; 3] [1; 2; 3] = 0);
  assert (List.compare compare [1; 2; 3] [1; 2] > 0);
  assert (List.compare compare [1; 2; 3] [1; 3; 2] < 0);
  assert (List.compare compare [3] [2; 1] > 0);

  begin
    let f ~limit a = if a >= limit then Some (a, limit) else None in
    assert (List.find_map (f ~limit:3) [] = None);
    assert (List.find_map (f ~limit:3) l = Some (3, 3));
    assert (List.find_map (f ~limit:30) l = None);
  end;

  assert (List.filteri (fun i _ -> i < 2) (List.rev l) = [9; 8]);

  let hello = ['H';'e';'l';'l';'o'] in
  let world = ['W';'o';'r';'l';'d';'!'] in
  let hello_world = hello @ [' '] @ world in
  assert (List.take 5 hello_world = hello);
  assert (List.take 3 [1; 2; 3; 4; 5] = [1; 2; 3]);
  assert (List.take 3 [1; 2] = [1; 2]);
  assert (List.take 3 [] = []);
  assert (List.take (-1) [1; 2] = []);
  assert (List.take 0 [1; 2] = []);
  assert (List.drop 6 hello_world = world);
  assert (List.drop 3 [1; 2; 3; 4; 5] = [4; 5]);
  assert (List.drop 3 [1; 2] = []);
  assert (List.drop 3 [] = []);
  assert (List.drop (-1) [1; 2] = [1; 2]);
  assert (List.drop 0 [1; 2] = [1; 2]);
  assert (List.split_at 6 hello_world = (hello @ [' '], world));
  assert (List.split_at 3 [1; 2; 3; 4; 5] = ([1; 2; 3], [4; 5]));
  assert (List.split_at 1 [1; 2; 3] = ([1], [2; 3]));
  assert (List.split_at 3 [1; 2; 3] = ([1; 2; 3], []));
  assert (List.split_at 4 [1; 2; 3] = ([1; 2; 3], []));
  assert (List.split_at 0 [1; 2; 3] = ([], [1; 2; 3]));
  assert (List.split_at (-1) [1; 2; 3] = ([], [1; 2; 3]));
  assert (List.take_while (fun x -> x < 3) [1; 2; 3; 4; 1; 2; 3; 4]
          = [1; 2]);
  assert (List.take_while (fun x -> x < 9) [1; 2; 3] = [1; 2; 3]);
  assert (List.take_while (fun x -> x < 0) [1; 2; 3] = []);
  assert (List.drop_while (fun x -> x < 3) [1; 2; 3; 4; 5; 1; 2; 3]
          = [3; 4; 5; 1; 2; 3]);
  assert (List.drop_while (fun x -> x < 9) [1; 2; 3] = []);
  assert (List.drop_while (fun x -> x < 0) [1; 2; 3] = [1; 2; 3]);
  assert (List.partition is_even [1; 2; 3; 4; 5]
          = ([2; 4], [1; 3; 5]));
  assert (List.partition_map string_of_even_or_int [1; 2; 3; 4; 5]
          = (["2"; "4"], [1; 3; 5]));

  assert (List.compare_lengths [] [] = 0);
  assert (List.compare_lengths [1;2] ['a';'b'] = 0);
  assert (List.compare_lengths [] [1;2] < 0);
  assert (List.compare_lengths ['a'] [1;2] < 0);
  assert (List.compare_lengths [1;2] [] > 0);
  assert (List.compare_lengths [1;2] ['a'] > 0);

  assert (List.compare_length_with [] 0 = 0);
  assert (List.compare_length_with [] 1 < 0);
  assert (List.compare_length_with [] (-1) > 0);
  assert (List.compare_length_with [] max_int < 0);
  assert (List.compare_length_with [] min_int > 0);
  assert (List.compare_length_with [1] 0 > 0);
  assert (List.compare_length_with ['1'] 1 = 0);
  assert (List.compare_length_with ['1'] 2 < 0);
  assert (List.filter_map string_of_even_opt l = ["0";"2";"4";"6";"8"]);
  assert (List.concat_map (fun i -> [i; i+1]) [1; 5] = [1; 2; 5; 6]);
  assert (
    let count = ref 0 in
    List.concat_map (fun i -> incr count; [i; !count]) [1; 5] = [1; 1; 5; 2]);
  assert (List.fold_left_map (fun a b -> a + b, b) 0 l = (45, l));
  assert (List.fold_left_map (fun a b -> assert false) 0 [] = (0, []));
  assert (
    let f a b = a + b, string_of_int b in
    List.fold_left_map f 0 l = (45, sl));
  ()
;;

(* Empty test case *)
let () =
  assert ((List.init 0 (fun x -> x)) = []);
;;

(* Erroneous test case *)

let () =
  let result = try
      let _ = List.init (-1) (fun x -> x) in false
  with Invalid_argument e -> true (* Exception caught *)
  in assert result;
;;

(* Evaluation order *)
let () =
  let test n =
    let result = ref false in
    let _ = List.init n (fun x -> result := (x = n - 1)) in
    assert !result
  in
  (* Threshold must equal the value in stdlib/list.ml *)
  let threshold = 10_000 in
  test threshold; (* Non tail-recursive case *)
  test (threshold + 1) (* Tail-recursive case *)
;;

let () = print_endline "OK";;
