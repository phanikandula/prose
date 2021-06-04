#!/usr/bin/env sh
set -e # Error on any non-zero return code
set -u # Error on access of unset vars
set -o pipefail # Error on any errors from commands in a pipe |


set -a
source /site/prose.settings
set +a

CSS_FILE="assets/css/${THEME_NAME}.min.css"

function build_site() {

    host_name="$1"
    output_dir="/site/$2"

    rm -rf ${output_dir}
    mkdir -p ${output_dir}

    asciidoctor --require asciidoctor-multipage --backend multipage_html5 --attribute linkcss \
        --attribute copycss! --attribute stylesheet=${CSS_FILE} --destination-dir ${output_dir} \
        --attribute sitepath=${host_name} /site/input/home/index.adoc

    for full_book_dir in `ls -d -- /site/input/books/*/`; 
    do 
        book_dir=`basename $full_book_dir`
        asciidoctor --require asciidoctor-multipage --backend multipage_html5 --attribute linkcss \
        --attribute copycss! --attribute stylesheet=../${CSS_FILE} --destination-dir ${output_dir}/${book_dir} \
        --attribute sitepath=${host_name} /site/input/books/${book_dir}/index.adoc

        if [[ -d /site/input/books/${book_dir}/static ]];
        then
            cp -R /site/input/books/${book_dir}/static/* ${output_dir}/${book_dir}
        fi

    done;
    
    mkdir -p ${output_dir}/assets/css
    cp $HOME/prose/static/${CSS_FILE} ${output_dir}/${CSS_FILE}
}

function parse() {
    if [[ $# -eq 0 ]]; 
    then
        first_arg="build"
    else
        first_arg="$1"
    fi

    case "$first_arg" in
            help)
                    echo "Run ./prose     -- without args to build production version"
                    echo "Run ./prose dev -- to build dev version"
                    ;;
            build)
                    host_name="$PROD_HOST"
                    output_dir="${PROD_OUTPUT_DIR}"
                    echo "Building prod version of site at $output_dir"
                    build_site $host_name $output_dir
                    echo "Done."
                    ;;
            dev)
                    host_name="$DEV_HOST"
                    output_dir="${DEV_OUTPUT_DIR}"
                    echo "Building dev version of site at $output_dir"
                    build_site $host_name $output_dir
                    echo "Done."                    
                    ;;
            *)
                    echo "Got something I don't handle yet: $1"
                    ;;
    esac
}

parse "$@"