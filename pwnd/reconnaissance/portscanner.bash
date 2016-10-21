###########################################################################
#                                                                         #
# Copyright (c) 2016, SafeBreach                                          #
# All rights reserved.                                                    #
#                                                                         #
# Redistribution and use in source and binary forms, with or without      #
# modification, are permitted provided that the following conditions are  #
# met:                                                                    #
#                                                                         #
#  1. Redistributions of source code must retain the above                #
# copyright notice, this list of conditions and the following             #
# disclaimer.                                                             #
#                                                                         #
#  2. Redistributions in binary form must reproduce the                   #
# above copyright notice, this list of conditions and the following       #
# disclaimer in the documentation and/or other materials provided with    #
# the distribution.                                                       #
#                                                                         #
#  3. Neither the name of the copyright holder                            #
# nor the names of its contributors may be used to endorse or promote     #
# products derived from this software without specific prior written      #
# permission.                                                             #
#                                                                         #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS                      #
# AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,         #
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF                #
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.    #
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR    #
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  #
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE       #
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS           #
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER    #
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR         #
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF  #
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                              #
#                                                                         #
###########################################################################

# portscanner, A simple yet "cross platform" implementation of TCP and UDP port scanner using bash sockets

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

# TODO: Add alternative implementations for `timeout'-like functionality

__portscanner_timeout() {
  # Based on: http://stackoverflow.com/questions/601543/command-line-command-to-auto-kill-a-command-after-a-certain-amount-of-time
  `perl -e 'alarm shift; open STDERR, "> /dev/null"; exec @ARGV' "$@"`
  # `` works better than $() in Linux when it comes to supressing 'Alarm' message _AND_ still having alarm terminating the process
}

# Based on http://www.catonmat.net/blog/tcp-port-scanner-in-bash/

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
