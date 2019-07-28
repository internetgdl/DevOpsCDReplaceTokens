Write-Host "Replace Tokens"

#settings FileName
$appsettingsName = "appsettings.infra.json"
# Enter to folder
cd $(System.DefaultWorkingDirectory)
# loop searching zips with .json configurations

$MainDirectory =Get-ChildItem -Directory | %{$_.Name} | Select-Object -last 1 

cd ($MainDirectory)

$directories =Get-ChildItem -Directory | %{$_.Name} 

foreach($directory in $directories) 
{ 
     cd ($directory)
     #loop into a directory to 
     $files =Get-ChildItem -Recurse -File -Include *.zip | %{$_.Name}
     foreach($file in $files) {
         
          $newFolder = $file.Replace(".zip","").Replace(".","-")

          mkdir ($newFolder)
          #Unzip All files
          Expand-Archive -Path $file -DestinationPath $newFolder
          #cd ($newFolder)
          #Work whit the settings file

          $fileReplace = $newFolder+"/"+$appsettingsName
          $foo = Get-Content -Raw -Path $fileReplace | ConvertFrom-Json

          $objMembers = $foo.psobject.Members | where-object membertype -like 'noteproperty'   
          foreach ( $member in $objMembers ) { 
            $tmpVal = gci env: | where name -eq $member.name
            if (-not ([string]::IsNullOrEmpty($tmpVal)))
            {
                $member.Value = $tmpVal
            }
          }

          Remove-Item –path $fileReplace
          $foo | ConvertTo-Json | Out-File $fileReplace
          Compress-Archive -Path $fileReplace -Update -DestinationPath $file
          Get-Content -path $fileReplace
          #cd ..     
          Remove-Item $newFolder -Confirm:$false -Force -Recurse
     }

     #Exit of folder
    
}
Write-Host "End of Replace Tokens"
