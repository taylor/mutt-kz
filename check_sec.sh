#!/bin/sh --

#
# grep for some things which may look like security problems.
#

TMPFILE="`mktemp check_sec.tmp.XXXXXX`" || exit 1

do_check_files ()
{
	pattern="$1" ; shift
	magic="$1" ; shift
	msg="$1" ; shift
	egrep -n "$pattern" "$@"        	| \
		grep -v '^[^	 ]*:[^ 	]*#' 	| \
		fgrep -v "$magic" > $TMPFILE

	test -s $TMPFILE && {
		echo "$msg" ;
		cat $TMPFILE;
		rm -f $TMPFILE;
		exit 1;
	}
}

do_check ()
{
	do_check_files "$1" "$2" "$3" *.c */*.c
}

do_check '\<fopen.*'\"'.*w' __FOPEN_CHECKED__ "Alert: Unchecked fopen calls."
do_check '\<(mutt_)?strcpy' __STRCPY_CHECKED__ "Alert: Unchecked strcpy calls."
do_check '\<strcat' __STRCAT_CHECKED__ "Alert: Unchecked strcat calls."
do_check '\<sprintf.*%s' __SPRINTF_CHECKED__ "Alert: Unchecked sprintf calls."

# don't do this check on others' code.
do_check_files '\<(malloc|realloc|free|strdup)[ 	]*\(' __MEM_CHECKED__ "Alert: Use of traditional memory management calls." \
	*.c imap/*.c

rm -f $TMPFILE
exit 0