param(
    [Parameter(Mandatory)]
    [string]$Version
)

$ErrorActionPreference = "Stop"

$changelog = (
    Invoke-WebRequest "https://raw.githubusercontent.com/aws/aws-cli/v2/CHANGELOG.rst"
).Content

$notes = Join-Path $env:RUNNER_TEMP "aws-cli-$Version.md"

(
    [regex]::Match(
        $changelog,
        "(?ms)^$([regex]::Escape($Version))`r?`n=+.*?(?=^\d+\.\d+\.\d+`r?$|\z)"
    )
).Value |
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
    --title "AWS CLI Portable $Version" `
    --notes-file $notes

git tag "v$Version"
git push origin "v$Version"
