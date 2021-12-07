# GetUrls
This function is used to convert Defender for Office "Safelinks" urls back to the url it was before. As input we are accepting a comma separated string.


Input JSON: `
{
    "Urls": ""
}`

Reponse:
This functions response all urls comma separated and extract the *.protection.outlook.com string and convert thr Uri back to human readebly Uri.