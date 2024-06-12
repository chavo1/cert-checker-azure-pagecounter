#!/bin/bash

# Function to retrieve the SSL certificate expiration date
get_ssl_expiry_date() {
    local hostname=$1
    # Use openssl to get the certificate details
    local cert_info=$(echo | openssl s_client -servername "$hostname" -connect "$hostname:443" 2>/dev/null | openssl x509 -noout -dates)
    
    if [ $? -ne 0 ]; then
        echo "Failed to retrieve certificate information for $hostname"
        exit 1
    fi

    # Extract the notAfter date
    local expiry_date=$(echo "$cert_info" | grep 'notAfter=' | cut -d= -f2)

    if [ -z "$expiry_date" ]; then
        echo "Could not retrieve the expiration date from the certificate."
        exit 1
    fi

    # Convert the date to a more readable format
    local expiry_date_formatted=$(date -d "$expiry_date" '+%Y-%m-%d %H:%M:%S')

    echo "$expiry_date_formatted"
}

# Main function to display the SSL certificate expiration date
display_expiry_date() {
    local hostname=$1
    echo -n "The SSL/TLS certificate for $hostname expires on: "
    get_ssl_expiry_date "$hostname"
}

# Entry point of the script
main() {
    local hostname="example.com"
    display_expiry_date "$hostname"
}

# Run the main function
main
