# Get the current path of the script
$currentPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Get the current system PATH variable
$systemPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")

# Check if the current path already exists in the system PATH
if ($systemPath -split ";" -contains $currentPath) {
    Write-Host "The current path is already in the system PATH."
}
else {
    # Append the current path to the system PATH variable
    $newPath = "$systemPath;$currentPath"

    # Set the updated system PATH variable
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
    Write-Host "The current path has been added to the system PATH."
}
