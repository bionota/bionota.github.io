#!/usr/bin/env bash
# sitemap.sh -- Generate TXT, XML and HTML sitemaps
# v0.5.3  nov/2021  by mountaineerbr
#   __ _  ___  __ _____  / /____ _(_)__  ___ ___ ____/ /  ____
#  /  ' \/ _ \/ // / _ \/ __/ _ `/ / _ \/ -_) -_) __/ _ \/ __/
# /_/_/_/\___/\_,_/_//_/\__/\_,_/_/_//_/\__/\__/_/ /_.__/_/   

#home page root
ROOT="$HOME/www/bionota.github.io"
#website root
ROOTW="https://bionota.github.io"
#blog root
ROOTB="$ROOT"
#website blog root
ROOTBW="$ROOTW"

#sitemap files
#txt
SMAPTXT="$ROOT/sitemap.txt"
#xml
SMAPXML="$ROOT/sitemap.xml"
#html (directory tree)
SMAPTREE="$ROOT/sitemap.html"
SMAPTREEW="$ROOTW/sitemap.html"

#find files with these extensions
EXTENSIONS=(htm html php asp aspx jsp)
#extensions for `tree` -- must be equivalent to \`$EXTENSIONS' array
EXTENSIONSTREE='*.htm|*.html|*.php|*.asp|*.aspx|*.jsp'

#exclude patterns from the sitemaps (TXT and XML)
#patterns are read by `sed -E', escape \ as \\
EXCLUDEARR=(
	'index\.html$' 		#don't add index.html but their parent dir only
	'.*/[._].*' 		#files starting with either . or (hidden or unlisted)
	'.*/0/.*' 		#olde website, kind of hidden
	'.*/[a-z]/.*' 		#template files such as a.html, z.html, etc
	'.*/[a-z]/.*' 		#template files such as a.html, z.html, etc
	'.*/template_.*' 	#general template files
	'.*/[a-z]\.html$'  	#unlisted directories
	'.*/bak/.*' 		#backup directory
	'.*/css/.*' 		#css stuff
	'.*/gfx/.*' 		#graphics
	'.*/js/.*' 		#java script shit
	'.*/bin/.*' 		#scripts
	'.*/misc/.*' 		#miscellaneous dir
	'.*/res/.*' 		#general resources dir
	'.*/[0-9]+/.+' 		#blog files from subdir
	'.*google.*' 		#google shit
)
#exclude for `tree` (HTML) -- must be equivalent to `$EXCLUDEARR[@]' array
#patterns are read by `tree -I'
EXCLUDETREE='[._]*|0|[a-z].html|[a-z]|template_*|index.html|bak|css|gfx|js|bin|misc|res|google*|thumb|media|sitemap.xml|sitemap.html'

#html tags for injection in tree-generated page
HTMLHEAD='<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>Website map, navigate to all pages</title>
<meta name="resource-type" content="document">
<meta name="description" content="Site map for human visitors; this navigation page may be preferable for some people to use">
<meta name="keywords" content="navigation, navegação, accessibility, acessibilidade, interface, alternativo, alternative, user navigation, navegação de usuário, discover the webste, descubra o website">
<meta name="distribution" content="global">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<!-- <link rev="made" href="mailto:jamilbio20[[at]]gmail[[dot]]com"> -->
<link rel="shortcut icon" href="favicon.png" type="image/x-icon">
<style>
	H1, H1 + P
	{
		margin: 1em 0 1em 4em;
	}
</style>'

#xml tags and schema for namespaces (xmlns attribute)
XMLHEAD="<?xml version=\"1.0\" encoding=\"utf-8\"?>
<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">"
#xml warning
XMLWARNING="	<!--

	  Hey!
	  This web page is actually a data file that is meant to be
	   read by RSS reader programs.
	  See ${SMAPTREEW:-$ROOTW} for
	   the human-readable sitemap page.

	-->"
XMLTAIL='</urlset>'
#https://infinitesticks.com/2018/07/generate-a-list-of-urls-from-a-sitemap

#clear everything on the line
CLR='\033[2K'

#script name
SN="${0##*/}"

#help page
HELP="NAME
	$SN -- Generate TXT, XML and HTML sitemaps


SYNOPSIS
	$SN

	This script will generate sitemaps in TXT, XML and HTML formats.
	Please, customise variable information, such as local and website
	roots, and  set exclusin criteria in the script head source code.

	Based on Google & Bing's sitemap guidelines. XML sitemaps should
	not contain more than 50,000 URLs and should be no larger than
	50M when uncompressed. In case of a larger site with many URLs,
	multiple sitemap files should be created. Their size should be
	no more than 10M(safer)-50M uncompressed or 50K links each.

	It is necessary to verify ownership and submit sitemap.xml to
	search engines as they may not read sitemap.xml by defaults.

	Don't forget to add the \`Sitemap' entry to robots.txt. Take
	notice that base URLs matter (http vs https).

	Human-readable time format should defaults to UTC0 when printed.

	Package \`tree' is run to generate HTML sitemap. Notice that not
	all versions of \`tree' accept the -H flag, required in this
	script.

	Initial ideas were taken from \`Poor Man's Webmaster Tools'.
	Special thanks goes to Koen Noens for the scripts.


REFERENCES
	Localised versions (alternative languages)
	<https://support.google.com/webmasters/answer/189077#sitemap>

	Google
	ping: <http://www.google.com/ping?sitemap=https://example.com/sitemap.xml>
	<https://support.google.com/webmasters/answer/183668?hl=en#addsitemap>
	<https://search.google.com/search-console/sitemaps>

	Bing & Yahoo!
	ping: <http://www.bing.com/ping?sitemap=http%3A%2F%2Fwww.example.com/sitemap.xml>
	<https://www.bing.com/webmaster/help/how-to-submit-sitemaps-82a15bd4>
	<https://www.bing.com/webmasters/sitemaps>

	Duckduckgo
	<<We get our results from multiple sources so there's no place to
	submit them to DuckDuckGo directly. Once your site is indexed by
	our sources, it should show on DuckDuckGo correctly.>>

	<<There's no direct way to submit your website URL to Yahoo! and
	AOL. All search results at Yahoo! and AOL are now powered by Bing.
	Ask.com no longer allows you to submit sitemaps.>>

	Ask.com
	<<Launch your Web browser and copy and paste the entire submission URL,
	including your sitemap, into the browser address bar and press Enter.
	A confirmation message from Ask.com appears in the browser.>>
	ping: <http://submissions.ask.com/ping?sitemap=http://<The Domain Name>/sitemapxml.aspx>
	ping: <http://submissions.ask.com/ping?sitemap=http%3A//www.URL.com/sitemap.xml>

	More
	<https://www.sitemaps.org/protocol.html>
	<https://support.google.com/webmasters/answer/183668?hl=en>
	<https://www.bing.com/webmaster/help/sitemaps-3b5cf6ed>


OPTIONS
	-h 	Help page.
	-v 	Verbose.
	-V 	Script version."


#functions

#entity escaping
escf()
{
	local input="$1"
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


#parse options
while getopts hvV c
do 	case $c in
		#help
		h) 	echo "$HELP" ;exit 0 ;;
		#verbose
		v) 	OPTV=1 ;;
		#script version
		V) 	grep -m1 '# v[0-9]' "$0" ;;
		\?) 	exit 1 ;;
	esac
done
shift $((OPTIND - 1))
unset c

#check for pkgs
for pkg in tree   #tidy
do 	if ! command -v "$pkg" &>/dev/null
	then echo "$SN: err: package missing -- $pkg" >&2 ;exit 1
	fi
done
unset pkg


#PART ZERO
#make file lists
#cd into webpage root directory
cd "$ROOT" || exit

#find files
#ignore file path with /. (hidden files and directories)
for ext in "${EXTENSIONS[@]}"
do 	SMAPFILES="$SMAPFILES
$(find "$ROOT" \( ! -path '*/.*' \) -name "*.$ext")"
done
unset ext
#append slash after directory
#https://superuser.com/questions/152958/exclude-hidden-files-when-searching-with-unix-linux-find
#https://unix.stackexchange.com/questions/4847/make-find-show-slash-after-directories

#add items to sitemap files as these may not have been included
#(for sitemap.txt and sitemap.xml)
SMAPFILES="$SMAPFILES
$SMAPTXT
$SMAPTREE
$SMAPXML
$ROOTB/rss.xml
$ROOTB/rss_alt.xml"

#exclude list
#run the exclusion array
echo "$SN: removing entries matching exclusion criteria.." >&2
empty=""
for entry in "${EXCLUDEARR[@]}"
do 	((++e))
	printf "\r${CLR}>>>%4d/%4d  %s  " "$e" "${#EXCLUDEARR[@]}" "$entry" >&2
	SMAPFILES=$(sed -E -e "s,$entry,$empty,g" <<<"$SMAPFILES")
done
echo >&2
unset empty entry e

#remove blank lines from path lists
#sort path lists
SMAPFILES=$(sed -e '/^\s*$/d' <<<"$SMAPFILES" | sort -f -V -u)


#PART ONE - TXT
#change site root to build urls
echo "${SMAPFILES//"$ROOT"/$ROOTW}" >"$SMAPTXT"


#PART TWO - XML
#timestamp
TS=$(date -u -Iseconds)
#get total links
TOTAL=$(wc -l <<<"$SMAPFILES")

#inject url entries
echo "$SN: inject url entries in XML.." >&2
while IFS=  read -r
do 	(( ++n ))

	#feedback
	((OPTV)) && eol='\n' || eol='\r'
	printf "${eol}${CLR}>>>%4d/%4d  %s  " "$n" "$TOTAL" "$REPLY"  >&2

	#escape entities for urls
	#change local root to website root
	URL=$(escf "${REPLY/"$ROOT"/$ROOTW}")

	#last modification date
	if [[ -e "$REPLY" ]]
	then 	MOD=$(stat --format="%Y" "$REPLY")
		MOD=$(date -u -Iseconds -d@"$MOD")
	else 	MOD=$(date -u -Iseconds)
	fi

	URLLIST="  <url>
    <loc>$URL</loc>
    <lastmod>$MOD</lastmod>
  </url>
$URLLIST"
done <<<"$SMAPFILES"
echo >&2
#optional attributes: lastmod, changefreq and priority


#make xml skeleton
cat >"$SMAPXML" <<!
$XMLHEAD
$XMLWARNING
$URLLIST
$XMLTAIL
<!-- generated-on="$TS" -->
<!-- items="$TOTAL" -->
!

#clean environment
unset REPLY URL URLLIST MOD SMAPFILES REPLY URL ALT MOD TS n eol


#PART THREE
#HTML (use relative paths!)
#create directory tree
echo "$SN: create sitemap.html with  \`tree' package.." >&2
#remove default meta tags
#eval "$(dircolors -b)"
tree -C -r -F -v -H '.' -L 6 \
	--noreport \
	--charset utf-8 \
	-T Sitemap \
	-P "$EXTENSIONSTREE" \
	-I "$EXCLUDETREE" \
	| sed -e 's/>\.</>Home</' -e '/<meta/,/<title/ d ;/<p class="VERSION">/,/<\/p>/ d' \
	>"$SMAPTREE"

#hack `tree' output
echo "$SN: hack \`tree' output" >&2
#add custom meta tags
sed -i -e '/<head>/ r /dev/stdin' "$SMAPTREE" <<<"$HTMLHEAD"


#PART FOUR
#optionally ping search engines with HTTP GET request
#or submit sitemap to their respective webmaster tools pages

