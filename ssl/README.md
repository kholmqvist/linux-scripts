## check-certificates.sh
- Retrieves the SSL certificate for the specified domain and calculates how many days are left until it expires.

### Usage:

#### Check port 443 on example.com
./check-certificate -d example.com

#### Check custom port on example.com
./check-certificate -d example.com -p 1234
