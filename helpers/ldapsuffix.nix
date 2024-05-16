{lib, ...}:

with lib.strings;
let
toLdapSuffix = attr:
  concatMapStringsSep "," (x: "dc=" + x) (splitString "." attr);
in 
toLdapSuffix


