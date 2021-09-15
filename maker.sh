#! /bin/bash

stripext() {
    echo $( echo "$1" | sed -E "s/(.*)\..*/\1/")
}

compile() {
    name=$(stripext "$1")
    echo "Making $name..." >> /dev/stderr

    echo "Weaveing to $name.pandoc.md"  >> /dev/stderr
    pweave "$1" -F "$(dirname "$1")/figures" -f pandoc -o "$name.pandoc.md" >> /dev/stderr

    echo "Adding code numbers" >> /dev/stderr
    sed -i -E "s/\`\`\`python/\`\`\`{.python .numberLines}/g" "$name.pandoc.md"

    echo "running pandoc with custom template and design..." >> /dev/stderr
    pandoc -i $name.pandoc.md -f markdown -t pdf -o $name.pdf --template=template.latex --highlight-style=style.theme >> /dev/stderr

    echo "Output at (you can pipe this):" >> /dev/stderr
    echo "$name.pdf"
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
    *) help ;;
esac

