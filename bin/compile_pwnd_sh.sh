#!/usr/bin/env bash

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

##########
# Consts #
##########

DEFAULT_OUTPUT_FILENAME="pwnd.sh"


#############
# Functions #
#############

normalize_and_append() {
	grep -v "^#" < "$1" >> "$2"
	echo " " >> "$2"
}


###############
# Entry Point #
###############

output_filename="$DEFAULT_OUTPUT_FILENAME"

if [ ! -z "${1-}" ]; then
  output_filename="$1"
fi

# Start with a shebang line
echo "#!/usr/bin/env bash"> "$output_filename"

normalize_and_append "../pwnd/_pwnd.bash" "$output_filename"

for module in $(find ../pwnd -type f -name "[a-zA-Z0-9]*.bash"); do
  normalize_and_append "$module" "$output_filename"
done

normalize_and_append "../pwnd/_bootstrap.bash" "$output_filename"

ls -la "$output_filename"
