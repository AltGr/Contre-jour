
let slurp ichan =
  let len = 10240 in
  let str = String.create len in
  let buf = Buffer.create 10240 in
  let rec aux () =
    let read = input ichan str 0 len in
    if read <> 0 then (
      Buffer.add_substring buf str 0 read;
      aux ()
    ) in
  aux ();
  Buffer.contents buf

##register thumb: string, int, int -> string
(* file, maxwidth, maxheight -> thumbnail *)
let thumb f w h =
  let ch =
    Unix.open_process_in (Printf.sprintf "convert -thumbnail %dx%d %S /dev/stdout" w h f)
  in
  let t = slurp ch in
  close_in ch;
  t

##register resize: string, int, int -> string
(* file, maxwidth, maxheight -> image_channel *)
let resize f w h =
  let ch =
    Unix.open_process_in (Printf.sprintf "convert -sample %dx%d %S /dev/stdout" w h f)
  in
  let t = slurp ch in
  close_in ch;
  t

##register comment: string -> string
(* file -> comment *)
let comment f = assert false
