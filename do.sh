#!/usr/bin/env bash

# shellcheck disable=2164,2046
PROGDIR=$( cd $(dirname "${BASH_SOURCE[0]}") ; pwd )

function usage {
cat <<EOF >&2
usage ./$(basename "${BASH_SOURCE[0]}") <option>

options.
   -n | --strip-newlines      Removes empty lines
   -c | --strip-comments      Removes comments
   -u | --unsubscribe TOPIC   Does not include references to TOPIC in output
   -s | --subscribe TOPIC     Includes otherwise hidden references to TOPIC
EOF
exit 1
}


unsubscribe=''
subscribe=''

opts=()
files=()

while (( $# )) ; do
   case "$1" in
      -h | --help)
         usage
         ;;

      -n | --strip-newlines)
         shift
         opts+=( -v STRIP_NEWLINES=yes )
         ;;

      -c | --strip-comments)
         shift
         opts+=( -v STRIP_COMMENTS=yes )
         ;;

      -s | --subscribe)
         shift
         subscribe+="${subscribe:=,}${1}"
         shift
         ;;

      -u | --unsubscribe)
         shift
         unsubscribe+="${unsubscribe:=,}${1}"
         shift
         ;;

      -[^-]*)
         opt="${1/-/}"; newopts=()
         while [[ "$opt" =~ . ]] ; do
            char=${BASH_REMATCH[0]}
            newopts+=( -"${char}" )
            opt="${opt/${char}/}"
         done
         shift

         # If there's only 1 match that hasn't been handled by a valid option
         # above, it's an error. Add to invalid, and continue.
         if (( ${#newopts[@]} == 1 )) ; then
            invalid_opts+=( "${newopts[@]}" )
            continue
         fi

         set -- "${newopts[@]}"  "$@"
         ;;

      -*)
         invalid_opts+=( "$1" ) ; shift
         ;;

      *) files+=( "$1" ) ; shift
         ;;
   esac
done

# shellcheck disable=2128
if [[ $invalid_opts ]] ; then
   printf 'ERRO: Invalid options:'      >&2
   printf ' [%s]'  "${invalid_opts[@]}" >&2
   printf '\n'                          >&2
   usage
fi

opts+=(
   -v SUBSCRIBE="${subscribe}"
   -v UNSUBSCRIBE="${unsubscribe}"
   -f "${PROGDIR}"/preprawk
)
awk "${opts[@]}" "${files[@]}"
