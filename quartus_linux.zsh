#!/bin/zsh

# Get the location where all the scripts are
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Source the functions file
if [[ ! -f "$SCRIPT_DIR/functions.zsh" ]]; then
    echo "Functions file not found!!"
    exit
else
    source "$SCRIPT_DIR/functions.zsh"
fi

# Get all projects in the working directory
local projects=($(find . -type f -path "*.qpf"))

export QMK_PROJECT_DIR=$(pwd)

# Get just the names of the projects
for ((i = 0; i < ${#projects[@]}; i++)); do
    projects[i+1]=$(sed "s/.qpf//" <<< "${projects[i+1]}")
    projects[i+1]="${projects[i+1]#./}"
done

# Check if there is a project
if [[ ${#projects} = 0 ]]; then
    echo "No projects were found."
    echo "Please run this script from the project base directory"
    return 1
fi

# Set the project name
export QMK_PROJECT_NAME=$projects[1]

# Test if there is more than one possible project
if [[ ${#projects[@]} -ne 1 ]]; then
    echo "Multiple Projects Found. Please select one:"
    for ((i = 1; i < ${#projects[@]}+1; i++)); do
        echo "$i.........${projects[$i]}"
    done

    local sel=0
    # Get the user to select which project to use
    while [[ true ]] do
        echo -n "Selection: "
        read sel
        # Checkc if the selection is a number
        if [[ ! "$sel" =~ ^-?[0-9]+$ ]]; then
            echo "That's not a valid number."
            continue
        fi
        # Check that the selection was valid
        if [[ $sel > ${#projects[@]} || $sel = 0 ]]; then
            echo "Oops.. looks like thats not a valid selection"
        else
            # Setup the project name
            export QMK_PROJECT_NAME=$projects[$sel]
            break
        fi
    done
fi

# Echo project name
echo "Setting up Quartus Project: $QMK_PROJECT_NAME"


# qmk function
export function qmk(){
    if [[ "$QMK_PROJECT_DIR" != "$(pwd)" ]]; then
        echo "QMK Project directory does not match the current working directory."
        return 1
    fi
    if [[ ! -n $QMK_PROJECT_NAME ]]; then
        echo "Quartus MaKe called without a project"
        echo "Source QMK from the project directory to rectify the issue"
    fi
    if [[ $# = 0 ]]; then
        echo "Executing default action: Build"
        ql_compile "$QMK_PROJECT_NAME.qpf"
        return 0
    else
        if [[ $1 = "build" ]]; then
            ql_compile "$QMK_PROJECT_NAME.qpf"
        fi
        if [[ $1 = "flash" ]]; then
            ql_flash "$QMK_PROJECT_DIR/output_files/$QMK_PROJECT_NAME.sof"
        fi
    fi

}
echo "Set up Quartus $QMK_PROJECT_NAME Project"

