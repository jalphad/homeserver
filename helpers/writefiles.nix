{pkgs,...}:

with pkgs;
let
  writeFiles = name: fileInfoList:
    let
      prepare = ''
        mkdir -p $out
      '';
      f = builtins.foldl' (acc: elem:
        (acc + ''
          echo '${elem.text}' > $out/${elem.name}
        ''));
      script = writeShellScript "builder.sh" (f prepare fileInfoList);
    in
    stdenv.mkDerivation rec {
      inherit name;
      phases = "installPhase";
      installPhase = script;
    };
in
  writeFiles

