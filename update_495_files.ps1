#####################
# CySci 495 Fall 2018
# This is a script Capt McMinn runs to copy over course files automagically from the NAS
# This is run as a scheduled task service
# please don't kill it
# or use it to propagate malware
# (dank memes okay)
# This script shouldn't run after late Dec 2018
# there should be a bit of a random delay between each pull so the 
# script doesn't DDOS the NAS (less than 20 compys should be fine anyway)
# LLAP \\//
#####################
# map the course folder
If (-not (Test-Path "W:\"))
{
    $net = new-object -ComObject WScript.Network
    $net.MapNetworkDrive("W:", "\\10.0.0.40\fs-40\60-COURSES\CS 333\Fall 2018\push", $false, "student", "CyberRange")
}

# create folder on Desktop if it does not exist
$path= Resolve-Path "~\Desktop\CyS438_push"
$path = $path.path

$dropbox_path = "W:\dropbox"
$script_path = "W:\run"

If (-not (Test-Path $path))
{
	mkdir $path
}

# TODO I could probably do this with ansible if I had VMs...
## tasks:
# copy over the dropbox to the local push folder
# robocopy should automatically 
$source = $dropbox_path
$destination = $path

$copyoptions = "/MIR" # mirror the source tree
$command = "robocopy `"$($source)`" $($destination) $copyOptions"
$output = Invoke-Expression $command


# run all of the scripts in the run directory with CMD
# use cmd to get around the script execution prevention
Get-ChildItem $script_path | ForEach-Object {
  & $_.FullName
}
