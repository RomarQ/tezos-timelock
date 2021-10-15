open Js_of_ocaml

module Interface : sig
  open Js

  val create_chest_and_chest_key : js_string t -> int -> js_string t

  val create_chest : js_string t -> int -> js_string t

  val create_chest_key : js_string t -> int -> js_string t

  val open_chest : js_string t -> js_string t -> int -> js_string t
end = struct
  let create_chest_and_chest_key payload time =
    let payload = Js.to_string payload in
    let payload = Hex.to_bytes (`Hex payload) in
    let chest, chest_key = Timelock.create_chest_and_chest_key ~payload ~time in
    let chest = Timelock.bytes_of_chest chest in
    let chest_key = Timelock.bytes_of_chest_key chest_key in
    let result =
      object%js (self)
        val chest = chest [@@readwrite]

        val key = chest_key [@@readwrite]
      end
    in
    Json.output result

  let create_chest payload time =
    let payload = Js.to_string payload in
    let payload = Hex.to_bytes (`Hex payload) in

    let public, secret = Timelock.gen_rsa_keys () in
    let locked_value = Timelock.gen_locked_value public in
    let unlocked_value =
      Timelock.unlock_with_secret secret ~time locked_value
    in
    let sym_key = Timelock.unlocked_value_to_symmetric_key unlocked_value in
    let c = Timelock.encrypt sym_key payload in
    let chest = Timelock.{locked_value; rsa_public = public; ciphertext = c} in
    Js.string (Timelock.bytes_of_chest chest)

  let create_chest_key chest time =
    let chest = Js.to_string chest |> Timelock.chest_of_bytes in
    let chest_key = Timelock.create_chest_key ~time chest in
    Timelock.bytes_of_chest_key chest_key |> Js.string

  let open_chest chest chest_key time =
    let chest = Js.to_string chest |> Timelock.chest_of_bytes in
    let chest_key = Js.to_string chest_key |> Timelock.chest_key_of_bytes in
    let result = Timelock.open_chest chest chest_key ~time in
    match result with
    | Correct bytes ->
        let (`Hex bytes) = Hex.of_bytes bytes in
        Json.output
          (object%js (self)
             val kind = "Correct" [@@readwrite]

             val bytes = bytes [@@readwrite]
          end)
    | Bogus_cipher ->
        Json.output
          (object%js (self)
             val kind = "Bogus_cipher" [@@readwrite]
          end)
    | Bogus_opening ->
        Json.output
          (object%js (self)
             val kind = "Bogus_opening" [@@readwrite]
          end)
end

let export_to_js s f =
  Js.Unsafe.set (Js.Unsafe.variable "exports") s (Js.wrap_callback f)

let[@ocaml.warning "-21"] () =
  (* Export public methods*)
  Js.Unsafe.eval_string
    (Printf.sprintf "const globalScope = typeof globalThis !== 'undefined' ? globalThis : (typeof window !== 'undefined' ? window : global);globalScope.exports = globalScope.exports || {}");
  export_to_js "create_chest_and_chest_key" Interface.create_chest_and_chest_key;
  export_to_js "create_chest_key" Interface.create_chest_key;
  export_to_js "open_chest" Interface.open_chest
