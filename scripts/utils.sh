utils_distro() {
  if [ -f /etc/os-release ]; then
      # freedesktop.org and systemd
      . /etc/os-release
      OS=$NAME
      VER=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then
      # linuxbase.org
      OS=$(lsb_release -si)
      VER=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then
      # For some versions of Debian/Ubuntu without lsb_release command
      . /etc/lsb-release
      OS=$DISTRIB_ID
      VER=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then
      # Older Debian/Ubuntu/etc.
      OS=Debian
      VER=$(cat /etc/debian_version)
  elif [ -f /etc/SuSe-release ]; then
      # Older SuSE/etc.
      ...
  elif [ -f /etc/redhat-release ]; then
      # Older Red Hat, CentOS, etc.
      ...
  else
      # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
      OS=$(uname -s)
      VER=$(uname -r)
  fi
}


# Read secret string
utils_read_secret()
{
    # Disable echo.
    stty -echo

    # Set up trap to ensure echo is enabled before exiting if the script
    # is terminated while echo is disabled.
    trap 'stty echo' EXIT

    # Read secret.
    read "$@"

    # Enable echo.
    stty echo
    trap - EXIT

    # Print a newline because the newline entered by the user after
    # entering the passcode is not echoed. This ensures that the
    # next line of output begins at a new line.
    echo
}
