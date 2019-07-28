# Enter to folder
cd $(System.DefaultWorkingDirectory)
# loop searching zips with .json configurations

$MainDirectory =Get-ChildItem -Directory | %{$_.Name} | Select-Object -last 1 

cd ($MainDirectory)

$directories =Get-ChildItem -Directory | %{$_.Name} 

$alias = $(Release.PrimaryArtifactSourceAlias)
$artifact = $(Release.Artifacts.$alias.DefinitionName)
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
          cd ($newFolder)
          #Work whit the settings file

          $fileReplace = "appsettings.infra.json"
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
          Get-Content -path $fileReplace
          #ZipEntireFiles
          Compress-Archive -Path ./* -DestinationPath ../$file -Force    
          #End of work with folder
          cd ..     
          Remove-Item $newFolder -Confirm:$false -Force -Recurse
     }

     #Exit of folder
    
}