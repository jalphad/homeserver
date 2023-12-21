{
  system.activationScripts.media =
    ''
      chown root:media /data/media
      mkdir -m 775 -p /data/media/storage
      mkdir -m 775 -p /data/media/storage/downloads
      mkdir -m 775 -p /data/media/storage/downloads/movies
      mkdir -m 775 -p /data/media/storage/downloads/music
      mkdir -m 775 -p /data/media/storage/downloads/shows
      mkdir -m 775 -p /data/media/storage/movies
      mkdir -m 775 -p /data/media/storage/music
      mkdir -m 775 -p /data/media/storage/shows

      mkdir -m 775 -p /data/media/temp
      mkdir -m 775 -p /data/media/temp/blackhole
      mkdir -m 775 -p /data/media/temp/blackhole/movies
      mkdir -m 775 -p /data/media/temp/blackhole/music
      mkdir -m 775 -p /data/media/temp/blackhole/shows
      mkdir -m 775 -p /data/media/temp/processing
    '';
}