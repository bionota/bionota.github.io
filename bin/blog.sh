#!/usr/bin/env bash
# blog.sh -- Blog Posting and RSS Feed Systems
# v0.8.3  dec/2021  mountaineerbr  #compatible with FreeBSD 13#
#   __ _  ___  __ _____  / /____ _(_)__  ___ ___ ____/ /  ____
#  /  ' \/ _ \/ // / _ \/ __/ _ `/ / _ \/ -_) -_) __/ _ \/ __/
# /_/_/_/\___/\_,_/_//_/\__/\_,_/_/_//_/\__/\__/_/ /_.__/_/   
#shell options
set -o pipefail
shopt -s nullglob extglob

#defaults
#local home page root
ROOT="$HOME/www/bionota.github.io"
#web home page root URL
ROOTWEB="https://bionota.github.io"

#local blog root
#!# it may be the same URL or a sub-URL from home page root
ROOTBLOG="$ROOT"
#web blog root URL
ROOTBLOGWEB="$ROOTWEB"

#local blog post directory
#!#it may be the same URL or a sub-URL from blog root
BLOG_POSTDIR="$ROOT"
#web blog post URL
BLOG_POSTWEB="$ROOTWEB"

#templates
#new post
TEMPLATE_NEWPOST="$ROOTBLOG/bin/template_post_new.html"
#post list
TEMPLATE_INDEX="$ROOTBLOG/template_post_index.html"
#single post index.html
TEMPLATE_STANDALONE="$ROOTBLOG/bin/template_post_standalone.html"
#catenation
TEMPLATE_CAT="$ROOTBLOG/template_post_cat.html"
#RSS main feed
TEMPLATE_FEED="$ROOTBLOG/template_rss.xml"
#RSS alternative (full content) feed
TEMPLATE_FEED_ALT="$ROOTBLOG/template_rss_alt.xml"

#file targets
#blog index
TARGET_INDEX="$ROOTBLOG/index.html"
#post catenation
TARGET_CAT="$ROOTBLOG/cat.html"
#RSS main feed
TARGET_FEED="$ROOTBLOG/rss.xml"
#RSS alternative feed
TARGET_FEED_ALT="$ROOTBLOG/rss_alt.xml"
#html post list items (optional)
#POST_LIST_HTML_PATH="$ROOTBLOG/titles.html"
#plain text post title list (optional)
POST_LIST_PLAIN_PATH="$ROOTBLOG/titles.txt"
POST_LIST_MAXITEMS=0

#post author
DEF_AUTH=mountaineerbr
#rss author (e-mail address)
RSS_AUTHOR='jamilbio20@gmail.com (JSN)'
#category
DEF_CATEGORY=science
#language
DEF_LANG=pt  #en

#buttons (labels may be translated)
BUTTON_STANDALONE='[avulso]'  #[stand-alone]
BUTTON_PREV=Anterior  #Previous
BUTTON_NEXT=Próximo   #Next

#open graph default image
IMGOGDEF="$ROOTWEB/gfx/bg11bg.png"
OG_IMG_ALT_DEF="Cogumelos, folhas e gravetos."

#raw post file name
RAWPOST_FNAME=i.html
RAWPOST_FNAME_MD=i.md
#raw post extensions
EXT_HTML="${RAWPOST_FNAME##*.}"
EXT_MD="${RAWPOST_FNAME_MD##*.}"

#enable tidy if available
OPTI=1

#markdown command
#MARKDOWN_CMD=(markdown)
#https://www.pell.portland.or.us/~orc/Code/discount/
MARKDOWN_CMD=(md2html --github)
#https://github.com/mity/md4c

#curl command
CURL_CMD=(curl)
#CURL_CMD=(wget -O-)

#uuidgen command
#comment out to set post URL as GUID instead
UUIDGEN_CMD=(uuidgen -s -n @dns -N)
UUID_NAME=blog
UUID_ALT_NAME=blogalt
#post number is appended to name ($UUID_NAME and $UUID_ALT_NAME)
#ex: uuidgen -s -n @dns -N blog1
#see `uuidgen' from `linux-util'

#timestamp formats
TIME_RFC5322_FMT='%a, %d %b %Y %H:%M:%S %z'
TIME_ISO8601_FMT='%Y-%m-%d'  #'%Y-%m-%dT%H:%M:%S%z'
TIME_CUSTOM_FMT='%d/%b/%Y'

#printf string
#(clear everything in the line)
CLR='\033[2K'

#script name
SN="${0##*/}"

#help page
HELP="NAME
	$SN - Blog Posting and RSS Feed Systems


SYNOPSIS
	$SN [-a] [NUM|POST TITLE]
	$SN [-cfit]
	$SN [-hV]

	
	Create post, generate simple blog pages and RSS feeds.

	The user should be familiar with HTML tags to customise the tem-
	plate and CSS files. The user should feel free to customise HTML
	and CSS throughout this script source code, too.

	Author may write post hypertext in markup or markdown by setting
	the raw post filename as $RAWPOST_FNAME or $RAWPOST_FNAME_MD.

	Required packages are Bash, optionally tidy, markdown and uuidgen.


DESCRIPTION
	The user should set all variables in this script head source code
	and customise all template and style files.

	If the script is run and no options are set, generate HTML and RSS
	files from templates. Raw post files are only recompiled if modi-
	fication has been detected since previous run. This greatly improves
	speed. To force recompiling HTML and RSS buffers, set option -f.
	
	Option -a creates a new directory and post from template at blog
	root, eg. 1/$RAWPOST_FNAME. TITLE may be set from command line
	as positional argument. Instead, if NUM is the first positional
	argument, edit that post.

	To write in markdown, rename post file name to $RAWPOST_FNAME_MD so hypertext
	is converted to markup. Set your preferred markdown command in the
	script head source code \$MARKDOWN_CMD array.

	Post file uppercase tags, such as \`DATE:' are important and should
	be filled in with plain text (HTML entities will be auto escaped).
	There are other special uppercase variables in templates, such as
	\`<!-- HYPERTEXT -->' which are recognised by the compiling engine.

	\`Tidy' checks and corrects many errors, formats markup nicely and
	is set to run by defaults, if available. In order to not tidy up
	generated pages, set option -i.

	Set option -c to check (validate) author hypertext from post $RAWPOST_FNAME
	file with tidy. No files are modified.

	Set option -t to try resetting modification time of raw post file
	$RAWPOST_FNAME with attributes from the previously generated index.html.
	This will keep time attributes of those files constant even when
	modifying raw posts and recompiling them.

	Please, write HTML5 conformant hypertext, with lowercase tags and
	double quotation of attributes.

	Inspired by the Poor Man Webmaster Tools from the Silly Software
	Company.


RSS FEED
	Two RSS feeds are generated. The main one with short descriptions
	of post entries and one media enclosure, and an alternative feed
	with full post content.

	Make sure template XML files for RSS feeds are set at $TEMPLATE_FEED and
	$TEMPLATE_FEED_ALT.

	If \`uuidgen' command is enabled, UUIDs are post-number-specific
	and do not vary over time. If not enabled, use permalink as UUID.
	Package \`uuidgen' is available from \`util-linux'.


SPECIAL VARIABLES
	Special variables are uppercase HTML comments in template files
	and are substituted by this script on generated pages.


	Current substituting or recognised variables

	$TEMPLATE_NEWPOST
	DATE: 			Set post date.
	TITLE/H1: 		Set page title and adds <h1>.
	DESCRIPTION: 		Set post and main rss descriptions.
	KEYWORDS: 		Set page keywords and rss categories.
	LANGUAGE: 		Set article language, \`en' if unset.
	<!-- HYPERTEXT --> 	Anchor start of author hypertext,
				either markup or markdown.

	$TEMPLATE_STANDALONE
	<!-- ARTICLE --> 	Anchor article from raw post.
	<!-- NAV NEXT --> 	Mark added with next button.
	<!-- NAV PREV --> 	Mark added with previous button.
	<!-- NAV PREVNEXT --> 	Anchor post navigation buttons.
	<!-- OPENGRAPH --> 	Anchor Open Graph meta tags.

	$TEMPLATE_CAT
	<!-- CAT ARTICLES --> 	Anchor catenation of posts (from buffer).
	<!-- NAV STANDALONE -->	Anchor post stand-alone link.

	$TEMPLATE_INDEX
	<!-- HTML POSTLIST --> 	Anchor for HTML list with post dates and titles.

	$TEMPLATE_FEED
	$TEMPLATE_FEED_ALT
	<!-- CURRENT TIME ISO8601 -->
				Substitute with current ISO-8601 time format.
	<!-- CURRENT TIME RFC5322 -->
				Substitute with current RFC-5322 time format.
	<!-- RSS ITEM --> 	Anchor post items in RSS feed.

	Multiple templates
	<!-- METATAGS --> 	Anchor head meta tags.


DIRECTORY AND FILE STRUCTURE
	The blog structure was chosen for its simplicity and straightfor-
	wardness in URL navigation from the visitor perspective (posts are
	not burried under some unpredictable directory structures).

	Blog post directories start with an index number [0-9]+ inside the
	blog root directory. The post directory must hold an $RAWPOST_FNAME file,
	which is a clone from template $TEMPLATE_NEWPOST.

	Templates are located at the blog root and under bin directory
	so they can be opened in a webbrowser with valid link, css and
	other relative references working.

	$RAWPOST_FNAME files are processed/compiled to generate index.html and
	hidden buffer files at the same directory as $RAWPOST_FNAME. Buffer files
	are kept with the necessary image SRC and anchor HREF changes for
	catenation into $TARGET_CAT.

	Post files have timestamps checked and are only recompiled when
	changed since previous run. If you change templates only, a full
	recompilation (with -f) may be required.


ENVIRONMENT
	VISUAL
	EDITOR 	New post creation or edition (option -a) read these two
		variables in order. If none set, defaults to \`vim'.


BLOG REFERENCES
	Poor Man Webmaster Tools
	<http://users.telenet.be/mydotcom/howto/www/tools.htm>

	Roman Zolotarev's ss5
	<https://www.romanzolotarev.com/ssg.html>

	Slackjeff's hacktuite
	<https://github.com/slackjeff/hacktuite>

	Miscellaneous
	<https://unix.stackexchange.com/questions/502230/how-to-apply-sed-if-it-contains-one-string-but-not-another/502233>


RSS REFERENCES
	RSS and Atom
	<https://info.sice.indiana.edu/~dingying/Teaching/S604/RSS.ppt>
	<http://www.intertwingly.net/wiki/pie/Rss20AndAtom10Compared#major>
	<https://www.scriptol.com/rss/comparison-atom-rss-tags.php>
	<http://weblog.philringnalda.com/>

	SPECS
	RSS 1.0
	<http://web.resource.org/rss/1.0/spec>
	RSS 2.0
	<https://cyber.harvard.edu/rss/rss.html
	Atom
	<https://www.ietf.org/rfc/rfc4287.txt>
	<https://tools.ietf.org/rfc/rfc4287.txt>

	Atom xml:base attribute
	<https://tools.ietf.org/html/rfc4287>
	<https://www.odata.org/documentation/odata-version-2-0/atom-format/>
	<https://pythonhosted.org/feedparser/common-atom-elements.html>

	GUIDs
	<https://tools.ietf.org/html/rfc4122.html#section-4.3>
	<https://validator.w3.org/feed/docs/error/InvalidPermalink.html>
	<http://www.詹姆斯.com/blog/2006/08/rss-dup-detection>

	Full content or excerpt?
	<https://webmasters.stackexchange.com/questions/100290/duplicating-a-rss-feed-to-show-the-whole-post-in-addition-to-the-feed-showing-sn/100296#100296>

	Tidy HTML escaping
	https://stackoverflow.com/questions/5272819/xmlstarlet-parser-error-entity-not-defined

	More
	<https://www.w3schools.com/xml/xml_rss.asp>
	<https://www.w3schools.com/xml/xpath_syntax.asp>
	<https://validator.w3.org/feed/docs/atom.html>
	<https://ddialliance.org/Specification/DDI-Codebook/2.5/XMLSchema/field_level_documentation_files/namespaces/http_purl_org_dc_elements_1_1/namespace-overview.html>
	<https://www.dublincore.org/specifications/dublin-core/dcmi-terms/>
	<https://stackoverflow.com/questions/24984162/xmlstarlet-utf-8-nordic-characters>
	<https://stackoverflow.com/questions/15400259/can-xmlstarlet-preserve-cdata-during-copy>
	<https://webmasters.stackexchange.com/questions/102139/can-a-website-have-multiple-rss-feeds-how-would-the-link-and-channel-elemen>


WARRANTY
	Licensed under the GNU Public License v3 or better and is distrib-
	uted without support or bug corrections.

	This script requires Bash and optionally tidy, markdown and uuidgen
	to work properly.

	If you found this script useful or interesting, please consider
	sending me a nickle!  =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


BUGS


OPTIONS
	-a [NUM|TITLE]
		Create new post with TITLE or edit post NUM.
	-c 	Check/validate author HTML with tidy.
	-f 	Force recompilation of HTML and RSS files and buffers.
	-h 	Help.
	-i 	Do not tidy up generated pages.
	-t 	Reset post file times with buffer attributes (not visible).
	-V 	Script version."


#functions
#create a new post from template
creatf()
{
	local title p_num description keywords p_target_dir date_iso8601 template_change visual_exit REPLY

	title="$*" p_num="$1"

	if [[ "$p_num" = +([0-9]) && "$p_num" -le "$LASTPOST" ]]
	then
		#edit post NUM
		p_target_dir="$ROOTBLOG/$p_num" ;[[ -d "$p_target_dir" ]] || return
		CREATF_TARGET_PATH=( "$p_target_dir"/@($RAWPOST_FNAME|$RAWPOST_FNAME_MD) )

		"${VISUAL:-${EDITOR:-vim}}" "${CREATF_TARGET_PATH[@]: -1}" ;visual_exit=$?

		read -n1 -p 'Compile or Quit? (c/Q) ' ;echo
		echo "Raw post path -- ${CREATF_TARGET_PATH[@]: -1}" >&2
		case "$REPLY" in
			#compile
			[cC]*) true;;
			#quit
			*) exit $visual_exit;;
		esac
		unset CREATF_TARGET_PATH 
	else
		#new post
		((++LASTPOST , ++N))
		p_target_dir="$ROOTBLOG/$N"
		[[ "$title" ]] || read -erp 'TITLE/H1: ' title
		read -erp 'DESCRIPTION: ' description
		read -erp 'KEYWORDS (comma separated): ' keywords
		read -n1 -p 'Write in markdown? (y/N) ' ;echo
		case "$REPLY" in
			#markdown
			[yY]*) CREATF_TARGET_PATH=( "$p_target_dir/$RAWPOST_FNAME_MD" );;
			#markup
			*)     CREATF_TARGET_PATH=( "$p_target_dir/$RAWPOST_FNAME" );;
		esac
		date_iso8601=$(datefun -I)
		keywords="${keywords:-$DEF_CATEGORY}"
		template_change=$(<"$TEMPLATE_NEWPOST")
		template_change="${template_change/DATE:*([[:space:]])/DATE: $date_iso8601$'\n'}"
		template_change="${template_change/TITLE\/H1:*([[:space:]])/TITLE\/H1: $title$'\n'}"
		template_change="${template_change/DESCRIPTION:*([[:space:]])/DESCRIPTION: $description$'\n'}"
		template_change="${template_change/KEYWORDS:*([[:space:]])/KEYWORDS: $keywords$'\n'}"
	
		#create new post directory and file
		[[ -d "$p_target_dir" ]] || mkdir -p -- "$p_target_dir" || return
		echo "$template_change"$'\n\n' >"${CREATF_TARGET_PATH[@]: -1}" || return
	
		#first post edit
		"${VISUAL:-${EDITOR:-vim}}" "${CREATF_TARGET_PATH[@]: -1}" ;visual_exit=$?
		
		read -n1 -p 'Compile, Remove post or Quit? (c/r/Q) ' ;echo
		case "$REPLY" in
			#compile
			[cC]*) true;;
			#remove new post
			[rR]*) rm -v -- "${CREATF_TARGET_PATH[@]: -1}" && rmdir -v -- "$p_target_dir" ;exit $(($?+visual_exit));;
			#quit
			*) exit $visual_exit;;
		esac
		echo "Raw post path -- ${CREATF_TARGET_PATH[@]: -1}" >&2
	fi
	return $visual_exit
}

# Choose between GNU or BSD date
# datefun.sh [-u|-R|-I[fmt]] [YYY-MM-DD|@UNIX] [+OUTPUT_FORMAT]
# datefun.sh [-u|-R|-I[fmt]]
#
# By defaults, input should be UNIX time (append @) or ISO8601 format
# because of BSD date (or set $INPUT_FMT).
# Relative times are not supported, such as `-1d' and `last week'.
# Option -I `fmt' may be `date', `hours', `minutes' or `seconds'.
# Setting environment TZ=UTC0 is equivalent to -u. 
datefun()
{
	local options unix_input input_fmt
	input_fmt="${INPUT_FMT:-$TIME_ISO8601_FMT}"

	#check for options
	[[ "$1" = -[RI]* ]] && options="$1" && shift
	#[[ "$1" = @* ]] && unix_input=@ && set -- "${1#@}" "${@:2}"

	#run date command
	if ((BSDDATE))
	then 	[[ "${1:-+}" != @(+|@|-f)* ]] && set -- -f"${input_fmt}" "$@"
		[[ "$1" = @* ]] && set -- "-r${1#@}" "${@:2}"
		"${DATE_CMD[@]}" ${options} -j "$@"
	else 	[[ "${1:-+}" != @(+|-d)* ]] && set -- -d"${unix_input}${1}" "${@:2}"
		"${DATE_CMD[@]}" ${options} "$@"
	fi
}

#entity escaping
escf()
{
	local input="$1"
	#if tidy is set, do not escape input
	((OPTI)) && { echo "$input" ;return ;}

	input="${input//&/&amp;}" 	#ampersand
	input="${input//\'/&apos;}"	#less-than
	input="${input//\"/&quot;}"	#greater-than
	input="${input//>/&gt;}" 	#apostrophe
	input="${input//</&lt;}" 	#quotation
	input="${input//©/&\#xA9;}" 	#copyright
	input="${input//℗/&\#x2117;}" 	#sound recording copyright
	input="${input//™/&\#x2122;}" 	#TM trademark
	echo "$input"
}
#{ perl -e "use CGI qw(escapeHTML); print escapeHTML(\"$input\n\");" ;}

#simple html filter
#hf() { sed 's/<[^>]*>//g' "$@" ;}

#remove implicit refs .. and .
#ex: a/b/../img.gif -> a/img.gif
#ex: ./a/b/../../img.gif -> img.gif
rmimpf()
{
	local input="$1"
	while [[ "$input" =~ ([^/]+/[.][.]/) || "$input" =~ ^([.]/) || "$input" =~ (/[.])/ ]]
	do 	input="${input/"${BASH_REMATCH[1]}"}"
	done
	echo "$input"
}

#tidy validate, check html
tidycheckf()
{
	local f ret post_raw
	#-c check/validate raw post files with tidy only?
	for f
	do 	[[ "${f,,}" = *.html ]] || { printf 'warning: skipping markdown post -- %s\n' "$f" >&2 ;continue ;}
		post_raw=$(<"$f")
		tidy -quiet \
			--char-encoding utf8 \
			--input-encoding utf8 \
			--output-encoding utf8 \
			--show-body-only yes \
			-errors \
			<<<"${post_raw#*'<!-- HYPERTEXT -->'}"
		ret+=($?) ;((ret[-1] > 0)) && echo -e "$f\n" >&2
	done
	#sum return codes
	return $((${ret[@]/%/+} 0))
}
#https://stackoverflow.com/questions/1837624/validating-html-from-the-command-line

#tidy up
tidyupf()
{
	local ret
	tidy --quiet yes \
		--char-encoding utf8 \
		--input-encoding utf8 \
		--output-encoding utf8 \
		--show-warnings no \
		--show-info no \
		--break-before-br yes \
		--fix-style-tags yes \
		--fix-uri yes \
		--vertical-space yes \
		--hide-comments no \
		--tidy-mark yes \
		--preserve-entities yes \
		--show-body-only auto \
		"$@"
	ret=$?
	((ret>1)) && exit $ret
	return $ret
}


#start
#parse options
while getopts acfhitvV- c
do
	case $c in
		#new post
		a) OPTA=1;;
		#check post
		c) OPTC=1;;
		#help
		h|-) echo "$HELP" ;exit 0;;
		#force recompile post index.html files
		f) OPTF=1;;
		#unset tidy
		i) OPTI=0;;
		#keep old mod time
		t) OPTT=1;;
		###debug, verbose mode
		##v) OPTV=1;;
		#script version
		v|V) grep -m1 '# v[0-9]*' "$0" ;exit ;;
		\?) exit 1;;
	esac
done
shift $((OPTIND - 1))
unset c

#check for pkgs
command -v tidy &>/dev/null || {
	echo "warning: optional package -- tidy" >&2
	OPTI=0
}
command -v "${MARKDOWN_CMD[0]}" &>/dev/null || {
	echo "warning: optional package --  ${MARKDOWN_CMD[0]:-markdown}" >&2
	MARKDOWN_CMD=(false)
}
command -v "${CURL_CMD[0]}" &>/dev/null || {
	echo "warning: optional package --  ${CURL_CMD[0]:-curl}" >&2
	CURL_CMD=(false)
}
"${UUIDGEN_CMD[@]:-false}" name1 &>/dev/null &>/dev/null || {
	echo "warning: optional package -- ${UUIDGEN_CMD[0]:-uuid generator}" >&2
	UUIDGEN_CMD=(false)
}
# Choose between GNU or BSD stat, print last modification date
if stat --help
then 	STAT_CMD=(stat -c %Y)  #GNU
else 	STAT_CMD=(stat -f %m)  #BSD
fi 	>/dev/null 2>&1
#test whether BSD or GNU date is available
if ((! ${#DATE_CMD[@]})) && DATE_CMD=(date) && ! date --version
then 	gdate --version && DATE_CMD=(gdate) || BSDDATE=1
fi 	>/dev/null 2>&1

#set trap
trap '{ exit; }' INT TERM HUP


#PART ZERO - PREPARATION
#check for template files
for t in "$TEMPLATE_CAT" "$TEMPLATE_INDEX" "$TEMPLATE_STANDALONE" \
	"$TEMPLATE_NEWPOST" "$TEMPLATE_FEED" "$TEMPLATE_FEED_ALT"
do 	[[ -e "$t" ]] || { echo "$SN: err: template file missing -- $t" >&2 ;exit 1 ;}
done
unset t

#changing to $ROOTBLOG is required!
echo "change to website root -- $ROOTBLOG" >&2
cd "$ROOTBLOG" || exit

#generate file list, must sort by number (version number)
echo "generate array with post paths" >&2
IFS="${IFS# }"
POSTFILES=( $(printf '%s\n' +([0-9])/@("$RAWPOST_FNAME"|"$RAWPOST_FNAME_MD") | sort -Vr) )
IFS=$' \t\n'

#set first and last post numbers
#(loop processing is from last to first)
#extract the top directory
regex="^/?([^/]+)/?"
[[ "${POSTFILES[@]: -1}" =~ $regex ]] ;FIRSTPOST="${BASH_REMATCH[1]}"
[[ "${POSTFILES[0]}" =~     $regex ]]  ;LASTPOST="${BASH_REMATCH[1]}"
N=$((LASTPOST)) || LASTPOST=1 N=1
#http://molk.ch/tips/gnu/bash/rematch.html

#-a create new post
if ((OPTA))
then creatf "$@" || exit ;POSTFILES=("${CREATF_TARGET_PATH[@]: -1}" "${POSTFILES[@]}")
#-c validate, check html with tidy
elif ((OPTC))
then tidycheckf "${POSTFILES[@]}" ;exit
#post array must not be empty
elif ((${#POSTFILES[@]}==0))
then exit 1
fi

#get current time timestamps
TIME_CURRENT_RFC5322=$(datefun -R)
TIME_CURRENT_ISO8601=$(datefun -I)


echo "compile post HTML and RSS files" >&2
for file in "${POSTFILES[@]}"
do
	#if `i.html' has an `i.md' counterpart, skip `i.html'
	[[ "$file" = *."$EXT_HTML" && -e "${file%.*}$EXT_MD" ]] && { ((--N)) ;continue ;}
	#feedback
	printf "\r$CLR>>>%3d/%3d  %s " "$N" "$LASTPOST" "$file" >&2

	#PART ONE - INDIVIDUAL POSTS
	#extract the basename
	[[ "$file" =~ .*/(.+\..*)$ ]]
	#post index.html path
	post_target_path="${file%${BASH_REMATCH[1]}}index.html"
	#cat.htm and rss buffers paths
	post_cat_buffer_path="${file%${BASH_REMATCH[1]}}.cat.html"
	post_rss_buffer_path="${file%${BASH_REMATCH[1]}}.rss.xml"
	post_rss_alt_buffer_path="${file%${BASH_REMATCH[1]}}.rss_alt.xml"
	#post and rss canonical url
	post_canonical="$ROOTBLOGWEB/$N/"
	#file path array for cat.html and rss
	CATFILES+=("$post_cat_buffer_path")
	RSSFILES+=("$post_rss_buffer_path")
	RSSALTFILES+=("$post_rss_alt_buffer_path")

	#set some important post vars
	#read raw post (i.html)
	post_raw=$(<"$file")
	[[ "$post_raw" =~ DATE:[[:space:]]*([0-9]{4}[/.-][0-9]{1,2}[/.-][0-9]{1,2})[[:space:]]*TITLE/H1: ]]
	date_iso8601="${BASH_REMATCH[1]//\//-}" date_iso8601="${date_iso8601//[[:space:]]}"
	date_customfmt=$(datefun "$date_iso8601" +"$TIME_CUSTOM_FMT")
	date_customfmt="${date_customfmt:-$date_iso8601}"

	[[ "$post_raw" =~ TITLE/H1:(.*)DESCRIPTION: ]]
	title=$(escf "${BASH_REMATCH[1]}")


	#main compiling engine
	#(re-)generate post index.html (stand-alone) and
	#catenation and rss feed buffers
	if
		#get post i.html and index.html modification timestamps
		i_timestamp=$("${STAT_CMD[@]}" "$file")
		if [[ -e "$post_target_path" ]]
		then	index_timestamp=$("${STAT_CMD[@]}" "$post_target_path")
			index_timestamp_iso8601=$(datefun -Iseconds @"$index_timestamp")
		fi

		#if option -f OR no buffer for catenation
		#OR no post index.html (stand-alone) OR i.html and index.html timestamps differ
		[[ "$OPTF" || ! -s "$post_cat_buffer_path" || ! -s "$post_rss_alt_buffer_path"
		|| ! -s "$post_rss_alt_buffer_path" || ! -s "$post_target_path"
		|| "$i_timestamp" -ne "$index_timestamp"
		|| ( "$N" -lt "$LASTPOST" && "$(<"$post_target_path")" != *'<!-- NAV NEXT -->'* ) ]]
	then
		#set more post vars
		#timestamps
		date_rfc5322=$(datefun -R "$date_iso8601")

		[[ "$post_raw" =~ DESCRIPTION:(.*)KEYWORDS: ]]
		description=$(escf "${BASH_REMATCH[1]}")
		[[ "$post_raw" =~ KEYWORDS:(.*)LANGUAGE: ]]
		keywords=$(escf "${BASH_REMATCH[1]:-$DEF_CATEGORY}")
		[[ "$post_raw" =~ LANGUAGE:(.*)\<\!--* ]]
		lang="${BASH_REMATCH[1]%%\<\!--*}" lang="${lang//[[:space:]]}"
		[[ "$post_raw" =~ '<!-- HYPERTEXT -->'(.*) ]]
		html_text="${BASH_REMATCH[1]}"
		unset post_raw

		#is that markdown file?
		if [[ "$file" = *."$EXT_MD" ]]
		then 	html_text=$("${MARKDOWN_CMD[@]}" <<<"$html_text") || {
				printf '\nerr: skipping markdown post -- %s\n' "$file" >&2
				((--N))
				continue
			}
		fi

		#remove leading and trailing spaces
		for var in title description keywords html_text
		do 	lead="${!var%%[^[:space:]]*}" trail="${!var##*[^[:space:]]}"
			eval "$var=\"\${!var#\$lead}\"" "$var=\"\${!var%\$trail}\""
		done
		#bash: declare "$var=${!var#$lead}" ;declare "$var=${!var%$trail}"

		#set metatags
		metatags="
<title>#$N $title -  $date_customfmt</title>
<meta name=\"description\" content=\"$description\">
<meta name=\"keywords\" content=\"$keywords\">
<link rel=\"canonical\" href=\"$post_canonical\">
<link rel=\"stylesheet\" href=\"../css/style.css\" type=\"text/css\">"

		article="<article class=\"h-entry\"${lang:+ lang=\"${lang:-$DEF_LANG}\"}>
<header>
<h1 class=\"p-name\" id=\"$N\">#$N $title</h1>
<time class=\"dt-published\" datetime=\"$date_iso8601\">$date_customfmt</time>
<!-- NAV STANDALONE -->
<br>
</header>
$html_text
</article>"

		#set navigation previous and next buttons
		((N==LASTPOST)) \
			|| nav_next="<!-- NAV NEXT --><a class=\"w3-bar-item w3-right\" href=\"../$((N+1))/\">$BUTTON_NEXT</a>"
		((N==FIRSTPOST)) \
			|| nav_prev="<!-- NAV PREV --><a class=\"w3-bar-item w3-right\" href=\"../$((N-1))/\">$BUTTON_PREV</a>"

		#set open graph (requires absolute urls)
		regex="<img .*src=['\"]([^'\"]+)['\"]"
		if [[ "$html_text" =~ $regex && "${BASH_REMATCH[0]%%>*}" =~ $regex ]]  #`first match'
		then 	og_img_src="${BASH_REMATCH[1]}"
			og_img_src=$(rmimpf "$ROOTBLOGWEB/$N/$og_img_src")

			regex="<img .*alt=['\"]([^'\"]+)['\"]"
			[[ "$html_text" =~ $regex ]]
			[[ "${BASH_REMATCH[0]%%>*}" =~ $regex ]]  #`first match'
			og_img_alt="${BASH_REMATCH[1]}"
		fi

		#set opengraph tags
		ogtags="<meta property=\"og:url\" content=\"$ROOTBLOGWEB/$N/\">
<meta property=\"og:type\" content=\"blog\">
<meta property=\"og:title\" content=\"$title\">
<meta property=\"og:image\" content=\"${og_img_src:-$IMGOGDEF}\">
<meta property=\"og:description\" content=\"$description\">
<meta name=\"twitter:card\" content=\"summary\">
<meta name=\"twitter:image:alt\" content=\"${og_img_alt:-$OG_IMG_ALT_DEF}\">"


		#check required vars are set
		for var in title description keywords html_text metatags date_rfc5322 date_iso8601
		do 	[[ "${!var}" ]] || echo -e "\awarning: unset var -- $var" >&2
		done
		#zsh parameter indirection: "${(P)var}"
		#https://unix.stackexchange.com/questions/68035/foo-and-zsh

		#substitute post text
		temp_post_target=$(<"$TEMPLATE_STANDALONE")
		temp_post_target="${temp_post_target/"<!-- METATAGS -->"/$metatags}"
		temp_post_target="${temp_post_target/"<!-- OPENGRAPH -->"/$ogtags}"
		temp_post_target="${temp_post_target/"<!-- ARTICLE -->"/$article}"
		temp_post_target="${temp_post_target/"<!-- NAV PREVNEXT -->"/$nav_next$'\n'$nav_prev}"

		#tidy up post index.html?
		if ((OPTI))
		then 	tidyupf <<<"$temp_post_target"
		else 	echo "$temp_post_target"
		fi 	>"$post_target_path"


		#PART THREE - CATENATION
		#add navigation to individual posts
		nav_standalone="<nav><a href=\"$N/\">$BUTTON_STANDALONE</a></nav>"

		#fix relative references
		#catenation and rss file buffer
		cat_rss_buffer="${article/"<!-- NAV STANDALONE -->"/$nav_standalone}"
		test_cat_rss_buffer="$cat_rss_buffer"
		while [[ "$test_cat_rss_buffer" =~ (src|href)=[\'\"]([^\'\"]+)[\'\"] ]]
		do 	if 	#check that reference path exists
				src_change="$N/${BASH_REMATCH[2]}"
				[[ -e "$src_change" || -e "${src_change%[#?&]*}" ]]
			then 	#remove implicit refs .. and .
				src_change=$(rmimpf "$src_change")

				#change src relative paths
				cat_rss_buffer="${cat_rss_buffer//"${BASH_REMATCH[2]}"/$src_change}"
			fi
			test_cat_rss_buffer="${test_cat_rss_buffer//"${BASH_REMATCH[0]}"}"
		done
		unset test_cat_rss_buffer

		#tidy up post cat buffer (and for rss)?
		if ((OPTI))
		then 	cat_rss_buffer_tidy=$(tidyupf --wrap 0 <<<"$cat_rss_buffer")
			echo "$cat_rss_buffer_tidy"
		else 	echo "$cat_rss_buffer"
		fi 	>"$post_cat_buffer_path"

		#set an older timestamp for post i.html from post index.html
		((OPTT && index_timestamp < i_timestamp)) && touch -d"${index_timestamp_iso8601:0:19}" "$file"
		#clone file attributes (such as mod date) from post i.html to post index.html
		touch -r "$file" "$post_target_path"


		#PART FOUR - RSS feeds
		#RSS unique identifier
		#can be a permalink or a 16 byte string
		rss_guid=$("${UUIDGEN_CMD[@]}" "${UUID_NAME}${N}")
		rss_alt_guid=$("${UUIDGEN_CMD[@]}" "${UUID_ALT_NAME}${N}")

		#RSS category
		rss_category="${keywords//, /,}" rss_category="${rss_category// ,/,}" rss_category="${rss_category//,/\/}"

		#RSS media enclosure
		regex="<img .*src=['\"]([^'\"]+)['\"]"
		if [[ "$html_text" =~ $regex ]]
			[[ "${BASH_REMATCH[0]%%>*}" =~ $regex ]]
		then
			enclosure_src="${BASH_REMATCH[1]}"
			enclosure_ext=${enclosure_src##*.}
			if 	#set probable enclosure local subpath
				enclosure_subpath="$N/$enclosure_src"
				[[ -e "$enclosure_subpath" ]]
			then 
				#set enclosure local url and file size
				enclosure_url=$(rmimpf "$ROOTBLOGWEB/$enclosure_subpath")
				enclosure_size=$(wc -c <"$enclosure_subpath")
			elif [[ "$enclosure_src" != @(/|./|../)* ]]
			then 	#set enclosure remote url and file size
				enclosure_url="$enclosure_src"
				enclosure_size=$("${CURL_CMD[@]}" "$enclosure_src" | wc -c)
			fi
			#set enclosure tag
			[[ "$enclosure_url" ]] && enclosure="<enclosure url=\"$enclosure_url\" length=\"$enclosure_size\" type=\"image/$enclosure_ext\"/>"
		fi


		#MAIN FEED (rss.xml)
		[[ "$rss_guid" ]] && ispermalink=false || ispermalink=true
		rss_item="    <item>
      <title xml:lang=\"${lang:-$DEF_LANG}\">#$N $title</title>
      <pubDate>${date_rfc5322:-${date_iso8601:-unavailable}}</pubDate>
      <description>${description:-unavailable}</description>
      <link>${post_canonical:-$ROOTBLOGWEB}</link>
      <dc:language>${lang:-$DEF_LANG}</dc:language>
      <category>${rss_category:-${DEF_CATEGORY:-unavailable}}</category>
      <author>$RSS_AUTHOR</author>
      <guid isPermaLink=\"$ispermalink\">${rss_guid:-${post_canonical:-unavailable}}</guid>
      $enclosure
    </item>"

		#ALTERNATIVE FEED (rss_alt.xml)
		rss_alt_item="    <item>
      <title xml:lang=\"${lang:-$DEF_LANG}\">#$N $title</title>
      <pubDate>${date_rfc5322:-${date_iso8601:-unavailable}}</pubDate>
      <link>${post_canonical:-$ROOTBLOGWEB}</link>
      <dc:language>${lang:-$DEF_LANG}</dc:language>
      <category>${rss_category:-${DEF_CATEGORY:-unavailable}}</category>
      <author>${RSS_AUTHOR:-$DEF_AUTH}</author>
      <guid isPermaLink=\"$ispermalink\">${rss_guid:-${post_canonical:-unavailable}}</guid>
      <description><![CDATA[ ${cat_rss_buffer_tidy:-${cat_rss_buffer:-unavailable}} ]]></description>
    </item>"
		echo "$rss_item"     >"$post_rss_buffer_path"
		echo "$rss_alt_item" >"$post_rss_alt_buffer_path"

		echo >&2
	fi


	#PART TWO - POST LISTS
	#set HTML <li> items (for an HTML list such as <ul> list), reverse order
	POST_LIST_HTML="$POST_LIST_HTML
<li><time class=\"dt-published\" datetime=\"$date_iso8601\">$date_customfmt</time> <a class=\"p-name\" href=\"$N/\">#$N $title</a></li>"
	POST_LIST_PLAIN="$POST_LIST_PLAIN
$date_customfmt #$N ${title//[[:space:]]/ }"

	if ((POST_LIST_MAXITEMS && (LASTPOST - N) <= POST_LIST_MAXITEMS))
	then 	POST_LIST_HTML_MAX="$POST_LIST_HTML_MAX
<li><time class=\"dt-published\" datetime=\"$date_iso8601\">$date_customfmt</time> <a class=\"p-name\" href=\"$N/\">#$N $title</a></li>"
		POST_LIST_PLAIN_MAX="$POST_LIST_PLAIN_MAX
$date_customfmt #$N ${title//[[:space:]]/ }"
	fi

	#counter
	((--N))

	#keep environment clean
	unset i_timestamp index_timestamp date_rfc5322 description keywords lang html_text var lead trail date_customfmt metatags article nav_next nav_prev regex og_img_src og_img_alt ogtags temp_post_target nav_standalone cat_rss_buffer test_cat_rss_buffer src_change rss_guid rss_alt_guid rss_category enclosure_src enclosure_ext enclosure_subpath enclosure_url enclosure_size enclosure ispermalink file post_target_path post_cat_buffer_path post_canonical post_raw date_iso8601 title post_rss_buffer_path post_rss_alt_buffer_path rss_item rss_alt_item cat_rss_buffer_tidy index_timestamp_iso8601
done
echo >&2


#PART TWO - POST LISTS (REMAINING)
echo "create blog root index.html (post list)" >&2
TEMP_INDEX=$(<"$TEMPLATE_INDEX")
echo "${TEMP_INDEX/'<!-- HTML POSTLIST -->'/$POST_LIST_HTML}" >"$TARGET_INDEX"
unset TEMP_INDEX

#generate post list files
#(or do substitute these variables in some other page)
#HTML post list
[[ "$POST_LIST_HTML_PATH" ]] \
	&& echo "${POST_LIST_HTML_MAX:-$POST_LIST_HTML}" >"$POST_LIST_HTML_PATH"
#TXT post list
[[ "$POST_LIST_PLAIN_PATH" ]] \
	&& echo "${POST_LIST_PLAIN_MAX:-$POST_LIST_PLAIN}" >"$POST_LIST_PLAIN_PATH"
unset POST_LIST_HTML POST_LIST_PLAIN POST_LIST_PLAIN_MAX POST_LIST_HTML_MAX


#PART THREE - CATENATION (REMAINING)
#catenate posts into template
#cat_buffer_final_part=$(cat -- "${CATFILES[@]}")
for f in "${CATFILES[@]}" ;do cat_buffer_final_part+=$(<"$f")$'\n' ;done
#increase headings in catenated hypertext
for h in 4 3 2 1
do 	cat_buffer_final_part="${cat_buffer_final_part//"<h$h"/<h$((h+1))}"
	cat_buffer_final_part="${cat_buffer_final_part//"</h$h"/<\/h$((h+1))}"
done
#load template cat template and substitute articles
cat_buffer_final=$(<"$TEMPLATE_CAT")
cat_buffer_final="${cat_buffer_final/"<!-- CAT ARTICLES -->"/$cat_buffer_final_part}"

#tidy up cat.html?
if ((OPTI))
then 	tidyupf <<<"$cat_buffer_final"
else 	echo "$cat_buffer_final"
fi 	>"$TARGET_CAT"
unset CATFILES cat_buffer_final cat_buffer_final_part f h


#PART FOUR - RSS feeds
#read RSS feed templates
TEMP_TARGET_FEED=$(<"$TEMPLATE_FEED")
TEMP_TARGET_FEED_ALT=$(<"$TEMPLATE_FEED_ALT")
RSS_ITEM=$(cat -- "${RSSFILES[@]}" )
RSS_ALT_ITEM=$(cat -- "${RSSALTFILES[@]}" )

#substitute rss item list, and special vars
TEMP_TARGET_FEED="${TEMP_TARGET_FEED/"<!-- RSS ITEM -->"/$RSS_ITEM}"
TEMP_TARGET_FEED="${TEMP_TARGET_FEED//"<!-- CURRENT TIME RFC5322 -->"/$TIME_CURRENT_RFC5322}"
TEMP_TARGET_FEED="${TEMP_TARGET_FEED//"<!-- CURRENT TIME ISO8601 -->"/$TIME_CURRENT_ISO8601}"
TEMP_TARGET_FEED_ALT="${TEMP_TARGET_FEED_ALT/"<!-- RSS ITEM -->"/$RSS_ALT_ITEM}"
TEMP_TARGET_FEED_ALT="${TEMP_TARGET_FEED_ALT//"<!-- CURRENT TIME RFC5322 -->"/$TIME_CURRENT_RFC5322}"
TEMP_TARGET_FEED_ALT="${TEMP_TARGET_FEED_ALT//"<!-- CURRENT TIME ISO8601 -->"/$TIME_CURRENT_ISO8601}"

#tidy up rss feeds?
if ((OPTI))
then 	tidyupf --input-xml yes <<<"$TEMP_TARGET_FEED"
else 	echo "$TEMP_TARGET_FEED"
fi 	>"$TARGET_FEED"
if ((OPTI))
then 	tidyupf --input-xml yes <<<"$TEMP_TARGET_FEED_ALT"
else 	echo "$TEMP_TARGET_FEED_ALT"
fi 	>"$TARGET_FEED_ALT"
unset TARGET_FEED TARGET_FEED_ALT RSSFILES RSSALTFILES RSS_ITEM RSS_ALT_ITEM


#PART SIX -
#miscellaneous tasks

