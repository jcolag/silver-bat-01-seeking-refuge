#!/bin/bash
cover=$(mktemp --suffix=.pdf)
back=$(mktemp --suffix=.pdf)
blank=$(mktemp --suffix=.pdf)
pad=$(mktemp --suffix=.pdf)

convert xc:none -page 306x494.64 "${blank}"
convert text/assets/01-Refuge-Cover.png -resize 637.50x1030.50 -gravity center -extent 637.50x1030.50 -units PixelsPerInch -density 150 "${cover}"
convert text/assets/01-Refuge-Back-Cover.png -resize 637.50x1030.50 -gravity center -extent 637.50x1030.50 -units PixelsPerInch -density 150 "${back}"
quarkdown c --pdf text/front-matter.qd
quarkdown c --pdf text/seeking-refuge.qd

frontPages=$(pdftk output/Seeking-Refuge-Frontmatter.pdf dump_data | grep NumberOfPages | cut -f2 -d':')
mainPages=$(pdftk output/Seeking-Refuge.pdf dump_data | grep NumberOfPages | cut -f2 -d':')
pages=$((frontPages + mainPages + 4))
need=$((4 - pages % 4))
repeat=$(yes 1 | head -$need | paste -sd' ')

pdftk "${blank}" cat ${repeat} output "${pad}"
pdftk "${cover}" "${blank}" output/Seeking-Refuge-Frontmatter.pdf output/Seeking-Refuge.pdf "${pad}" "${blank}" "${back}" cat output output/Seeking-Refuge-v2.pdf
cd text || return
pandoc --from=markdown \
  --output=../output/Seeking-Refuge-v2.epub \
  --metadata title="The League of the Silver Bat #1:  Seeking Refuge" \
  --metadata author="John Colagioia" \
  --toc \
  --css assets/epub.css \
  --epub-cover assets/01-Refuge-Cover.png \
  --epub-embed-font=fonts/SourceSansPro-Regular.otf \
  --epub-embed-font=fonts/Comfortaa-Regular.ttf \
  <(sed 's/<<<//g;s/^#/\n\n#/g;s/ - /---/g;s/^\..*//g;s/#!/#/g;s/^  //g' ./*.md)
cd ..
nohup evince output/Seeking-Refuge-v2.pdf &
rm "${cover}" "${back}" "${blank}" "${pad}" output/Seeking-Refuge-Frontmatter.pdf output/seeking-refuge.zip
sleep 1
rm nohup.out
zip -Djv9 output/seeking-refuge output/Seeking-Refuge-v2.pdf output/Seeking-Refuge-v2.epub

