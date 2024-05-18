# CodeMarkdownForGPT

When working with chatGPT as a code-writing assistant, sometimes we need to share the code with it. Project Snapshot is
a script that allows you to output the content of specified file types along with an optional directory structure from
the terminal. It's a handy tool for quickly reviewing or sharing the current state of your project's codebase.

## Prerequisites

- Zsh
- Tree command-line utility

## Installation

1. Clone this repository or download the script `project_snapshot.sh`.
2. Make the script executable by running `chmod +x project_snapshot.sh`.
3. (Optional) Install the `tree` command-line utility (for the structure option):
   - On Ubuntu: `sudo apt-get install tree`
   - On macOS: `brew install tree`
    
## Usage

To use Project Snapshot, you need to have either Zsh or Bash installed on your machine.

1. Clone this repository or download the script `project_snapshot.sh`.
2. Make the script executable by running `chmod +x project_snapshot.sh`.
3. Execute the script in the root directory of your project.

```bash
./project_snapshot.sh [options] filetypes...
```

### Options

- `-s`: Include directory structure in the output.
- `-f`: Include file contents for specified file types in the output.

### File Types

Specify the file types you want to include in the output by their extensions, separated by spaces.

### Examples

```bash
# Output the content of all .js and .css files
./project_snapshot.sh -f js css

# Output the directory structure only
./project_snapshot.sh -s

# Output the content of all .py files and include the directory structure
./project_snapshot.sh -s -f py

# Output the directory structure and all file contents
./project_snapshot.sh -s -f
```

## Integrating with Zsh

To make this script easily accessible from anywhere, you can add it to your Zsh or Bash source.

1. Move `project_snapshot.sh` to a location in your PATH, for example `~/bin/`.
2. Rename `project_snapshot.sh` to `project_snapshot` for easier access.
3. Now you can use the `project_snapshot` command from anywhere:

```bash
project_snapshot [options] filetypes...
```

### Adding to PATH (Optional)

If you don't have a bin directory in your home directory or it's not included in your PATH, 
you can create it and add it to your PATH by adding the following lines to your `.zshrc` (for Zsh) or `.bashrc` (for Bash) file:
```bash
mkdir -p ~/bin
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```
Or for Bash:
```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Now move `project_snapshot.sh` to `~/bin/` and rename it to `project_snapshot`:

```bash
mv project_snapshot.sh ~/bin/project_snapshot
```

Now you should be able to call `project_snapshot` from anywhere.

## Contributing

If you have suggestions for how Project Snapshot could be improved, or want to report a bug, open an issue! We'd love for you to contribute to this project by fixing bugs or adding features.
