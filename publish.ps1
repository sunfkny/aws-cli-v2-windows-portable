param(
    [Parameter(Mandatory)]
    [string]$Version
)

$ErrorActionPreference = "Stop"

$changelog = (
    Invoke-WebRequest "https://raw.githubusercontent.com/aws/aws-cli/v2/CHANGELOG.rst"
).Content

$notes = Join-Path $env:RUNNER_TEMP "aws-cli-$Version.md"
$escapedVersion = [regex]::Escape($Version)
$match = [regex]::Match(
    $changelog,
    "(?ms)^$escapedVersion`r?`n=+`r?`n(?<Notes>.*?)(?=^\d+\.\d+\.\d+`r?`n=+`r?$|\z)"
)

if (-not $match.Success) {
    throw "Version $Version was not found in the AWS CLI changelog"
}

$match.Groups["Notes"].Value.Trim() |
    Set-Content `
    $notes `
    -Encoding utf8

$archive =
    Join-Path `
    (Resolve-Path dist) `
    "aws-cli-v2-windows-portable-$Version.7z"

gh release create `
    "v$Version" `
    $archive `
    --title "$Version" `
    --notes-file $notes

git tag "v$Version"
git push origin "v$Version"
