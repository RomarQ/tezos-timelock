type command =
  | CreateChestAndChestKey of { payload: string; time: int }
  | OpenChest of {chest: string; chest_key: string; time: int }

let rec print_divider ?(lines = 1) () =
  print_endline "==================================";
  if lines > 1 then print_divider ~lines:(lines-1) () else ()

let usage () =
  print_endline {|
    Usage: timelock [COMMAND] [ARGS]

    [COMMAND]

    > create_chest_and_chest_key

          Create a chest and a chest key given a payload and the number of puzzle iterations.

        [ARGS]

            --payload <bytes>
                Packed bytes to be encrypted.

            --time <iterations>
                Number of puzzle iterations. Works in logarithmic time.

      ------------------

    > open-chest

        Open chest

        [ARGS]

            --chest <bytes>

            --chest-key <bytes>

            --time <iterations>
                Number of puzzle iterations. Works in logarithmic time.

    [EXAMPLES]

        timelock create-chest-and-chest-key --payload "05010000000b48454c4c4f20574f524c44" --time 2000

        timelock open-chest --chest "..." --chest-key "..." --time 2000
  |};
  exit 2

let rec parse_args args = function
  | ("--payload" | "--time" | "--chest" | "--chest-key") as field :: value :: rest ->
    parse_args (args @ [(Base.String.chop_prefix_exn ~prefix:"--" field, value)]) rest
  | _ -> args

let parse_command = function
  | "create-chest-and-chest-key" :: rest ->
    let args = parse_args [] rest in
    let payload = List.find_opt (fun (name, _) -> name = "payload") args in
    let time = List.find_opt (fun (name, _) -> name = "time") args in
    (match (payload, time) with
    | (Some (_, payload), Some (_, time)) -> CreateChestAndChestKey { payload; time = int_of_string time }
    | _, _ -> usage ())
  | "open-chest" :: rest ->
    let args = parse_args [] rest in
    let chest = List.find_opt (fun (name, _) -> name = "chest") args in
    let chest_key = List.find_opt (fun (name, _) -> name = "chest-key") args in
    let time = List.find_opt (fun (name, _) -> name = "time") args in
    (match (chest, chest_key, time) with
    | (Some (_, chest), Some (_, chest_key), Some (_, time)) -> OpenChest { chest; chest_key; time = int_of_string time }
    | _, _, _ -> usage ())
  | _ -> usage ()

let run () =
  let command = parse_command (List.tl (Array.to_list Sys.argv)) in

  match command with
  | CreateChestAndChestKey { payload; time} ->
    (* Print inputs *)
    print_endline "\n\nINPUTS";
    print_divider ();
    print_endline (Printf.sprintf "Payload: %s" payload);
    print_divider ();
    print_endline (Printf.sprintf "Time: %d\n" time);

    let chest, chest_key = Timelock.create_chest_and_chest_key ~payload:(Hex.to_bytes (`Hex payload)) ~time in
    let chest = Timelock.bytes_of_chest chest in
    let chest_key = Timelock.bytes_of_chest_key chest_key in

    (* Print outputs *)
    print_endline "OUTPUTS";
    print_divider ();
    print_endline (Printf.sprintf "Chest: %s" chest);
    print_divider ();
    print_endline (Printf.sprintf "Chest key: %s" chest_key)

  | OpenChest { chest; chest_key; time } ->
    (* Print inputs *)
    print_endline "\n\nINPUTS";
    print_divider ();
    print_endline (Printf.sprintf "Chest: %s" chest);
    print_divider ();
    print_endline (Printf.sprintf "Chest key: %s\n" chest_key);
    print_divider ();
    print_endline (Printf.sprintf "Time: %d\n" time);

    let chest = Timelock.chest_of_bytes chest in
    let chest_key = Timelock.chest_key_of_bytes chest_key in
    let result = Timelock.open_chest chest chest_key ~time in

    let result = (match result with
    | Correct bytes ->
        let (`Hex bytes) = Hex.of_bytes bytes in
        "Correct: " ^ bytes
    | Bogus_cipher -> "Bogus_cipher"
    | Bogus_opening -> "Bogus_opening") in

    (* Print outputs *)
    print_endline "OUTPUTS";
    print_divider ();
    print_endline (Printf.sprintf "Result : %s" result)

let main =
  try run () with
    | exn ->
      print_endline (Printexc.to_string exn);
      exit 1
