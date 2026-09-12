#!/bin/bash

find . -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.gif" \) | while read -r img; do
    
    # Որոշել նոր ֆայլի անունը (.webp ընդլայնմամբ)
    webp_img="${img%.*}.webp"

    # Դեպք 1: Եթե ֆայլը GIF անիմացիա է
    if [[ "${img##*.}" =~ ^[gG][iI][fF]$ ]]; then
        echo "Վերածվում է անիմացիոն WebP-ի: $img"
        # Օգտագործում ենք gif2webp գործիքը հատուկ անիմացիաների համար
        if gif2webp -q 75 "$img" -o "$webp_img" -quiet; then
            rm "$img"
        fi
        continue
    fi

    # Դեպք 2: Եթե ֆայլը սովորական նկար է (PNG/JPG)
    width=$(identify -format "%w" "$img" 2>/dev/null)
    [ -z "$width" ] && continue # Բաց թողնել, եթե ֆայլը վնասված է

    # Կիրառել չափսերի փոփոխություն միայն եթե լայնությունը մեծ է 1366px-ից
    if [ "$width" -gt 1366 ]; then
        echo "Չափսը փոխվում է և վերածվում WebP-ի: $img ($width px -> 1366px)"
        if convert "$img" -resize 1366x -quality 75 "$webp_img"; then
            rm "$img"
        fi
    else
        echo "Միայն վերածվում է WebP-ի (արդեն փոքր է 1366px-ից): $img"
        if cwebp -q 75 "$img" -o "$webp_img" -quiet; then
            rm "$img"
        fi
    fi
done
