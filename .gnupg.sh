#!/bin/sh

if [ -d ~/.gnupg ]; then
  if echo "$(mountpoint ~/.gnupg)" | grep -q "is a mountpoint"; then
    # ~/.gnupg is a bind mount from the host
    return 0;
  fi
fi

if [ ! -d /mnt/gnupg ]; then
  echo "No bind mounted ssh directory found (~/.gnupg, /mnt/gnupg), exiting"
  return 0
fi

if [ "$(stat -c '%U' /mnt/ssh)" != "UNKNOWN" ]; then
  echo "Unix host detected, symlinking /mnt/gnupg to ~/.gnupg"
  rm -r ~/.gnupg
  ln -s /mnt/gnupg ~/.gnupg
  return 0
fi