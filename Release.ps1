# Read the contents of Autoload/Version.gd
$versionFile = Get-Content -Path "Autoload/Version.gd"

# Extract the major and minor version from the file
$majorMinorVersion = $versionFile | Select-String -Pattern 'var major_minor = "(.+)"' | ForEach-Object { $_.Matches.Groups[1].Value }

# Get the current commit count
$commitCount = git rev-list --count HEAD

# Construct the full version
$fullVersion = "$majorMinorVersion.$commitCount"

# Create the Git tag
git tag -a "$fullVersion" -m "Release $fullVersion"

# Push the tag to the remote repository
git push origin "$fullVersion"

# Display the message
Write-Host "GitHub Actions are now running. Please wait 5 minutes, and a release will be created on GitHub and itch.io."

# Pause the script execution
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# NOTE: in github desktop click "Pull origin" before running this, in order to be sure the commits count is correct.