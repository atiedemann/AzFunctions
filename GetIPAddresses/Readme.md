# Get IP addresses from string
This is a function to extrect IP Adresses from string like ip addresses in mail headers. We find the address without regular expressions, we use the PowerShell language to verify if it is an IPv4 or IPv6 address.

Input JSON:
`{
    "Name": "<String>"
}`

If this function cannot find an ip address we will repond with this status:

`{ "Status": "failed" }`