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

# NOTE: in github desktop click "Pull origin" before running this, in order to be sure the commits count is correct.