
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
    echo "<p align="right">⚙ $DATE</p>" >> $TMP
    echo "<details>" >> $TMP
    echo "<summary>Table of contents</summary>" >> $TMP
    echo >> $TMP
    npx markdown-toc $FILE > toc.local
    echo >> $TMP
    cat toc.local >> $TMP
    echo >> $TMP
    echo "</details>" >> $TMP
    echo -n >> $TMP
    echo "<!-- OTC-HEADER-END -->" >> $TMP
    sed -e '/'"$START"'/,/'"$END"'/!b' -e '/'"$END"'/!d;r '$TMP'' -e 'd' $FILE > tmp.local
    cp tmp.local $FILE
  }
footer(){
    START="<!-- OTC-FOOTER-START -->"
    END="<!-- OTC-FOOTER-END -->"
    check_markers
    TMP="footer.local"
    echo "<!-- OTC-FOOTER-START -->" >> $TMP
    echo "# Terraform Docs" >> $TMP
    echo >> $TMP
    echo "<!-- BEGIN_TF_DOCS -->" >> $TMP
    echo "<!-- END_TF_DOCS -->" >> $TMP
    echo "---" >> $TMP
    echo "<p align="right">Updated: $GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID</p>" >> $TMP
    echo "<!-- OTC-FOOTER-END -->" >> $TMP
    sed -e '/'"$START"'/,/'"$END"'/!b' -e '/'"$END"'/!d;r '$TMP'' -e 'd' $FILE > tmp.local
    cp tmp.local $FILE
}

terraform_docs(){
  terraform-docs -c "$SCRIPT_DIRECTORY/terraform-docs.yml" $(dirname "${FILE}")
}
get_github_info
cat $FILE
echo "---"
footer
cat $FILE
echo "---"
terraform_docs
echo "---"
cat $FILE
header
git_push