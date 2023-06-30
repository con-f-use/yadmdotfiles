#!/usr/bin/env bash

printf -v urlsfile 'urls_%(%y%m%d%H%M)T.txt'
printf -v tstamp '%(%m%d)T' -1
printf -v mydir '%(%y%m%d)T' -1
mkdir -p "$mydir" && cd "$mydir" || exit 1
xclip -o -selection clipboard |
    sort -u |
    tee "$urlsfile" |
    sed -E "s/(https:\/\/thumbsnap.com\/)(.\/)?([a-zA-Z0-9]+).*/\1i\/\3.jpg?$tstamp/" |
    wget -i -

received=$(ls -1 ./*.jpg | sed -E -n 's/\.\/(.*)\.jpg$/\1/p' | sort -u)
wanted=$(sed -E -n 's#^.*/([a-zA-Z0-9]+)\?.*$#\1#p' ./urls*.txt)
diff -y <(printf "$wanted") <(printf "$received") |
    sed -E -n 's/^([a-zA-Z0-9]+)\s*</\1/p' |
while read img; do
    for ext in gif webp jpeg jpg; do 
        curl --location --remote-name "https://thumbsnap.com/i/$img.$ext?$tstamp" &&
            break
    done
done

rename 's/\.(jpg|png|gif|jpeg|webp)\?[0-1][0-9]{2,}$/.\1/' *
#sxiv -a *.jpg *.png *.webp *.jpeg *.gif &

