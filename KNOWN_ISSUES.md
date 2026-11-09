# Status and known issues

Remaining known issues and TODOs:

* For newly created securities, PP may not output empty `<events/>` element,
  while ppdb always does. Or to put it differently, PP may either have
  empty `<events/>` element, or not have it at all, while ppdb always
  outputs it. This is a known source of differences in output during
  round-tripping. This is rooted in details of internal representation:
  on the PP level, events may be either a null value, or an empty list.
  On the database side, events are represented by a table and rows in it,
  so there is no natural way to distinguish between "no events" and
  "empty events list". Nor conceptually these cases are different, why
  this unfortunate but harmless case of round-tripping diff is left alone.
  It might be possible to work that around to achieve perfect round-tripping,
  by storing additional data in the database, but that would contradict
  one of the ppdb's goals - to match as close as possible PP's object
  schema, without questionable additions and definitely without adhoc
  workarounds.
* Various features / additional properties of other objects may be not
  supported.
