## Replace Tokens on Continuos Delivery Definition in Microsoft DevOps

**Description**

PowerShell Script to replace the appsettings keys with the environment vars defined on the DevOps Release Definition.

We must to create a PowerShell script.

This Script will find the artifact directory and make a while over all artifacts finding and replacing the appsettings.json vars with the value of the variables defined in the release definition with the same name, and leave with not changes the undefined variables.

The Script extract the files in a new temporal folder take the appsettings.json, replace, delete the file and generate a new file, at the end compress a new file and save it deleting the artifact .zip file.

**Background**

In case of Windows WebApp in Microsoft DevOps Release or Build Definition Azure Implementing we have and option to replace the appsettings.json for the Dot Net Core WebApps for the variables defined in the stage variables set, in the case of Linux WebApp we don't have this option.

Windows WebApp

![Windows WebApp in Azure DevOps Definition](http://eduardo.mx/wp-content/uploads/2019/07/image-5.png)

Linux WebApp.
![Linux WebApp in Azure DevOps Definition](http://eduardo.mx/wp-content/uploads/2019/07/image-6.png)


I created this script in the we can expand a zip to get the appsettings.json replace with the vars of the environment replace the file and zip the entire content crating the new artifact for the azure implementation.

  

[eduardo.mx](http://eduardo.mx/2019/07/28/replace-tokens-on-continous-delivery-defintion-in-microsoft-devops-description/)
