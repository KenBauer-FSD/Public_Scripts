Function ConnectionTest{
    param (
        [Parameter(Mandatory=$true)]
            $HostName,
            $To,
            $From,
        [Parameter(Mandatory=$false)]
            [Switch]$Down,
            [Switch]$Up
    )
    $cred = get-credential
    
    if($Down -eq $true -and $Up -eq $false){
        DO {
            $successconnectionStatus = Test-Connection -ComputerName $HostName -Quiet
            Start-Sleep -Seconds 300}
            while ($successconnectionStatus -eq $True)
                Send-MailMessage -To $To -From $From -Subject "$HostName Connection Down" -Body "The connection to $Hostname is down." -BodyAsHtml -smtpserver smtp.office365.com -usessl -Credential $cred -Port 587
        }         
    elseif ($Up -eq $true -AND $Down -eq $false) {
        DO {
            $failedconnectionStatus = Test-Connection -ComputerName $HostName -Quiet
            Start-Sleep -seconds 300}
        while ($failedconnectionStatus -eq $False)
        Send-MailMessage -To $To -From $From -Subject "$HostName Connection Up" -Body "The connection to $Hostname is up." -BodyAsHtml -smtpserver smtp.office365.com -usessl -Credential $cred -Port 587
    }
    else {
        Write-Error -Message "Error: -Down or -Up specified improperly."
    }
    }
    