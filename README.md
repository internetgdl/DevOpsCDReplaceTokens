PowerShell Script to replace the appsettings keys with the enviroments vars defined on the DevOps Release Definition.

We must to create a powershell script.

This Scrill will find the artifact directory and make a while over all artifacts finding and replacing the appsettings.json vars with the value of the variables defined in the release definition with the same name, and leave with not changes the undefined variables.

The Script extract the files in a new temporal folder take the appsettings.json, replace, detele the file and generate a new file, at the end compress a new file and save it deleting the artifact .zip file.

