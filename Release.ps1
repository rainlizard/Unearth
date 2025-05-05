# Read the contents of Autoload/Version.gd
$versionFile = Get-Content -Path "Autoload/Version.gd"

# Extract the major and minor version from the file
$majorMinorVersion = $versionFile | Select-String -Pattern 'var major_minor = "(.+)"' | ForEach-Object { $_.Matches.Groups[1].Value }

# Get the current commit count
$commitCount = git rev-list --count HEAD

# Construct the full version
$fullVersion = "$majorMinorVersion.$commitCount"

# Prompt for changelog
Write-Host "Paste your changelog below for version $fullVersion."
Write-Host "Press Enter on an empty line when finished:"
$changelogLines = @()
while ($true) {
    $line = Read-Host
    # Check if the line is null (Ctrl+Z in console) or empty
    if ($line -eq $null -or [string]::IsNullOrWhiteSpace($line)) {
        break
    }
    $changelogLines += $line
}
$changelog = $changelogLines -join "`n"

# Construct the tag message
# The first line is the title, followed by a blank line, then the body (changelog)
$tagMessage = "Release $fullVersion`n`n$changelog"

# Create the Git tag
# Use -m with the multi-line message. PowerShell should handle passing it correctly.
git tag -a "$fullVersion" -m $tagMessage

# Push the tag to the remote repository
git push origin "$fullVersion"

# Display the message
Write-Host "GitHub Actions are now running. Please wait 5 minutes, and a release will be created on GitHub and itch.io."

# Pause the script execution
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# NOTE: in github desktop click "Pull origin" before running this, in order to be sure the commits count is correct.