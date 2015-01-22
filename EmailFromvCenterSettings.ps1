# From http://rvdnieuwendijk.com/2011/11/19/how-to-use-the-vcenter-server-settings-from-powercli-to-send-e-mail/
#  The following PowerCLI script shows you how to retrieve the mail.sender and mail.smtp.server values from the vCenter Server 
#  Settings. And it uses the Send-MailMessage cmdlet to send you an overview of all your virtual machines.
#
$vCenterSettings = Get-View -Id 'OptionManager-VpxSettings'
$MailSender = ($vCenterSettings.Setting | Where-Object { $_.Key -eq "mail.sender"}).Value
$MailSmtpServer = ($vCenterSettings.Setting | Where-Object { $_.Key -eq "mail.smtp.server"}).Value
 
$Report = Get-VM | Sort-Object -Property Name | Out-String
Send-MailMessage -from $MailSender -to "you@yourdomain.com" -subject "Sending the vSphere report" -body $Report -smtpServer $MailSmtpServer
