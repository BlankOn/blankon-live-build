# This will add /usr/sbin into PATH, but this will only work for terminal user also set path in /etc/environment.d/*.conf this still not enough

case ":$PATH:" in
    *:/usr/sbin:*) ;;
    *) PATH="$PATH:/usr/sbin:/sbin" ;;
  esac
export PATH
