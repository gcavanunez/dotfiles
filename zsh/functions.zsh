# Quick directory navigation
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Git shorthand
gs() { git status "$@"; }
gd() { git diff "$@"; }

# Git push and open PR URL
gpr() {
    git push origin HEAD

    if [ $? -eq 0 ]; then
        github_url=$(git remote -v | awk '/fetch/{print $2}' | sed -Ee 's#(git@|git://)#http://#' -e 's@com:@com/@' -e 's%\.git$%%')
        branch_name=$(git symbolic-ref HEAD 2>/dev/null | sed 's#^.*/##')
        remote_name=$(git remote)
        main_branch=$(git remote show $remote_name | awk '/HEAD branch/{print $NF}')
        pr_url=$github_url"/compare/"$main_branch"..."$branch_name
        echo $pr_url | pbcopy
        echo 'Pull request URL copied to clipboard.'
    else
        echo 'Failed to push commits and copy pull request URL.'
    fi
}

# Laravel
tinker() {
    if [ -z "$1" ]; then
        php artisan tinker
    else
        php artisan tinker --execute="dd($1);"
    fi
}

# Video / ffmpeg
convert_to_mp4() {
    local input_file="$1.mkv"
    local output_file="$1.mp4"
    ffmpeg -i "$input_file" -c copy "$output_file"
}

convert_to_mp4_fast() {
    local input_file="$1.mp4"
    local output_file="$1-speedrun.mp4"
    ffmpeg -i "$input_file" -filter_complex "[0:v]setpts=0.8*PTS[v];[0:a]atempo=1.25[a]" -map "[v]" -map "[a]" "$output_file"
}

transcode-video-1080p() {
    ffmpeg -i $1 -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy ${1%.*}-1080p.mp4
}

transcode-mov-to-mp4() {
    ffmpeg -i "$1" -c:v libx264 -preset fast -crf 23 -c:a aac "${1%.*}.mp4"
}

# Files
slugify_filenames() {
    local DIR="$1"

    if [[ -z "$DIR" ]]; then
        echo "Usage: slugify_filenames <directory>"
        return 1
    fi

    if [[ ! -d "$DIR" ]]; then
        echo "Error: '$DIR' is not a valid directory."
        return 1
    fi

    find "$DIR" -type f | while read file; do
        dir=$(dirname "$file")
        filename=$(basename -- "$file")
        newname=$(echo $filename | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-zA-Z0-9._]/-/g' -e 's/--*/-/g')
        newfile="${dir}/${newname}"

        if [[ "$file" != "$newfile" ]]; then
            if [[ -e "$newfile" ]]; then
                echo "Warning: not renaming '$file' because '$newfile' already exists."
            else
                mv "$file" "$newfile"
                echo "Renamed '$file' to '$newfile'"
            fi
        fi
    done
}

compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }

# MySQL
mysql_connect() {
    mysql --socket /tmp/mysql_3306.sock -uroot
}

mysql_createdb() {
    if [ -z "$1" ]; then
        echo "Need to provide a database name"
    else
        mysql_connect <<MYSQL_SCRIPT
CREATE DATABASE $1 CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
MYSQL_SCRIPT
        echo "MySQL user and database created."
        echo "Database: $1"
    fi
}

# Search
rgfzf() {
    rg --color=always --line-number --no-heading --smart-case "${*:-}" \
    | fzf -d':' --ansi \
        --preview "bat -p --color=always {1} --highlight-line {2}" \
        --preview-window ~8,+{2}-5 \
    | awk -F':' '{print $1}'
}

# Diff this host's mise config against the bootstrap template for this OS.
misediff() {
    local template

    case "$(uname -s)" in
        Darwin)
            template="$HOME/dotfiles/mise/config.macos.template.toml"
            ;;
        Linux)
            template="$HOME/dotfiles/mise/config.linux.template.toml"
            ;;
        *)
            echo "Unsupported OS: $(uname -s)" >&2
            return 1
            ;;
    esac

    diff -u "$template" "$HOME/.config/mise/config.toml"
}
