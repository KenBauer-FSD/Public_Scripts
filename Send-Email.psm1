
function Send_email {
    param (
        [Parameter(Mandatory=$true)]$To,
        [Parameter(Mandatory=$true)]$From,
        [Parameter]$Subject,
        [Parameter]$body
    )
    Send-MailMessage -To $To -From $From -Subject $Subject -Body $body -BodyAsHtml -smtpserver smtp.office365.com -usessl -Credential $cred -Port 587

    
}