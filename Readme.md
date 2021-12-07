# Azure functions
In this repository I will save my functions that I build in some of my projects to help others working with these functions.

## Get IP Addresses
This is a function to extrect IP Adresses from string like ip addresses in mail headers. We find the address without regular expressions, we use the PowerShell language to verify if it is an IPv4 or IPv6 address.

## GetUrls
This function is used to convert Defender for Office "Safelinks" urls back to the url it was before. As input we are accepting a comma separated string.

## Make Zip file
This function can be used to make a zip file from file streams. I use this function in a logic app that get an email from Office 365 mailbox that hat attachments in it. We stream the attachments to this function and get a zip file stream back.