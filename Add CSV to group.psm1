function Add-CsvToGroup {
<#
.Synopsis
Adds all users listed in provided CSV to specified AD Group   
.EXAMPLE
Add-CSVToGroup -csv c:\temp\users.csv -groupname "All Staff" -reportpath c:\reports\output.csv
.INPUTS
-CSVPath
.OUTPUTS
List of failed users is exported to c:\temp\FailedImport<date>.csv   
.NOTES
FailedImport file that is created can be used for subsequent runs of the script, so you can continue to run against that list to catch missed workstations.
#>
    Param(
            [Parameter(Mandatory=$true)]$CSV,
            [Parameter(Mandatory=$true)]$GroupName,
            [Parameter(Mandatory=$true)]$ReportPath
        )

    $users = Import-Csv $csv -Header "Name"

    foreach ($user in $users){
        $name = $user.Name
        $account= (Get-ADUser -Filter {name -eq $name}).samaccountname
        try{ add-adgroupmember -identity "$GroupName" -Members $account -ErrorAction SilentlyContinue}
        catch {Write-Output "Unable to locate $name"}
}

Get-ADGroupMember -identity “GroupName” | Select-Object name | Export-csv -path $ReportPath -NoTypeInformation
}