{lib, ...}:

with lib;
let
toLdapSuffix = attr:
  concatMapStringsSep "," (x: "dc=" + x) (splitString "." attr);
in 
toLdapSuffix


