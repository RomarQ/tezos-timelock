(*****************************************************************************)
(*                                                                           *)
(* Open Source License                                                       *)
(* Copyright (c) 2018 Dynamic Ledger Solutions, Inc. <contact@tezos.com>     *)
(*                                                                           *)
(* Permission is hereby granted, free of charge, to any person obtaining a   *)
(* copy of this software and associated documentation files (the "Software"),*)
(* to deal in the Software without restriction, including without limitation *)
(* the rights to use, copy, modify, merge, publish, distribute, sublicense,  *)
(* and/or sell copies of the Software, and to permit persons to whom the     *)
(* Software is furnished to do so, subject to the following conditions:      *)
(*                                                                           *)
(* The above copyright notice and this permission notice shall be included   *)
(* in all copies or substantial portions of the Software.                    *)
(*                                                                           *)
(* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR*)
(* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  *)
(* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL   *)
(* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER*)
(* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING   *)
(* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER       *)
(* DEALINGS IN THE SOFTWARE.                                                 *)
(*                                                                           *)
(*****************************************************************************)

open Tezos_hacl_glue.Hacl

module Blake2B = struct
  let to_bytes (Blake2b.Hash h) = h

  let hash_string ?key l =
    let key = Option.map Bytes.of_string key in
    let input = String.concat "" l in
    Blake2b.direct ?key (Bytes.of_string input) 32
end

module Secretbox = struct
  include Tezos_hacl_glue.Hacl.Secretbox

  let secretbox key msg nonce =
    let msglen = Bytes.length msg in
    let cmsg = Bytes.create (msglen + tagbytes) in
    secretbox ~key ~nonce ~msg ~cmsg;
    cmsg

  let secretbox_open key cmsg nonce =
    let cmsglen = Bytes.length cmsg in
    let msg = Bytes.create (cmsglen - tagbytes) in
    match secretbox_open ~key ~nonce ~cmsg ~msg with
    | false -> None
    | true -> Some msg
end

let tag_length = Box.tagbytes

let random_nonce = Nonce.gen

let nonce_size = Nonce.size

let nonce_encoding = Data_encoding.Fixed.bytes nonce_size
