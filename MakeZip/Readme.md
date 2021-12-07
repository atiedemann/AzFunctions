# Make Zip file
This function can be used to make a zip file from file streams. I use this function in a logic app that get an email from Office 365 mailbox that hat attachments in it. We stream the attachments to this function and get a zip file stream back.

Input JSON:
`[
    {
      "contentBytes": "xxxyyyvvv",
      "contentType": "image/png",
      "name": "image001.png"
    }
]`

The response is in JSON format and looks like this:
`{
    "ContentBytes": "",
    "Hashes": = {
        "Algorithm": "",
        "FileName": "",
        "Hash"" ""
    },
    "Status": "Success"
}`