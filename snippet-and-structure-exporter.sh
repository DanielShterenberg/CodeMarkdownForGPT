outputCode() {
  # Get file types from parameters
  fileTypes=("$@")

  # Flag for directory structure
  structure=false

  # Directories to exclude - use space to separate them ("venv" "anotherDir" "yetAnotherDir")
  excludeDirs=("venv")  # Add directory names to exclude here

  # Build the prune command for find
  pruneCmd=()
  for excludeDir in "${excludeDirs[@]}"; do
    pruneCmd+=(-name "$excludeDir" -prune -o)
  done

  # Check for -s flag
  while getopts ":s" opt; do
    case ${opt} in
      s )
        # Set flag
        structure=true
        ;;
      \? )
        echo "Usage: outputCode [-s] filetypes"
        return
        ;;
    esac
  done
  shift $((OPTIND -1))

  # Go over the directory recursively for specified file types
  for fileType in "${fileTypes[@]}"; do
    eval "find . $pruneCmd -name \"*.$fileType\" -print0" | while IFS= read -r -d '' file; do
      echo "\`\`\` $file"
      echo "$(cat "$file")"
      echo "\`\`\`"
    done
  done

  # Output directory structure if -s flag is provided
  if $structure; then
    # Create a temporary file for processed directories
    tempDirFile=$(mktemp)

    # Get the current directory name as the project name
    projectName=${PWD##*/}
    echo "- $projectName"

    # First, get all relevant file paths
    for fileType in "${fileTypes[@]}"; do
        find . "${pruneCmd[@]}" -name "*.$fileType" | while IFS= read -r file; do
            skip=false
            for excludeDir in "${excludeDirs[@]}"; do
                if [[ $file == ./$excludeDir/* ]]; then
                    skip=true
                    break
                fi
            done
            if $skip; then
                continue
            fi

            fullPath=""
            # Splitting the path into parts using Zsh-specific parameter expansion
            parts=("${(@s:/:)file}")
            for i in "${parts[@]:1}"; do  # skip the '.' part
                fullPath+="/$i"
                # Check if directory/file was already processed
                if ! grep -Fxq "$fullPath" "$tempDirFile"; then
                    echo "$fullPath" >> "$tempDirFile"
                    # Check if it's the last item in the directory
                    if [ "$fullPath" = "$(echo "$fullPath" | sed 's/[^\/]*$//')$(ls "$(echo "$PWD$fullPath" | sed 's/[^\/]*$//')" | tail -n 1)" ]; then
                        prefix="└──"
                    else
                        prefix="├──"
                    fi

                    # If it's a file
                    if [[ "$fullPath" == *".$fileType" ]]; then
                        if [[ "$fullPath" == /*/* ]]; then  # Nested files
                            echo "$fullPath" | sed -e "s/[^-][^\/]*\//│   /g" -e "s/\//$prefix /"
                        else  # Root level files
                            echo "$prefix ${fullPath:1}"  # Strips off the leading "./"
                        fi
                    else  # Directories
                        if [[ "$fullPath" == */*/* ]]; then  # Nested directories
                            echo "$fullPath" | sed -e "s/[^-][^\/]*\//│   /g" -e "s/\//│  /"
                        else  # Top level directories
                            echo "$fullPath" | sed -e "s/[^-][^\/]*\//│   /g" -e "s/\//  /"
                        fi
                    fi
                fi
            done
        done
    done

    # Clean up temporary file
    rm "$tempDirFile"
  fi
}