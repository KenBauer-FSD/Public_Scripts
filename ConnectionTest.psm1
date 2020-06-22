Function ConnectionTestDown{
    param (
        [Parameter(Mandatory=$true)]$HostName,
        [Parameter(Mandatory=$true)]$To,
        [Parameter(Mandatory=$true)]$From
    )
    $cred = get-credential
    
    DO {
        $successconnectionStatus = Test-Connection -ComputerName $HostName -Quiet
        Start-Sleep -seconds 5}
        while ($successconnectionStatus -eq $True)
                Send-MailMessage -To $To -From $From -Subject "$HostName Connection Down" -Body "The connection to $Hostname is down." -BodyAsHtml -smtpserver smtp.office365.com -usessl -Credential $cred -Port 587
    }
    
    Function ConnectionTestUp{
        param (
            [Parameter(Mandatory=$true)]$HostName,
            [Parameter(Mandatory=$true)]$To,
            [Parameter(Mandatory=$true)]$From
        )
        $cred = get-credential
        
        DO {
            $failedconnectionStatus = Test-Connection -ComputerName $HostName -Quiet
            Start-Sleep -seconds 5}
        while ($failedconnectionStatus -eq $False)
        Send-MailMessage -To $To -From $From -Subject "$HostName Connection Up" -Body "The connection to $Hostname is up." -BodyAsHtml -smtpserver smtp.office365.com -usessl -Credential $cred -Port 587
    }
