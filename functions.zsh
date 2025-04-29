#!/bin/zsh

# Check if a project file is valid
# @param $1 - Project File
function ql_check_project() {
    # Check the arguments
    if [[ $# -ne 1 ]]; then
        echo "No Project given to check_project"
        return 1
    fi
    # Check that the project file is valid
    if [[ $1 != *".qpf" ]]; then
        echo "Project file did not match the format *.qpf"
        return 2
    fi
    # Check that the project file exists
    if [[ ! -f $1 ]]; then
        echo "Project $1 does not exist"
        return3
    fi
    return 0
}


# Add File - Add a file to the quartus project
# This does not check if the file already exists
# @param $1 - Project File
# @param $2 - Source file to add (Path from project base)
function ql_add_file() {
    # Check the arguments
    if [[ $# -ne 2 ]]; then
        echo "Failed to add file"
        echo "Incorrect number of arguments passed"
        return 1
    fi
    # Check if the project is valid
    ql_check_project $1
    if [[ $? != 0 ]]; then
        echo "Invalid Project"
return 2
    fi
    # Check that the source file exists
    if [[ ! -f $2 ]]; then
        echo "Source file $2 does not exist"
        return 4
    fi

    echo "set_global_assignment --name VERILOG_FILE $2" >> "$1"
}


# Modify a project, add a pinmap
# @param $1 - Project File (*.qsf)
# @param $2 - Pin name (PIN_xxx)
# @param $3 - Assignment Name
function ql_add_pin() {
    if [[ $# -ne 3 ]]; then
        echo "add_pin called with incorrect arguments"
        return 1
    fi
    # Check project file exists
    if [[ ! -f $1 ]]; then
        echo "add_pin: Project file does not exist"
        return 2
    fi
    # Check project file matches type
    if [[ $1 != *".qsf" ]]; then
        echo "add_pin: Project file must be of type *.qsf"
        return 2
    fi
    # Check pin format
    if [[ $2 != "PIN_"* ]]; then
        echo "add_pin: Pin does not match expected type"
    fi
    # Check if pin or variable exists in current project
    # Delete that line if it does
    sed -i "/set_location_assignment $2 -to .*/d" "$1"
    sed -i "/set_location_assignment .* -to $3 /d" "$1"
    # sed -i '/set_location_assignment $2 -to *'
    # sed -i '/set_location_assignment * -to $3'
    echo "set_location_assignment $2 -to $3" >> "$1"
}

# Compile the project
# @param $1 - Project File
function ql_compile() {
    # Check if the project is valid
    if [[ $# -ne 1 ]]; then
        echo "Compile called with an invalid number of arguments"
    fi
    ql_check_project "$1"

    echo "Compiling $1"
    quartus_map "$1"

    echo "Fitting $1"
    quartus_fit "$1"

    echo "Assembling $1"
    quartus_asm "$1"
    return 0
}

# Flash the program to the development board
function ql_flash() {
    if [[ $# -ne 1 ]]; then
        echo "Flash called without a target file"
        return 1
    fi
    quartus_pgm -c USB-Blaster -m JTAG -o "p;$1"
    return 0
}


# Sample Usage
# ql_add_file  "../MiniSRC/miniSRC.qpf" ../MiniSRC/Processor/REG32.v
# ql_add_pin "../MiniSRC/miniSRC.qsf" "PIN_B7" "VGA_SYNC"
# ql_compile "../MiniSRC/miniSRC.qpf"

