(* HHVM module for Augeas *)
(* Author: Robin Gloster <robin.gloster@mayflower.de> *)
(* *)

module HHVM =
autoload xfm

(************************************************************************
* INI File settings
*************************************************************************)

let comment = IniFile.comment IniFile.comment_re IniFile.comment_default
let sep = IniFile.sep IniFile.sep_re IniFile.sep_default
let empty = IniFile.empty


(************************************************************************
* ENTRY
*
* We have to remove the keyword "section" from possible entry keywords
* otherwise it would lead to an ambiguity with the "section" label
* since PHP allows entries outside of sections.
*************************************************************************)
let entry =
let word = IniFile.entry_re
in let entry_re = word . ( "[" . word . "]" )?
in IniFile.indented_entry entry_re sep comment


(************************************************************************
* TITLE
*
* We use IniFile.title_label because there can be entries
* outside of sections whose labels would conflict with section names
*************************************************************************)
let title = IniFile.title ( IniFile.record_re - ".anon" )
let record = IniFile.record title entry

let record_anon = [ label ".anon" . ( entry | empty )+ ]


(************************************************************************
* LENS & FILTER
* There can be entries before any section
* IniFile.entry includes comment management, so we just pass entry to lns
*************************************************************************)
let lns = record_anon? . record*

let filter = (incl "/etc/hhvm/*.ini")
. (incl "/etc/default/hhvm")
. Util.stdexcl

let xfm = transform lns filter
