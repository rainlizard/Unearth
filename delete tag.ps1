# delete-latest-tag.ps1

# Navigate to the repository
Set-Location "C:\Github\Unearth"

# Get the most recent tag by creation date
$latestTag = git tag --sort=-creatordate | Select-Object -First 1

# Delete the tag if it exists
if ($latestTag) {
    git tag -d $latestTag
    Write-Host "Deleted local tag: $latestTag"
} else {
    Write-Host "No tags found."
}