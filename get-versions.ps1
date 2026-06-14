$ErrorActionPreference = "Stop"

$startVersion = "2.35.4"

$localVersions =
    [System.Collections.Generic.HashSet[string]]::new()

git tag | ForEach-Object {
    $localVersions.Add($_.TrimStart("v")) | Out-Null
}

$changelog = (
    Invoke-WebRequest "https://raw.githubusercontent.com/aws/aws-cli/v2/CHANGELOG.rst"
).Content

$remoteVersions =
    [regex]::Matches(
        $changelog,
        '(?m)^(\d+\.\d+\.\d+)$'
    ) |
    ForEach-Object {
        $_.Groups[1].Value
    }

[array]::Reverse($remoteVersions)

$startIndex = $remoteVersions.IndexOf($startVersion)

if ($startIndex -lt 0) {
    throw "Start version not found: $startVersion"
}

$remoteVersions =
    $remoteVersions[
        $startIndex..($remoteVersions.Count - 1)
    ]

$todo =
    $remoteVersions |
    Where-Object {
        -not $localVersions.Contains($_)
    }

$todo | ConvertTo-Json
