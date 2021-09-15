#! /bin/bash

stripext() {
    echo $( echo "$1" | sed -E "s/(.*)\..*/\1/")
}

compile() {
    name=$(stripext "$1")
    fname=$(stripext $(basename "$1"))
    calldir=$(pwd)
    cd $(dirname $1)

    echo "Making $name..." >> /dev/stderr

    echo "Weaveing to $fname.pandoc.md"  >> /dev/stderr
    pweave "$fname.md" -f pandoc -o "$fname.pandoc.md" >> /dev/stderr

    echo "Adding code numbers" >> /dev/stderr
    sed -i -E "s/\`\`\`python/\`\`\`{.python .numberLines}/g" "$fname.pandoc.md"

    echo "running pandoc with custom template and design..." >> /dev/stderr
    pandoc -i "$fname.pandoc.md" -f markdown -o "$fname.tex" --template="$calldir/template.latex" --highlight-style="$calldir/style.theme" >> /dev/stderr
    
    echo "running pandoc to make pdf" >> /dev/stderr
    pandoc -i "$fname.pandoc.md" -f markdown -t pdf -o "$fname.pdf" --template="$calldir/template.latex" --highlight-style="$calldir/style.theme" >> /dev/stderr
    
    cd "$calldir"

    echo "Output at (you can pipe this):" >> /dev/stderr
    echo "$name.pdf"
}

publish() {
    name=$(stripext "$1")
    echo "Compiling again..." >> /dev/stderr
    compile $1 >> /dev/stderr
    echo -e "Compiled!\n" >> /dev/stderr
    echo -e "Tangling..." >> /dev/stderr
    ptangle $1 >> /dev/stderr
    echo -e "Tangled!\n" >> /dev/stderr
    echo -e "Packaging..." >> /dev/stderr
    tar czvf "$name.tar.gz" "$1" "$name.py" "$name.pdf" "$name.tex" >> /dev/stderr
    echo "COMPLETE! tar.gz created at " >> /dev/stderr
    echo "$name.tar.gz"
}

help() {
    echo "411 maker"
    echo "Usage: maker.sh command path"
    echo "Commands:"
    echo -e "  new \`labno\`: \t\t\t make files for new lab"
    echo -e "  compile path_to_content: \t compile to pdf"
}

case "${1}" in
    new) mkdir l$2 && echo -e "---\nlabno=$2\ndate=\\\\today\n---\n\n" > l$2/content.md ;;
    compile) compile "$2" ;;
    publish) publish "$2" ;;
    *) help ;;
esac

