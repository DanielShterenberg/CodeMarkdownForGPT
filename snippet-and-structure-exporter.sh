#!/bin/bash

# Function to process command line options
process_options() {
  while getopts ":sf" opt; do
    case ${opt} in
      s )
        # Set flag for structure
        structure=true
        ;;
      f )
        # Set flag for file contents
        files=true
        ;;
      \? )
        echo "Usage: outputCode [-s] [-f] filetypes"
        exit 1
        ;;
    esac
  done
  shift $((OPTIND -1))
  fileTypes=("$@")  # Get the remaining arguments as file types
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

# Main function to handle project snapshot
project_snapshot() {
  # Flags for directory structure and file contents
  structure=false
  files=false
  # Directories to exclude - use space to separate them ("venv" ".git" ".idea")
  excludeDirs=("venv" ".git" ".idea" "node_modules")
  # Build the prune command for find
  pruneCmd=()

  # Process options and file types
  process_options "$@"
  build_prune_command

  # Output directory structure if -s flag is provided
  if $structure; then
    output_directory_structure
  fi

  # Output file contents if -f flag is provided
  if $files; then
    output_file_content
  fi
}

# Run the project_snapshot function with the provided arguments
project_snapshot "$@"
