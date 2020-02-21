# chkdomains

Provides you with which domains are pointing to your server's IP addresses
and which domains are pointing to remote IPs.

It is important to note the following:

	- The script does not report proxy services like CloudFlare, Sucuri, etc.
	- The script is configured to use Google's nameservers as it is not meant to troubleshoot DNS issues, IE bad resolution.
	- The script should work with cPanel NAT 1:1 servers, however, a badly configured NAT will produce unreliable data.

## Usage

```chkdomains

Simply run the following command as root:

	- /usr/local/cpanel/3rdparty/bin/perl <(curl -s https://raw.githubusercontent.com/rmcdougal/chkdomains/master/chkdomains.pl)

```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
Please make sure to update tests as appropriate.

## License

This is free software: you are free to change and redistribute it.  There is NO WARRANTY, to the extent permitted by law.
https://www.gnu.org/licenses/gpl-3.0.txt
