{ pkgs, ... }:

with pkgs;

let 
  sshaPwdHash = password: 
    builtins.readFile (
      runCommand "passwordhash" { buildInputs = [ openldap ]; }
        "echo -n ${password} | slappasswd -n -T /dev/stdin > $out"
    );
in
  sshaPwdHash