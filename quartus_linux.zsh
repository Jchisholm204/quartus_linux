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


# qmk function
export function qmk(){
    # Get all projects in the working directory
    local project_files=($(find . -type f -path "*.qpf"))

    # Check if there is a project
    if [[ ${#project_files} = 0 ]]; then
        echo "Quartus project files not found."
        echo "Please run this script from the project base directory"
        return 1
    fi

    local project="${project_files[1]}"
    echo "${#project_files[@]} : $project"

    # Test if there is more than one possible project
    if [[ ${#projects[@]} -ge 1 ]]; then
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
                project=$projects[$sel]
                break
            fi
        done
    fi # END: Test if there is more than one project

    # Remove the extension from the project name
    #   - Allows it to be used for multiple functions
    #   - Assumes that all project files have the same name
    #       + different extensions
    
    # Options
    if [[ $# = 0 || $1 = "build" ]]; then
        echo "Building Quartus Project..."
        ql_compile "$project"
        return 0
    elif [[ $1 = "flash" ]]; then
        # Test if the output files are present
        if [[ -f "./output_files/${project::-4}.sof" ]]; then
            ql_flash "./output_files/${project::-4}.sof"
        else
            echo "Flash Files not found..."
            return 1
        fi
    fi
}

