
SCRIPT_DIRECTORY=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIRECTORY/functions.sh"
show_info "$@"

header(){
    START="<!-- OTC-HEADER-START -->"
    END="<!-- OTC-HEADER-END -->"
    check_markers
    TMP="header.local"
    echo "<!-- OTC-HEADER-START -->" > $TMP
    echo "# $GITHUB_REPOSITORY" >> $TMP
    echo -n >> $TMP
    echo "| Status | Version | last updated |" >> $TMP
    echo "| ------ | ------- | ------------ |" >> $TMP
    echo "| $STATUS | $VERSION | $DATE      |" >> $TMP
    echo "<!-- OTC-HEADER-END -->" >> $TMP
    sed -e '/'"$START"'/,/'"$END"'/!b' -e '/'"$END"'/!d;r '$TMP'' -e 'd' $FILE > tmp.local
    cp tmp.local $FILE
}

footer(){
    START="<!-- OTC-FOOTER-START -->"
    END="<!-- OTC-FOOTER-END -->"
    check_markers
    TMP="footer.local"
    echo "<!-- OTC-FOOTER-START -->" > $TMP
    echo -n >> $TMP
    echo "---" >> $TMP
    echo "<div class="pull-right">Updated: $GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID</div>" >> $TMP
    echo "<!-- OTC-FOOTER-END -->" >> $TMP
    sed -e '/'"$START"'/,/'"$END"'/!b' -e '/'"$END"'/!d;r '$TMP'' -e 'd' $FILE > tmp.local
}

get_github_info
header
footer
cp tmp.local $FILE