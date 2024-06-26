{
  system.activationScripts.media =
    ''
      mkdir -m 775 -p /data/media/storage
      mkdir -m 775 -p /data/media/storage/downloads
      mkdir -m 775 -p /data/media/storage/downloads/movies
      mkdir -m 775 -p /data/media/storage/downloads/music
      mkdir -m 775 -p /data/media/storage/downloads/shows
      mkdir -m 775 -p /data/media/storage/downloads/other
      mkdir -m 775 -p /data/media/storage/organized
      mkdir -m 775 -p /data/media/storage/organized/movies
      mkdir -m 775 -p /data/media/storage/organized/music
      mkdir -m 775 -p /data/media/storage/organized/shows
      mkdir -m 775 -p /data/media/storage/organized/other

      mkdir -m 775 -p /data/media/temp
      mkdir -m 775 -p /data/media/temp/blackhole
      mkdir -m 775 -p /data/media/temp/blackhole/movies
      mkdir -m 775 -p /data/media/temp/blackhole/music
      mkdir -m 775 -p /data/media/temp/blackhole/shows
      mkdir -m 775 -p /data/media/temp/processing
      chown -R mediamgmt:media /data/media
      chown root:users /data/personal
      chmod 775 /data/personal
    '';
}