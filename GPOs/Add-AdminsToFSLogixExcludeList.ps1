# Group names
$fsLogixGroup = "FSLogix Profile Exclude List"
$adminGroup = "Administrators"

# Check if the FSLogix Profile Exclude List group exists
$fsLogixGroupExists = Get-LocalGroup -Name $fsLogixGroup -ErrorAction SilentlyContinue

if ($fsLogixGroupExists) {
    # Get all members of the local Administrators group
    $adminGroupMembers = Get-LocalGroupMember -Group $adminGroup

    foreach ($admin in $adminGroupMembers) {
        try {
            # Add each member of the Administrators group to the FSLogix Profile Exclude List group
            Add-LocalGroupMember -Group $fsLogixGroup -Member $admin.Name
            Write-Host "User $($admin.Name) has been added to the '$fsLogixGroup' group."
        } catch {
            Write-Host "Error adding $($admin.Name) to the '$fsLogixGroup' group: $_"
        }
    }
} else {
    Write-Host "The group '$fsLogixGroup' does not exist on this computer."
}
