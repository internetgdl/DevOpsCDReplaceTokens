Write-Host "Start of Replace Tokens"
if ([Environment]::GetEnvironmentVariable('VSTS_SECRET_VARIABLES'))
{
     $secretVariablesString = gci env:VSTS_SECRET_VARIABLES
     $secretVariablesString = $secretVariablesString.Value.replace("[", "").replace("]", "").replace('"', "");
     $secretVariables = $secretVariablesString.split(",")
}

#settings FileName
$appsettingsName = "appsettings.infra.json"

#Function

function GetJsonMembers($fooJson) {
   # $fooJson = $fooJson | ConvertFrom-Json 
    $objMembers = $fooJson.psobject.Members | where-object membertype -like 'noteproperty'  
    if ($objMembers -is [System.array]) {
        foreach ( $member in $objMembers ) {
            if ($member.Value -is [System.Management.Automation.PSCustomObject]) {
                $member.Value = GetJsonMembers($member.Value)
            }
            else {
                $tmpVal = gci env: | where name -eq $member.name
                if (-not ([string]::IsNullOrEmpty($tmpVal))) {
                    $member.Value = $tmpVal.Value
                }
                else {
                    $match = $secretVariables -match ($member.name) 
                    if ($match) {
                        $secretVariableRef = gci env:"secret_"$match
                    }
                }
            }
        }
    } 
    return $fooJson
}

# Enter to folder

#cd $(System.DefaultWorkingDirectory)
#Write-Host $(System.DefaultWorkingDirectory)

$MainDirectory = Get-ChildItem -Directory | % { $_.Name } | Select-Object -last 1 
Write-Host  $MainDirectory
cd ($MainDirectory)

# loop searching zips with .json configurations
$directories = @()
$directories += Get-ChildItem -Directory | % { $_.Name }  
Write-Host $directories

foreach ($directory in $directories) { 
    #$localdirectory = ($MainDirectory+"/"+$directory)
    cd ($directory)
    #loop into a directory to 
    $files = Get-ChildItem -Recurse -File -Include *.zip | % { $_.Name }
    Write-Host "files: "
    Write-Host $files
    foreach ($file in $files) {
         
        $newFolder = $file.Replace(".zip", "").Replace(".", "-")

        mkdir ($newFolder)
        #Unzip All files
        Expand-Archive -Path $file -DestinationPath $newFolder
        
        #Work whit the settings file
        $fileReplace = ("./" + $newFolder + "/" + $appsettingsName)
        Write-Host "before replace:"
        Write-Host $fileReplace

        Get-ChildItem -Path $fileReplace | 
        ForEach-Object -Process {
        try {
            $foo = ((Get-Content -Path $fileReplace) -replace '^\s*//.*' | Out-String | ConvertFrom-Json )  
            $fooJson = GetJsonMembers($foo)
            Remove-Item –path $fileReplace
            $fooJson | ConvertTo-Json | Out-File $fileReplace
            Compress-Archive -Path $fileReplace -Update -DestinationPath $file
            Remove-Item $newFolder -Confirm:$false -Force -Recurse
        } catch {
            write-host "can't convert file '$fileReplace' to JSON"
        }
    } | Group-Object message -NoElement

        
    }

} 
Write-Host "End of Replace Tokens"
