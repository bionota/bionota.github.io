#!/usr/bin/env bash
# generate html lists from urls
# v0.3.6  jan/2021  by mountaineerbr

#maximum length of title
MAXTITLELEN=300
#maximum description length
MAXDESCLEN=1000
#minimum description length
MINDESCLEN=20
#minimum <p> length
MINPLEN=20
#which <p> to fetch first
PNUM=1
#curl maximum time
MAXTIME=10
#main language glob
MAINLANG='pt*'

#chrome on windows 10
UAG='user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36'

HELP="NAME
        ul.sh -- Generate HTML list with url from positional arguments, file or stdin
USAGE
        ul.sh [OPTION..] [URL..]
        ul.sh [OPTION..] list.txt
OPTIONS
    -[0-9]         Set to fetch the Nth <p> tag, def=$PNUM
    -d             Detailed list
    -e MIN_LENGTH  Min length of description before switching to <p>, def=$MINDESCLEN
    -E MAX_LENGTH  Truncate length of description, def=$MAXDESCLEN
    -f             Don't print HTML elements at all, may combine with -pd.
    -h             Print this help page
    -l, -ll        Print hreflang or hreflang and lang attibutes, def=$MAINLANG
    -L LANG        Language for -ll (glob match skips printing), def=$MAINLANG
    -p             Prefer <p> for description
    -P MIN_LENGTH  Min length of <p> tag to fetch, def=$MINPLEN
    -s             Don't print newline between items
    -T MAX_LENGTH  Truncate length of title, def=$MAXTITLELEN
    -u             Don't print <ul> and <dl> tags"
#obs: if title checks fail, it falls back to <h1>
#obs: if description checks fail, it falls back to <p>, <h1> and <h2>


#curl
curlf()
{
    curl --compressed -sLb non-existing --max-time "$MAXTIME" --header "$UAG" "$1" ||
        wget -qO- --timeout="$MAXTIME" --header "$UAG" "$1"
}

#UTF-8-encode a string of Unicode symbols
escape()
{
	printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u);
	# print a newline unless we’re piping the output to another program
	if [ -t 1 ]; then
		echo ""; # newline
	fi;
}

#print li item
lif()
{
    local page title lang l hreflang h1 url desc p plongest plongest_try pbuf pnum

    pnum=$PNUM url="$1"
    page="$(curlf "$url")"

    [[ "$page" =~ \<(title|title\ +[^>]*)\>([^<]*)\< ]]
    title="${BASH_REMATCH[2]}"
    [[ "${title//[$IFS]}" ]] || {
        [[ "$page" =~ \<(h1|h1\ +[^>]*)\>([^<]*)\< ]]
        h1="${BASH_REMATCH[2]}"
    }
    title="${title:0:$MAXTITLELEN}" h1="${h1:0:$MAXTITLELEN}"

    #DESCRIPTION OR P
    ((OPTD)) && {
         [[ "$page" =~ (description[^>]+content=[\'\"$'\n']*)([^\'\"]*)[\'\"] ]]
         desc="${BASH_REMATCH[2]}"
         [[ -z "$OPTP" && ( "${desc//[$IFS]}" && "${#desc}" -gt $MINDESCLEN ) ]] || {
             for el in p h1 h2
             do
                 pbuf="$page" plongest=  plongest_try=  pnum=
                 while [[ "$pbuf" =~ \<($el|$el\ +[^>]*)\>([^<]*)\< ]] && ((${#p}<MINPLEN))
                 do
                     ((++pnum))
                     pbuf="${pbuf/<$el}"
                     plongest=$(hf <<<"${BASH_REMATCH[2]}")
                     ((${#plongest}>${#p})) && p="$plongest"
                     ((pnum>=PNUM)) || p=
                     ((${#p}>=MINPLEN)) && break 2
                 done
             done
         }
    }

    #LANGUAGE
    ((OPTL)) && {
         [[ "$page" =~ lang=[\'\"$'\n']([^\'\"]+)[\'\"] ]]
         l="${BASH_REMATCH[1]}" l="${l//[$IFS]}"
         if [[ -z "$l" ]]
	 then    unset l lang hreflang ;echo "warning: \`lang' attribute not found -- <$1>" >&2
         elif [[ "$l" && "$l" = $MAINLANG ]]
	 then    unset l lang hreflang
	 else    hreflang=" hreflang=\"$l\""  lang=" lang=\"$l\""
                 ((OPTL==1)) && unset lang
         fi
     }

    #final edits
    title=$(hf <<<"$title")
    desc=$(hf <<<"$desc")
    p=$(hf <<<"$p")
    title="${title//[$IFS]/ }"  h1="${h1//[$IFS]/ }"  desc="${desc//[$IFS]/ }"  p="${p//[$IFS]/ }"
    title="${title# }"  h1="${h1# }"  desc="${desc# }"  p="${p# }"
    title="${title% }"  h1="${h1% }"  desc="${desc% }"  p="${p% }"
    desc="${desc:0:$MAXDESCLEN}"  p="${p:0:$MAXDESCLEN}"

    if ((OPTF))
    then echo "${h1:-$title}"${OPTD:+$'\n'}"${p:-$desc}"$'\n'"<$url>"
    elif ((OPTD))
    then echo "  <dt><a${lang}${hreflang} href=\"$url\">${h1:-$title}</a></dt>
   <dd${lang}>${p:-$desc}</dd>"
    else echo "  <li><a${lang}${hreflang} href=\"$url\">${h1:-$title}</a></li>"
    fi

    ((OPTS)) || echo
}

#remove leading & trailing whitespace
trim()
{
    local var="${*//$'\r'}"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    printf '%s' "$var"
}
#https://web.archive.org/web/20121022051228/http://codesnippets.joyent.com/posts/show/1816


#parse options
while getopts 0123456789de:E:fhlL:pP:sT:u c
do  case $c in
        [0-9]) PNUM="$PNUM$c" OPTP=1 ;;
        d) OPTD=1 ;;
        e) MINDESCLEN=$OPTARG ;;
        E) MAXDESCLEN=$OPTARG ;;
        f) OPTF=1 OPTU=1 ;;
        h) echo "$HELP" ;exit ;;
        l) ((++OPTL)) ;;
        L) MAINLANG="$OPTARG" ;;
        p) OPTP=1 OPTD=1 ;;
        P) MINPLEN=$OPTARG OPTP=1 ;;
        s) OPTS=1 ;;
        T) MAXTITLELEN=$OPTARG ;;
        u) OPTU=1 ;;
        \?) exit 1 ;;
    esac
done
shift $((OPTIND -1))
unset c
shopt -s nocasematch  #nocaseglob #extglob 

#try and choose terminal browser to process html
if command -v w3m
then 	hf() { w3m -dump -T text/html ;}
elif command -v lynx
then 	hf() { lynx -force_html -stdin -dump -nolist ;}
elif command -v elinks
then 	hf() { elinks -dump  -no-references ;}
else 	hf() { sed 's/<[^>]*>//g' ;}
fi &>/dev/null


if ((OPTU+OPTF))
then :
elif ((OPTD))
then echo '<dl>'
else echo '<ul>'
fi

if (($#))
then
    for url
    do 	url="$(trim "$url")" ;[[ -z "$url" ]] || lif "$url"
    done
elif [[ -e "$1" || ! -t 0 ]]
then
    exec 0< "${1:-/dev/stdin}"
    while IFS= read -r url || [[ -n "${url// }" ]]
    do 	url="$(trim "$url")" ;[[ -z "$url" ]] || lif "$url"
    done
fi

if ((OPTU+OPTF))
then :
elif ((OPTD))
then echo '</dl>'
else echo '</ul>'
fi

