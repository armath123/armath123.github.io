#!/bin/sh

set -xe

echo "Watching for changes recursively... Press Ctrl+C to stop."

while inotifywait -q -e close_write -e modify -e moved_to -r .
do
    echo "Change detected. Re-compiling..."
    
    # Recursively find both *.html.m4 AND *.htm.m4 files
    find . -type f \( -name "*.html.m4" -o -name "*.htm.m4" \) | while read -r file; do
        # Extract the output filename by stripping the '.m4' suffix
        outfile="${file%.m4}"
        
        # Compile the file using m4
        m4 "$file" > "$outfile"
    done
    
    echo "✓ Done!"
done
