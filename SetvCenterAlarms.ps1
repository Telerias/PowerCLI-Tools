## http://www.van-lieshout.com/2012/01/powercli-automation-create-vcenter-notification-email-alarm-action/

# Line 1: The script first retrieves all the alarms. You can easily adapt the script to update only a specific alarms by changing this line to include the name of the alarm you want to update like:
#   Get-AlarmDefinition "Datastore usage on disk"
# or even all datastore alarms with:
#   Get-AlarmDefinition "Datastore*"
# Line 2: The script then configures the alarm action repeat frequency to repeat the action every 24 hours. The value must be specified in minutes and the default value is to repeat every 5 minutes.
#
# Line 3: On this line a new send notification email action is created to send an email to the email address vcenteralarms@customer.corp.
#
# Line 4: This creates an alarm action trigger when the status changes from “Green” to “Yellow” or from “Normal” to “Warning”.
#
# Line 5: During the creation of the send notification email alarm action, a default alarm action trigger is created. Because there’s currently no Set-AlarmActionTrigger cmdlet available, I decided that it’s easier to remove the default trigger rather than trying to change it from “Once” to “Repeat” by falling back to using the SDK methods. I warned you that it was quick and dirty ;-)
# 
# Line 6: finally this line creates an alarm action trigger when the status changes from “Yellow” to “Red” or from “Warning” to “Alert”.

Get-AlarmDefinition | %{
   $_ | Set-AlarmDefinition -ActionRepeatMinutes (60 * 24);
   $_ | New-AlarmAction -Email -To "vcenteralarms@customer.corp" | %{
      $_ | New-AlarmActionTrigger -StartStatus "Green" -EndStatus "Yellow" -Repeat
      $_ | Get-AlarmActionTrigger | ?{$_.repeat -eq $false} | Remove-AlarmActionTrigger -Confirm:$false
      $_ | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Red" -Repeat
   }
}
