#!/bin/bash

PASSWORD_FILE="passwords.txt"
TEMP_FILE=".temp"

# Function to encrypt passwords
encrypt_password() {
    local password="$1"
    echo "$password" | openssl enc -aes-256-cbc -salt -pass pass:supersecretpassword
}

# Function to decrypt passwords
decrypt_password() {
    local encrypted_password="$1"
    echo "$encrypted_password" | openssl enc -d -aes-256-cbc -salt -pass pass:supersecretpassword 2>/dev/null
}

# Function to add a password
add_password() {
    local service="$1"
    local username="$2"
    local password="$3"

    if grep -q "^$service:" "$PASSWORD_FILE"; then
        echo "Service already exists. Use 'update' to change the password."
        exit 1
    fi

    local encrypted_password=$(encrypt_password "$password")
    echo "$service:$username:$encrypted_password" >> "$PASSWORD_FILE"
    echo "Password added successfully."
}

# Function to retrieve a password
retrieve_password() {
    local service="$1"
    local line=$(grep "^$service:" "$PASSWORD_FILE" | head -n 1)
    
    if [ -z "$line" ]; then
        echo "Service not found."
        exit 1
    fi

    local username=$(echo "$line" | cut -d ':' -f 2)
    local encrypted_password=$(echo "$line" | cut -d ':' -f 3)
    local password=$(decrypt_password "$encrypted_password")

    echo "Service: $service"
    echo "Username: $username"
    echo "Password: $password"
}

# Function to update a password
update_password() {
    local service="$1"
    local new_password="$2"

    local line_number=$(grep -n "^$service:" "$PASSWORD_FILE" | cut -d ':' -f 1)

    if [ -z "$line_number" ]; then
        echo "Service not found."
        exit 1
    fi

    local encrypted_password=$(encrypt_password "$new_password")
    sed -i "${line_number}s/.*/$service:$(cut -d ':' -f 2 <<< "$line"):$encrypted_password/" "$PASSWORD_FILE"
    echo "Password updated successfully."
}

# Function to delete a password
delete_password() {
    local service="$1"

    if ! grep -q "^$service:" "$PASSWORD_FILE"; then
        echo "Service not found."
        exit 1
    fi

    grep -v "^$service:" "$PASSWORD_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$PASSWORD_FILE"
    echo "Password deleted successfully."
}

# Main function
main() {
    echo "Password Manager"
    echo "----------------"
    echo "Available commands: add, retrieve, update, delete"

    if [ $# -eq 0 ]; then
        echo "Usage: $0 <command>"
        exit 1
    fi

    local command="$1"
    shift

    case "$command" in
        "add") add_password "$@" ;;
        "retrieve") retrieve_password "$@" ;;
        "update") update_password "$@" ;;
        "delete") delete_password "$@" ;;
        *) echo "Invalid command. Available commands: add, retrieve, update, delete" ;;
    esac
}

# Run main function with arguments passed from command line
main "$@"