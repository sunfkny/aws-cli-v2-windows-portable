param(
    [Parameter(Mandatory)]
    [string]$Version
)

$ErrorActionPreference = "Stop"

$work = Join-Path ([System.IO.Path]::GetTempPath()) "aws-cli-$Version"

$msi = Join-Path $work "AWSCLIV2.msi"
$extractDir = Join-Path $work "extract"

Remove-Item $work -Recurse -Force -ErrorAction Ignore

New-Item $extractDir `
    -ItemType Directory `
    -Force | Out-Null

Invoke-WebRequest `
    "https://awscli.amazonaws.com/AWSCLIV2-$Version.msi" `
    -OutFile $msi

Start-Process `
    msiexec `
    -ArgumentList @(
        "/a"
        $msi
        "/qn"
        "TARGETDIR=$extractDir"
    ) `
    -Wait `
    -NoNewWindow

New-Item dist `
    -ItemType Directory `
    -Force | Out-Null

$awsCliDir = Join-Path $extractDir "Amazon\AWSCLIV2"

if (-not (Test-Path $awsCliDir)) {
    throw "Expected directory not found: $awsCliDir"
}

$archive =
    Join-Path `
    (Resolve-Path dist) `
    "aws-cli-v2-windows-portable-$Version.7z"

if (Test-Path $archive) {
    Remove-Item $archive -Force
}

& 7z a `
    $archive `
    "$awsCliDir\*"

if ($LASTEXITCODE -ne 0) {
    throw "7z failed"
}

Remove-Item `
    $work `
    -Recurse `
    -Force

$archive
