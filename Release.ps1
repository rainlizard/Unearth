# Read the contents of Autoload/Version.gd
$versionFile = Get-Content -Path "Autoload/Version.gd"

# Extract the major and minor version from the file
$majorMinorVersion = $versionFile | Select-String -Pattern 'var major_minor = "(.+)"' | ForEach-Object { $_.Matches.Groups[1].Value }

# Get the current commit count and add 1 for the changelog commit we're about to make
$commitCount = [int](git rev-list --count HEAD) + 1

# Construct the full version (this will be accurate after we commit the changelog)
$fullVersion = "$majorMinorVersion.$commitCount"

# Get current date in d/M/yyyy format
$currentDate = Get-Date -Format "d/M/yyyy"

Write-Host "Reminder: you may want to manually edit Autoload/Version.gd first!"
Write-Host "Reminder: changelog.gd should have <version> - <date> written for the top version, so it can be replaced by this script."
Write-Host "Creating release for version $fullVersion"
Write-Host "Press Enter to continue or Ctrl+C to cancel..."
Read-Host

# Read changelog.gd file
$changelogFile = Get-Content -Path "changelog.gd" -Raw

# Replace placeholders with actual values
$updatedChangelog = $changelogFile -replace '<version>', $fullVersion -replace '<date>', $currentDate

# Write the updated changelog back to the file
$updatedChangelog | Out-File -FilePath "changelog.gd" -Encoding utf8 -NoNewline

# Stage and commit the changelog changes
git add changelog.gd
git commit -m "Update changelog for release $fullVersion"

# Verify the commit count matches our expectation
$actualCommitCount = git rev-list --count HEAD
if ($actualCommitCount -ne $commitCount) {
    Write-Error "Version mismatch! Expected commit count: $commitCount, Actual: $actualCommitCount"
    exit 1
}

Write-Host "Commit successful. Version $fullVersion confirmed."

# Construct the tag message with just the version
$tagMessage = "Release $fullVersion"

# Create the Git tag using a temp file so multiline messages work
$tempFile = New-TemporaryFile
$tagMessage | Out-File -FilePath $tempFile -Encoding utf8
git tag -a "$fullVersion" -F $tempFile
Remove-Item $tempFile

# Push both the commit and the tag to the remote repository
git push origin main "$fullVersion"

# Display the message
Write-Host "GitHub Actions are now running. Please wait 5 minutes, and a release will be created on GitHub and itch.io."

# Pause the script execution
Write-Host "Press Enter to continue..."
Read-Host

# NOTE: in github desktop click "Pull origin" before running this, in order to be sure the commits count is correct.