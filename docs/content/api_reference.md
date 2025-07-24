+++
date = '2025-07-02T15:13:58+03:00'
draft = false
title = 'Package API'
+++

The Jodin package should be located in **Odin/shared/jodin**, which is implicitly imported in every cell. Everything here is under namespace **jodin**.

---

## Cell_Info

```odin
Cell_Info :: struct {
	id:   string,
	name: string,
	code: string
}
```

Object holding information about the current cell.

---

## Audio_Format

```odin
Audio_Format :: enum u8 {
	AAC,
	MP3,
	WAV,
	WEBM
}
```

Audio formats supported by the Jupyter front-end.

---

## Image_Format

```odin
Image_Format :: enum u8 {
	PNG,
	JPEG,
	GIF,
	WEBP
}
```

Image formats supported by the Jupyter front-end.

---

## cell_info

```odin
cell_info :: proc() -> Cell_Info {…}
```

Get info about the current cell.

---

## clear_output

```odin
clear_output :: proc(
	wait: bool = false
) -> bool {…}
```

Clear the output currently visible in the front-end. If **wait** is **true**, the output will be cleared only when new output becomes available.

---

## display_audio

```odin
display_audio :: proc(
	data: []u8,
	format: Audio_Format,
	element_id: string = "",
	loc: = #caller_location
) -> (err: Error) {…}
```

Display audio in the front-end.

---

## display_image

```odin
display_image :: proc{
	display_image_from_data_and_format_and_size,
	display_image_from_data_and_format,
	display_image_from_filepath,
	display_image_from_filepath_and_size
}
```

Display image in the front-end.

---

## display_image_from_data_and_format_and_size

```odin
display_image_from_data_and_format_and_size :: proc(
	data: []u8,
	format: Image_Format,
	size: [2]uint,
	display_id: string = "",
	loc: = #caller_location
) -> (err: Error) {…}
```

---

## display_image_from_data_and_format

```odin
display_image_from_data_and_format :: proc(
	data: []u8,
	format: Image_Format,
	display_id: string = "",
	loc: = #caller_location
) -> (err: Error) {…}
```

---

## display_image_from_filepath_and_size

```odin
display_image_from_filepath_and_size :: proc(
	path: string,
	size: [2]uint,
	display_id: string = "",
	loc: = #caller_location
) -> (err: Error) {…}
```

---

## display_image_from_filepath

```odin
display_image_from_filepath:: proc(
	path: string,
	display_id: string = "",
	loc: = #caller_location
) -> (err: Error) {…}
```

---

## inspect

```odin
inspect:: proc(
	x: $T
) {…}
```

Pretty-print information about an object.

---

## inspect_detailed

```odin
inspect_detailed:: proc(
	x: $T
) {…}
```

Pretty-print detailed information about an object.

---
