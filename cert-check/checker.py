import ssl
import socket
from datetime import datetime

def get_ssl_expiry_date(hostname):
    """
    Establishes a secure connection to the given hostname and retrieves the SSL certificate.
    Parses the certificate to extract and return the expiration date.

    Args:
    hostname (str): The domain name of the website to check.

    Returns:
    datetime: The expiration date of the SSL certificate.

    Raises:
    Exception: If there is an issue with the connection or retrieving the certificate.
    """
    try:
        # Create a default SSL context
        context = ssl.create_default_context()
        # Establish a connection to the hostname on port 443
        with context.wrap_socket(socket.socket(socket.AF_INET), server_hostname=hostname) as conn:
            # Set a timeout for the connection
            conn.settimeout(10.0)
            conn.connect((hostname, 443))
            # Retrieve the certificate
            ssl_info = conn.getpeercert()
            # Extract the 'notAfter' field which contains the expiration date
            expiry_date_str = ssl_info.get('notAfter')
            if not expiry_date_str:
                raise ValueError("Could not retrieve the 'notAfter' field from the certificate.")
            # Convert the date string to a datetime object
            expiry_date = datetime.strptime(expiry_date_str, '%b %d %H:%M:%S %Y %Z')
            return expiry_date
    except (ssl.SSLError, socket.error) as e:
        raise Exception(f"Failed to connect to {hostname}: {e}")
    except ValueError as e:
        raise Exception(f"Error parsing certificate data: {e}")

def display_expiry_date(hostname):
    """
    Fetches and displays the SSL certificate expiration date for the specified hostname.

    Args:
    hostname (str): The domain name of the website to check.
    """
    try:
        expiry_date = get_ssl_expiry_date(hostname)
        print(f"The SSL/TLS certificate for {hostname} expires on {expiry_date.strftime('%Y-%m-%d %H:%M:%S')}")
    except Exception as e:
        print(f"Error: {e}")

def main():
    """
    Main function to check the SSL certificate expiration date for a given hostname.
    """
    hostname = 'example.com'
    display_expiry_date(hostname)

if __name__ == "__main__":
    main()
