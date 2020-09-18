param(
    [Switch]$Delete=$false
)
#region Variables
$DaysInactive = 182
$DaysDelete = 365
$InactiveDate = (Get-Date).Adddays(-($DaysInactive))
$DeleteDate = (Get-Date).AddDays(-($DaysDelete))
$InactivePath ='c:\scripts\InactiveComputers.csv'
$DeletePath = 'c:\scripts\DeletedComputers.csv'
$DisabledOU = 'XXXXXXX'
$SearchBase ='XXXXXXX'
# Mail Variables
$SMTPServer = 'XXXXXXX'
$port = '25'
$from = 'Robot <robot@contoso.com>'
$to = 'Human <human@contoso.com>'
$subject = 'Inactive Workstation Cleanup'
#If -Delete is specified than includes the delete file in the $attachments variable, otherwise only the Inactive report is included.
if($Delete){$attachments = @($InactivePath,$DeletePath)}
else{$attachments = $InactivePath}
$body = 'See attached'
#endregion

#region Find
#$InactiveComputers finds all computer accounts older than $InactiveDate that don't match Windows Server Operating systems, or are not in a SERVER OU and are not disabled.
#If -Delete is specified DeleteComputers finds all computer accounts older than $DeleteDate but only looks for disabled accounts in the DisabledComputers OU.
$inactiveComputers = Search-ADAccount -AccountInactive -DateTime $InactiveDate -ComputersOnly -searchbase $SearchBase |Where-Object {$PSItem.operatingsystem -notlike '*windows*server*'}|Where-Object{$PSItem.distinguishedname -notlike '*server*'} |Where-Object{$PSItem.enabled -eq $true} |Select-Object Name, LastLogonDate, DistinguishedName
if($Delete){$deleteComputers = Search-ADAccount -AccountInactive -DateTime $DeleteDate -ComputersOnly -searchbase $DisabledOU |Where-Object{$PSItem.enabled -eq $false} |Select-Object Name, LastLogonDate, DistinguishedName}
#endregion

#region Report
# Deletes the old report files, then dumps the contents of $InactiveComputers and $DeleteComputers to their respective report paths. 
# If -delete was specified, will also report on the Deleted Computers.
Remove-Item C:\scripts\InactiveComputers.csv
if($Delete){Remove-Item C:\scripts\DeletedComputers.csv}
$InactiveComputers | Export-Csv -Append $InactivePath -NoTypeInformation
if($Delete){$deleteComputers | Export-Csv -Append $DeletePath -NoTypeInformation}
#endregion

#region Move
#Disable and move inactive computers to new OU
foreach ($Computer in $InactiveComputers) {
    Set-ADComputer -Enabled $false -Identity $Computer.DistinguishedName
    Write-Host "Disabling and moving" $Computer.Name
    Move-ADObject -Identity $Computer.DistinguishedName -TargetPath $DisabledOU
    }
#endregion

#region Delete
#Delete computers that have been inactive longer than $DaysDelete if the $delete flag was specified on run
if($Delete){
    foreach ($Computer in $deleteComputers){
        Write-Host "Deleting" $Computer.Name
        Remove-ADObject -Identity $Computer.DistinguishedName
    }
}
#endregion

Send-MailMessage -SmtpServer $SMTPServer -Port $port -usessl -From $from -to $to -subject $subject -attachments $attachments -Body $body -BodyAsHtml
