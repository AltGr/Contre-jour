// Contre-jour
// a simple image gallery viewer in OPA
//
// written by Louis Gesbert

import stdlib.io.file

thumbsize=200
imgwidth=800

Jpeg = {{
  thumb(file) =
    { jpg = (%%Jpeg.thumb%%)(file, thumbsize, thumbsize) }
  resize(file,w,h) =
    { jpg = (%%Jpeg.resize%%)(file,w,h) }
}}

get_image_files(dir) =
  fold_dir = %%BslFile.fold_dir_rec_opt%%
  lst = fold_dir((lst,_name,path -> "{path}" +> lst), {nil}, dir)
  Option.map(List.sort,lst)

disp(img) =
  [ #imgdiv <- <a href="/full/{Uri.encode_string(img)}"><img class=medium src="/medium/{img}" /></a> ]

image_elt(img) =
  <img class=thumb src="/thumb/{Uri.encode_string(img)}" onclick={_ -> Dom.transform(disp(img))} />

page(dir) =
  <div id=#main>
    <h3>Showing pictures in {dir}</h3>
    <div id=#imgdiv />
  </div>
  <div id=#list>{
    match get_image_files(dir) with
      ~{some} -> <ul>{List.fold((x,acc -> acc <+> <li>{image_elt(x)}</li> ),some,<></>)}</ul>
      {none} -> <>Error: could not load images</>
  }</div>

fullimage(jpg) =
  Resource.image({ jpg = File.content(jpg) })
medimage(jpg) =
  Resource.image(cache(@/medium[jpg], -> Jpeg.resize(jpg, imgwidth, imgwidth)))
thumb(jpg) =
  Resource.image(cache(@/thumb[jpg], -> Jpeg.thumb(jpg)))

database ./thumbcache/
db /thumb : stringmap(option(image))
db /thumb[_] full
db /medium : stringmap(option(image))
db /medium[_] full

cache(dbpath,compute) =
  match Db.read(dbpath) with
    ~{some} -> some
    {none} ->
      img = compute()
      do dbpath <- {some = img}
      img

server =
  dirname = parser f=([a-zA-Z0-9][-a-zA-Z0-9._ ]*) -> Text.to_string(f)
  ext_jpg = parser ext=(".jpg"|".jpeg"|".JPG") -> ext
  jpg = parser f=(dirname "/" [a-zA-Z0-9] (!ext_jpg [-a-zA-Z0-9._ ])* ext_jpg) -> Text.to_string(f)
  simple_server(
    parser
      | "/full/" ~jpg -> fullimage(jpg)
      | "/medium/" ~jpg -> medimage(jpg)
      | "/thumb/" ~jpg -> thumb(jpg)
      | "/" ~dirname -> html("Contre-jour: a simple gallery in OPA ({dirname})", page(dirname))
  )

css = css
body {
  color: white;
  background-color: black;
}

div#main {
  position: fixed;
  right: {px(float_of_int(thumbsize) * 1.2)};
  top: 0px;
  left: 0px;
  bottom: 0px;
}

div#list {
  position: absolute;
  top: 0px;
  width: {px(float_of_int(thumbsize) * 1.2)};
  right: 0px;
}

#list ul {
  list-style-type: none;
  padding: 0;
}

#list li {
  margin-top: 20px;
  margin-bottom: 20px;
}

h3 {
  text-align: center;
}

img.thumb {
  display: block;
  margin: auto;
  border: 3px solid white;
}

img.medium {
  display: block;
  margin: auto;
  border: 8px solid white;
}
