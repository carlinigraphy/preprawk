#!/usr/bin/env bash

# shellcheck disable=2164,2046
PROGDIR=$( cd $(dirname "${BASH_SOURCE[0]}") ; pwd )
OUTDIR="${PROGDIR}/dist/"
mkdir -p "$OUTDIR"


function usage {
cat <<EOF
usage ./$(basename "${BASH_SOURCE[0]}") <option>

options.
   -n | --strip-newlines      Removes empty lines
   -c | --strip-comments      Removes comments
   -u | --unsubscribe TOPIC   Does not include references to TOPIC in output
   -s | --subscribe TOPIC     Includes otherwise hidden references to TOPIC
EOF

exit "$1"
}


unsubscribe=''
subscribe=''

opts=()
positional=()

while (( $# )) ; do
   case "$1" in
      -h | --help)
         usage 0
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

      *) positional+=( "$1" ) ; shift
         ;;
   esac
done


if (( ! ${#positional[@]} )) ; then
   printf 'requires file input\n'
   usage 2
elif (( ${#positional[@]} > 1 )) ; then
   printf 'too many positional arguments:'
   printf ' [%s]'  "${positional[@]}"
   printf '\n'
   usage 1
fi


input="${positional[0]}"
output="${OUTDIR}/$(basename "$input")"

opts+=(
   -v SUBSCRIBE="${subscribe}"
   -v UNSUBSCRIBE="${unsubscribe}"
   -f "${PROGDIR}"/preprawk
)

awk "${opts[@]}" "$input" > "$output"
