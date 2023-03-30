
SCRIPT_DIRECTORY=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIRECTORY/functions.sh"
show_info "$@"

header(){
echo "<!-- OTC-HEADER-START -->" > header.local
echo "# $GITHUB_REPOSITORY" >> header.local
echo -n

}

footer(){
  echo footer
}

header