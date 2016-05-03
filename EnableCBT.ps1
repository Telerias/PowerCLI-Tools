# See VMware KB # 1031873
# You can use these PowerCLI commands to disable and then enable CBT without powering off the virtual machine. 
# This can be useful when one or more of the disks of the virtual machine is extended past a 128Gb boundary. 
# See QueryChangedDiskAreas API returns incorrect sectors after extending virtual machine VMDK file with Changed Block 
# Tracking (CBT) enabled (2090639). You can comment out the enable or disable commands in the script when appropriate for other uses

$vm="VM_Name"

$vmtest = Get-vm $vm| get-view
$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec

## disable ctk
# $vmConfigSpec.changeTrackingEnabled = $false
# $vmtest.reconfigVM($vmConfigSpec)
# $snap=New-Snapshot $vm -Name "Disable CBT"
# $snap | Remove-Snapshot -confirm:$false

# enable ctk
$vmConfigSpec.changeTrackingEnabled = $true
$vmtest.reconfigVM($vmConfigSpec)
$snap=New-Snapshot $vm -Name "Enable CBT"
$snap | Remove-Snapshot -confirm:$false
