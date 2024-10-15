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

  # Remove any existing filtered_structure directory
  rm -rf ./filtered_structure

  # Check if any file types are specified
  if [ ${#fileTypes[@]} -eq 0 ]; then
    # No file types specified, include all files
    find . "${pruneCmd[@]}" -type f -print | while read -r file; do
      dir=$(dirname "$file")
      mkdir -p "./filtered_structure/$dir"
      cp "$file" "./filtered_structure/$file"
    done
  else
    # Include only specified file types
    for fileType in "${fileTypes[@]}"; do
      find . "${pruneCmd[@]}" -name "*.$fileType" -print | while read -r file; do
        dir=$(dirname "$file")
        mkdir -p "./filtered_structure/$dir"
        cp "$file" "./filtered_structure/$file"
      done
    done
  fi

  # Use tree to display the filtered structure
  tree ./filtered_structure

  # Clean up the temporary filtered structure
  rm -rf ./filtered_structure
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
