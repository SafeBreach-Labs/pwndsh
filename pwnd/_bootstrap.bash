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

# _bootstrap.sh, interactive pwnd shell

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


###############
# Entry Point #
###############

cat << EOF
[Pwnd v${PWND_VERSION}, Itzik Kotler (@itzikkotler)]"
Type \`help' to display all the pwnd commands.
Type \`help name' to find out more about the pwnd command \`name'.

EOF

PS1="(\[\033[92m\]\[\033[1m\]pwnd\[\033[0m\]\[\033[39m\])${PS1-}"
