#!/bin/env  zsh


setopt extendedglob globstarshort

dir=/home/jsn/arq/fotos/2015jul_Fotos_Japao_CDsdaEliane
dir=/home/jsn/2015jul_Fotos_Japao_CDsdaEliane
dir=/home/jsn/www/bionota.github.io/misc

cd $dir

#Resize the image if it is larger than the specified dimensions.
#This will automatically preserve the aspect ratio of the image too.
thumblr()
{
	local f size
	[[ "$1" =~ ^[0-9x]+ ]] && size=$1 && shift || size=200x150
	for file in "$@"
	do 	convert "$file" -resize $size\> "${file%.*}Thumb.${file##*.}"
	done
}
#OBS: prefer to use programme `thumb' from imagemagickA6
# Using FFMPEG to Extract a Thumbnail from a Video
#{ ffmpeg -i InputFile.FLV -vframes 1 -an -s 400x222 -ss 30 OutputFile.jpg ;}
#https://networking.ringofsaturn.com/Unix/extractthumbnail.php
# Meaningful thumbnails for a Video using FFmpeg
#{ ffmpeg -ss 3 -i input.mp4 -vf "select=gt(scene\,0.4)" -frames:v 5 -vsync vfr -vf fps=fps=1/600 out%02d.jpg ;}
#https://superuser.com/questions/538112/meaningful-thumbnails-for-a-video-using-ffmpeg

#ls **Thumb.* >&2 || thumblr 500 **.jpg~Imagem*~Redações*
#ff=(**Thumb.*)

ff=(**.jpg~Imagem*~Redações*)
for f in $ff[@]
do
	((i++ % (${#ff[@]}/2) )) || block+='	
	<div class="w3-half">'
  	block+="
	<a href=\"${f/Thumb/}\" title=\"${${f##*/}%.jpg}\"><img src=\"$f\" style=\"width:100%\"></a>"
	((i % (${#ff[@]}/2) )) || block+='</div>'

done

block="<!-- Photo Grid -->
$block
<!-- End Page Content -->"

file=$(< ./index.html-template)
file="${file/<!-- Photo Grid -->*<!-- End Page Content -->/$block}"



print $file > ./index.html


exit
: || {
<!-- Photo Grid -->
<div class="w3-row-padding w3-grayscale" style="margin-bottom:128px">
  <div class="w3-half">
    <img src="/w3images/wedding.jpg" style="width:100%">
    <img src="/w3images/rocks.jpg" style="width:100%">
    <img src="/w3images/falls2.jpg" style="width:100%">
    <img src="/w3images/paris.jpg" style="width:100%">
    <img src="/w3images/nature.jpg" style="width:100%">
    <img src="/w3images/mist.jpg" style="width:100%">
    <img src="/w3images/paris.jpg" style="width:100%">
  </div>

  <div class="w3-half">
    <img src="/w3images/underwater.jpg" style="width:100%">
    <img src="/w3images/ocean.jpg" style="width:100%">
    <img src="/w3images/wedding.jpg" style="width:100%">
    <img src="/w3images/mountainskies.jpg" style="width:100%">
    <img src="/w3images/rocks.jpg" style="width:100%">
    <img src="/w3images/underwater.jpg" style="width:100%">
  </div>
</div>
  
<!-- End Page Content -->

}




