#!/bin/bash
#
# This is an expensive test to opt out of potentially
#> UNSUB THAT
if [[ $1 ]] ; then echo 'yup' ; fi
#> END UNSUB THAT

# Something to subscribe to.
#> SUB THAT
this should not be included
#> END SUB THAT
