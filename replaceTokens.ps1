Write - Host "Start of Replace Tokens"
$secretVariablesString = gci env: VSTS_SECRET_VARIABLES
$secretVariablesString = $secretVariablesString.Value.replace("[", "").replace("]", "").replace('"', "");
$secretVariables = $secretVariablesString.split(",")

# settings FileName
$appsettingsName = "appsettings.infra.json"

# Enter to folder

cd $(System.DefaultWorkingDirectory)
Write - Host $(System.DefaultWorkingDirectory)
$MainDirectory = Get - ChildItem - Directory | % {
    $_.Name
} | Select - Object - last 1
Write - Host $MainDirectory
cd($MainDirectory)

# loop searching zips with.json configurations
$directories = @()
$directories += Get - ChildItem - Directory | % {
    $_.Name
}
Write - Host $directories

foreach($directory in $directories) {
    #
    $localdirectory = ($MainDirectory + "/" + $directory)
    cd($directory)# loop into a directory to
    $files = Get - ChildItem - Recurse - File - Include * .zip | % {
        $_.Name
    }
    Write - Host "files: "
    Write - Host $files
    foreach($file in $files) {

        $newFolder = $file.Replace(".zip", "").Replace(".", "-")

        mkdir($newFolder)# Unzip All files
        Expand - Archive - Path $file - DestinationPath $newFolder# Work whit the settings file

        $fileReplacetmp = ("./" + $newFolder + "/tmp" + $appsettingsName)
        $fileReplace = ("./" + $newFolder + "/" + $appsettingsName)
        Write - Host "before replace:"
        Write - Host $fileReplace

        $foo = (Get - Content $fileReplace) - replace '^\s*//.*' | Out - String | ConvertFrom - Json
        $objMembers = $foo.psobject.Members | where - object membertype - like 'noteproperty'
        foreach($member in $objMembers) {

            $tmpVal = gci env: | where name - eq $member.name

            if (-not([string]::IsNullOrEmpty($tmpVal))) {

                $member.Value = $tmpVal.Value

            } else {

                $match = $secretVariables - match($member.name)
                if ($match) {
                    $secretVariableRef = gci env: "secret_"
                }
            }
        }
        Remove - Item– path $fileReplace
        $foo | ConvertTo - Json | Out - File $fileReplace
        Compress - Archive - Path $fileReplace - Update - DestinationPath $file
        Remove - Item $newFolder - Confirm: $false - Force - Recurse
    }

}
Write - Host "End of Replace Tokens"