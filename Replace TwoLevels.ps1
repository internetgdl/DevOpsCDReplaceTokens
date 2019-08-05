$fileReplace = "./appsettings.infra.json"
function GetJsonMembers($fooString) {

    $fooJson = $fooString | ConvertFrom-Json 
    $objMembers = $fooJson.psobject.Members | where-object membertype -like 'noteproperty'  

    if ($objMembers -is [System.array])
    {
        foreach ( $submember in $objMembers ) {
            if ($submember.Value -is [System.Management.Automation.PSCustomObject]){
                GetJsonMembers($submember.Value | ConvertTo-Json)
            } else {
                $submember.Value
            }
        }
    } 
}
 $foo = (Get-Content $fileReplace) -replace '^\s*//.*'| Out-String  
 GetJsonMembers($foo)