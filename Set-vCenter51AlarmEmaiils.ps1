# From http://fixingitpro.com/2012/07/09/powercli-script-to-automatically-setup-vcenter-alarm-email-notification/
# Some notes about the script:
#
# - The $user, $pass and $vCenterServer variables need to be edited to be correct for your environment.
# - This currently sets up email alerts for almost every single default alarm in vCenter (based on 5.0).  This is 
#   undoubtedly overkill and you’ll likely want to remove some from the lists.
# - In the current setup this script takes a while to run through all the alarms.  It took about 10 minutes for me.  
#   But that’s still a lot faster than doing it manually.
# - If you add or remove an alarm from the list make sure the following syntax is maintained:
# -- Alarm names should be in double-quotes (“)
# -- Alarms should be separated by commas (,)
# -- Back-ticks (`) are used to continue a breakup the single line of alarm names into multiple lines for readability.   
#    All alarms should have a back-tick at the end of the line except the last in the array.
# - If you want to add or remove email addresses make sure they too are in double-quotes, separated by commas with no spaces.
# - If you want to change the frequency of the repeating alerts just change the second number in the  “-ActionRepeatMinutes (60 * 24)” section.

$user="administrator"
$pass="Password1"
$vCenterServer="192.168.32.128"


$MailtoAddresses= "email1@email.com","email2@email.com"


#----Connect to the vCenter Server

Connect-VIServer -Server $vCenterServer -Protocol https -User $user -Password $pass -WarningAction SilentlyContinue | Out-Null

$sessionManager = Get-View -Id $global:DefaultVIServer.ExtensionData.Content.SessionManager
$sessionManager.SetLocale(“en-US”)

#----These Alarms will send a single email message and not repeat ----
$LowPriorityAlarms="Timed out starting Secondary VM",`
"No compatible host for Secondary VM",`
"Virtual Machine Fault Tolerance vLockStep interval Status Changed",`
"Migration error",`
"Exit standby error",`
"License error",`
"Virtual machine Fault Tolerance state changed",`
"VMKernel NIC not configured correctly",`
"Unmanaged workload detected on SIOC-enabled datastore",`
"Host IPMI System Event Log status",`
"Host Baseboard Management Controller status",`
"License user threshold monitoring",`
"Datastore capability alarm",`
"Storage DRS recommendation",`
"Storage DRS is not supported on Host.",`
"Datastore is in multiple datacenters",`
"Insufficient vSphere HA failover resources",`
"License capacity monitoring",`
"Pre-4.1 host connected to SIOC-enabled datastore",`
"Virtual machine cpu usage",`
"Virtual machine memory usage",`
"License inventory monitoring"

#----These Alarms will repeat every 24 hours----
$MediumPriorityAlarms=`
"Virtual machine error",`
"Health status changed alarm",`
"Host cpu usage",`
"Health status monitoring",`
"Host memory usage",`
"Cannot find vSphere HA master agent",`
"vSphere HA host status",`
"Host service console swap rates",`
"vSphere HA virtual machine monitoring action",`
"vSphere HA virtual machine monitoring error"


#----These Alarms will repeat every 2 hours----
$HighPriorityAlarms=`
"Host connection and power state",`
"Host processor status",`
"Host memory status",`
"Host hardware fan status",`
"Host hardware voltage",`
"Host hardware temperature status",`
"Host hardware power status",`
"Host hardware system board status",`
"Host battery status",`
"Status of other host hardware objects",`
"Host storage status",`
"Host error",`
"Host connection failure",`
"Cannot connect to storage",`
"Network connectivity lost",`
"Network uplink redundancy lost",`
"Network uplink redundancy degraded",`
"Thin-provisioned volume capacity threshold exceeded.",`
"Datastore cluster is out of space",`
"vSphere HA failover in progress",`
"vSphere HA virtual machine failover failed",`
"Datastore usage on disk"

#---Set Alarm Action for Low Priority Alarms---
Foreach ($LowPriorityAlarm in $LowPriorityAlarms) {
    Get-AlarmDefinition -Name "$LowPriorityAlarm" | Get-AlarmAction -ActionType SendEmail| Remove-AlarmAction -Confirm:$false
    Get-AlarmDefinition -Name "$LowPriorityAlarm" | New-AlarmAction -Email -To @($MailtoAddresses)
    Get-AlarmDefinition -Name "$LowPriorityAlarm" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Green" -EndStatus "Yellow"
    #Get-AlarmDefinition -Name "$LowPriorityAlarm" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Red"  # This ActionTrigger is enabled by default.
    Get-AlarmDefinition -Name "$LowPriorityAlarm" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Red" -EndStatus "Yellow"
    Get-AlarmDefinition -Name "$LowPriorityAlarm" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Green"
}

#---Set Alarm Action for Medium Priority Alarms---
Foreach ($MediumPriorityAlarm in $MediumPriorityAlarms) {
    Get-AlarmDefinition -Name "$MediumPriorityAlarm" | Get-AlarmAction -ActionType SendEmail| Remove-AlarmAction -Confirm:$false
    Set-AlarmDefinition "$MediumPriorityAlarm" -ActionRepeatMinutes (60 * 24) # 24 Hours
    Get-AlarmDefinition -Name "$MediumPriorityAlarm" | New-AlarmAction -Email -To @($MailtoAddresses)
    Get-AlarmDefinition -Name "$MediumPriorityAlarm" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Green" -EndStatus "Yellow"
    Get-AlarmDefinition -Name "$MediumPriorityAlarm" | Get-AlarmAction -ActionType SendEmail | Get-AlarmActionTrigger | Select -First 1 | Remove-AlarmActionTrigger -Confirm:$false
    Get-AlarmDefinition -Name "$MediumPriorityAlarm" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Red" -Repeat
    Get-AlarmDefinition -Name "$MediumPriorityAlarm" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Red" -EndStatus "Yellow"
    Get-AlarmDefinition -Name "$MediumPriorityAlarm" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Green"
}

#---Set Alarm Action for High Priority Alarms---
Foreach ($HighPriorityAlarm in $HighPriorityAlarms) {
    Get-AlarmDefinition -Name "$HighPriorityAlarm" | Get-AlarmAction -ActionType SendEmail| Remove-AlarmAction -Confirm:$false
    Set-AlarmDefinition "$HighPriorityAlarm" -ActionRepeatMinutes (60 * 2) # 2 hours
    Get-AlarmDefinition -Name "$HighPriorityAlarm" | New-AlarmAction -Email -To @($MailtoAddresses)
    Get-AlarmDefinition -Name "$HighPriorityAlarm" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Green" -EndStatus "Yellow"
    Get-AlarmDefinition -Name "$HighPriorityAlarm" | Get-AlarmAction -ActionType SendEmail | Get-AlarmActionTrigger | Select -First 1 | Remove-AlarmActionTrigger -Confirm:$false
    Get-AlarmDefinition -Name "$HighPriorityAlarm" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Red" -Repeat
    Get-AlarmDefinition -Name "$HighPriorityAlarm" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Red" -EndStatus "Yellow"
    Get-AlarmDefinition -Name "$HighPriorityAlarm" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Green"
}

#---Disconnect from vCenter Server----
Disconnect-VIServer -Server $vCenterServer -Force:$true -Confirm:$false
