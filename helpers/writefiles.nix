{pkgs,...}:

with pkgs;
let
  writeFiles = name: fileInfoList:
    let
      f = builtins.foldl' (acc: elem:
        (acc + ''
          echo '${elem.text}' > $out/${elem.name}
        ''));
      script = writeShellScript "builder.sh" (f '''' fileInfoList);
    in
    stdenv.mkDerivation rec {
      inherit name;
      phases = "buildPhase";
      builder = script;
    };
in
  writeFiles

