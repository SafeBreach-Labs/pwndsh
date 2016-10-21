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

# over_socket, A simple yet "cross platform" implementation of generic TCP and UDP socket using bash sockets

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
