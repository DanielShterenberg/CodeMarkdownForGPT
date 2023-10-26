# Function to process command line options
process_options() {
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
}

# Function to build the prune command for find
build_prune_command() {
  for excludeDir in "${excludeDirs[@]}"; do
    pruneCmd+=(-name "$excludeDir" -prune -o)
  done
}

# Function to output file content
output_file_content() {
  for fileType in "${fileTypes[@]}"; do
    find . "${pruneCmd[@]}" -name "*.$fileType" -print0 | while IFS= read -r -d '' file; do
      echo "\`\`\` $file"
      echo "$(cat "$file")"
      echo "\`\`\`"
    done
  done
}

# Function to output directory structure
output_directory_structure() {
    projectName=${PWD##*/}
    echo "- $projectName"

    # Build the exclude option for the tree command
    excludeOption=""
    for excludeDir in "${excludeDirs[@]}"; do
        excludeOption+=" -I '$excludeDir'"
    done

    # Use the tree command to output the directory structure
    # -a shows hidden files, -I excludes directories, --dirsfirst sorts directories before files
    eval "tree -a --dirsfirst $excludeOption"
}

project_snapshot() {
  # Get file types from parameters
  fileTypes=("$@")
  # Flag for directory structure
  structure=false
  # Directories to exclude - use space to separate them ("venv" "anotherDir" "yetAnotherDir")
  excludeDirs=("venv" ".git" ".idea")
  # Build the prune command for find
  pruneCmd=()

  process_options "$@"
  build_prune_command
  output_file_content

  # Output directory structure if -s flag is provided
  if $structure; then
    output_directory_structure
  fi
}
