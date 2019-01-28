I didn't want pre-determine vCloud Director API Rest Calls. So i started to create this wrapper so I could leverage endpoints easily and create JSON/XML as body; to keep all api changes as version control as possible. I leverage the about_page demo to test my wrapper.

There is two ways to Login.
Either leverage the New-vCDLogin with all the parameters or leverage just the URI and PATH. Where path is the location of said parameters. You will find an example file for it here as well.


aboutpage.json and aboutpageESF.json are two body file needed to POST API calls for uploading extension into vcloud director
