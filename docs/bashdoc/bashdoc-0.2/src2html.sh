#!/bin/bash

VERSION="0.1.8"
HEADER="<!-- Generated by src2html.sh version $VERSION, on $(date). -->"

#	@Globals FUNC_DIR, SCRIPTS
#	Parses arguments for this script
function args()
{
	while [ $# -gt 0 ] ; do
		case $1 in 
			--funcs)	FUNC_DIR=$2
					shift 2
					;;
			-*)		usage
					exit 1
					;;
			*)		SCRIPTS="$*"
					break
					;;
		esac
	done
}

#	Usage for this script
function usage()
{
	cat <<- EOF
		$(basename $0) --funcs func_directory script [script...]
		'--funcs func_directory'	Directory which contains the *.func files
		script	A script wich has a .func file
	
		Example: src2html.sh --funcs docs /home/user/p4/sgl/devel/sorcery/var/lib/sorcery/modules/lib{misc,codex} bash2doc.sh
	EOF
}

#	@param	func file, file with a list of functions
#	@param	html file for the script
#	@Stdout	sed expressions to do the search and replace
#	Create sed expressions to search and replace
function create_sed()
{
	for f in $( cat $1 ) ; do
  		echo "" "-e" '"/function[[:blank:]]*'$f'[[:blank:]]*()/{s@function[[:blank:]]*'$f'[[:blank:]]*()@function <a name='$f'><a href=\"'$2'#'$f'\">'$f'</a></a>()@;n}"'
		echo "" "-e" '"s@\([^[:alnum:]_><-]\)'$f'\([^[:alnum:]_><-]\)@\1<a href=\"'$2'#'$f'\">'$f'</a>\2@g"'
		echo "" "-e" '"s@^'$f'\([^[:alnum:]_><-]\)@<a href=\"'$2'#'$f'\">'$f'</a>\1@g"'
		echo "" "-e" '"s@\([^[:alnum:]_><-]\)'$f'\$@\1<a href=\"'$2'#'$f'\">'$f'</a>@g"'
		echo "" "-e" '"s@^'$f'\$@<a href=\"'$2'#'$f'\">'$f'</a>@g"'
	done
}

args "$@"

echo "Creating HTML version of scripts"
# Do the rewriting of html characters and put the result in the func dir
for SCRIPT in $SCRIPTS ; do

	echo "HTML'ising $SCRIPT..." 
	SRC_HTML=${SCRIPT#/}
	SRC_HTML=$FUNC_DIR/${SRC_HTML//\//\.}.src.html

	cat <<- EOF > $SRC_HTML
		<html>
		$HEADER
		<head>
			<title>Source of $SCRIPT</title>
		</head>
		<body>
			<h1>$SCRIPT</h1>
			<pre>
	EOF
	sed -e 's/</\&lt;/g' -e 's/>/\&gt;/g' $SCRIPT | cat -n	>> $SRC_HTML
	cat <<- EOF >> $SRC_HTML
		</pre>
		</body>
		</html>
	EOF
done

echo "Interlinking src pages"
# Do teh cross referencing
for SCRIPT in $SCRIPTS ; do
	echo "Crossreferencing $SCRIPT..."
	FUNC_FILE=${SCRIPT#/}
	FUNC_FILE=$FUNC_DIR/${FUNC_FILE//\//\.}.funcs
	LINK=${SCRIPT#*/}
	LINK=${LINK//\//\.}
	sed_expr=$( create_sed $FUNC_FILE ${LINK}.html )
#echo
#echo "FOR SCRIPT: $SCRIPT"
#echo "$sed_expr"
#read
	if ! [[ $sed_expr ]] ; then continue ; fi
	for HTML_FILE in $SCRIPTS ; do
		HTML_FILE=${HTML_FILE#/}
		HTML_FILE=$FUNC_DIR/${HTML_FILE//\//\.}.src.html
		eval sed $sed_expr $HTML_FILE > $HTML_FILE.2
		mv $HTML_FILE.2 $HTML_FILE
	done
done

echo "Linking bashdocs to src pages"
for SCRIPT in $SCRIPTS ; do
	#HTML_FILE is the bashdoc generated html file
	#SRC_FILE is the src2html generated html file
	HTML_FILE=${SCRIPT#/}
	HTML_FILE=$FUNC_DIR/${HTML_FILE//\//\.}.html
	SRC_FILE=${HTML_FILE%.html}
	SRC_FILE=${SRC_FILE#*/}
	SRC_FILE=${SRC_FILE}.src.html
	echo "Rewriting $HTML_FILE to link to $SRC_FILE..."

	# The <strong> is nasty. It would be nice if the formatting of the bashdoc was
	# more independent.
	sed -e "s@$SCRIPT@<a href=$SRC_FILE>$SCRIPT</a>@g" 	\
		-e "s@function[[:blank:]]*<strong>\([^(]*\)</strong>()@function <a href=\"${SRC_FILE}#\1\"><strong>\1</strong></a>()@"	\
		$HTML_FILE > $HTML_FILE.2
	echo "<!-- Modified by src2html.sh version $VERSION on $(date). -->" >> $HTML_FILE.2
	mv $HTML_FILE.2 $HTML_FILE
done
