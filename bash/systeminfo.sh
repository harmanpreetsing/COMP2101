#!/bin/bash

# Function to display help message
display_help() {
    echo "Usage: systeminfo.sh [OPTIONS]"
    echo "Options:"
    echo "  -h    Display help for your script and exits"
    echo "  -v    Run your script verbosely, showing any errors to the user instead of sending them to the logfile"
    echo "  -system    Run only the computerreport, osreport, cpureport, ramreport, and videoreport"
    echo "  -disk    Run only the diskreport"
    echo "  -network    Run only the networkreport"
}

# Function to perform computer report
computerreport() {
    # Add code to perform computer report
    echo "Performing computer report..."
}

# Function to perform OS report
osreport() {
    # Add code to perform OS report
    echo "Performing OS report..."
}

# Function to perform CPU report
cpureport() {
    # Add code to perform CPU report
    echo "Performing CPU report..."
}

# Function to perform RAM report
ramreport() {
    # Add code to perform RAM report
    echo "Performing RAM report..."
}

# Function to perform video report
videoreport() {
    # Add code to perform video report
    echo "Performing video report..."
}

# Function to perform disk report
diskreport() {
    # Add code to perform disk report
    echo "Performing disk report..."
}

# Function to perform network report
networkreport() {
    # Add code to perform network report
    echo "Performing network report..."
}

    # If no command line options are provided, run full system report
    if [[ $# -eq 0 ]]; then
        computerreport
        osreport
        cpureport
        ramreport
        videoreport
        diskreport
        networkreport
    fi

