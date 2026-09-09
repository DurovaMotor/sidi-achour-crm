$project = 'sidi-achour-crm'
$branch = 'main'
$now = [DateTimeOffset]::UtcNow
$version = $now.ToString("'v'yyyy.MM.dd.HHmmss.fff") + '-' + [Guid]::NewGuid().ToString('N').Substring(0, 8).ToUpperInvariant()
$hashBytes = [Text.Encoding]::UTF8.GetBytes($version)
$releaseHash = [Convert]::ToHexString([Security.Cryptography.SHA1]::HashData($hashBytes)).ToLowerInvariant()
$message = "Release $version"
$utf8 = [Text.UTF8Encoding]::new($false)

$indexPath = Join-Path $PSScriptRoot 'public\index.html'
$html = [IO.File]::ReadAllText($indexPath)
$previousAssetNames = [regex]::Matches($html, '/build/(?<name>(?:app|styles)\.[0-9a-f]{16}\.(?:js|css))') | ForEach-Object { $_.Groups['name'].Value }
$buildDirectory = Join-Path $PSScriptRoot 'public\build'
New-Item -ItemType Directory -Path $buildDirectory -Force | Out-Null
$styleSource = Join-Path $PSScriptRoot 'public\styles.css'
$appSource = Join-Path $PSScriptRoot 'public\app.js'
$styleHash = (Get-FileHash -LiteralPath $styleSource -Algorithm SHA256).Hash.Substring(0, 16).ToLowerInvariant()
$appHash = (Get-FileHash -LiteralPath $appSource -Algorithm SHA256).Hash.Substring(0, 16).ToLowerInvariant()
$styleName = "styles.$styleHash.css"
$appName = "app.$appHash.js"
$styleUrl = "/build/$styleName"
$appUrl = "/build/$appName"
[IO.File]::WriteAllBytes((Join-Path $buildDirectory $styleName), [IO.File]::ReadAllBytes($styleSource))
[IO.File]::WriteAllBytes((Join-Path $buildDirectory $appName), [IO.File]::ReadAllBytes($appSource))
$keepAssetNames = @($styleName, $appName) + $previousAssetNames
Get-ChildItem -LiteralPath $buildDirectory -File | Where-Object { $_.Name -match '^(?:app|styles)\.[0-9a-f]{16}\.(?:js|css)$' -and $_.Name -notin $keepAssetNames } | ForEach-Object { Remove-Item -LiteralPath $_.FullName }
$html = [regex]::Replace($html, '(<meta name="app-version" content=")[^"]*(">)', { param($match) $match.Groups[1].Value + $version + $match.Groups[2].Value })
$html = [regex]::Replace($html, '(<span class="release-version" id="releaseVersion">)[^<]*(</span>)', { param($match) $match.Groups[1].Value + $version + $match.Groups[2].Value })
$html = [regex]::Replace($html, '(<link rel="stylesheet" href=")[^"]*styles(?:\.[0-9a-f]{16})?\.css(?:\?v=[^"]*)?(">)', { param($match) $match.Groups[1].Value + $styleUrl + $match.Groups[2].Value })
$html = [regex]::Replace($html, '(<script src=")[^"]*app(?:\.[0-9a-f]{16})?\.js(?:\?v=[^"]*)?(" defer></script>)', { param($match) $match.Groups[1].Value + $appUrl + $match.Groups[2].Value })
[IO.File]::WriteAllText($indexPath, $html, $utf8)
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'public\Adam.html'), $html, $utf8)
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'public\Sidi.html'), $html, $utf8)

$manifest = [ordered]@{
  schemaVersion = 1
  version = $version
  releasedAt = $now.ToString('o')
  cloudflare = [ordered]@{
    project = $project
    branch = $branch
    commitHash = $releaseHash
    commitMessage = $message
  }
  assets = @($styleUrl, $appUrl)
  fingerprints = [ordered]@{ css = $styleHash; js = $appHash }
}
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'public\version.json'), ($manifest | ConvertTo-Json -Depth 4), $utf8)

$outputPath = Join-Path ([IO.Path]::GetTempPath()) ("wrangler-pages-{0}.ndjson" -f [Guid]::NewGuid().ToString('N'))
$env:WRANGLER_OUTPUT_FILE_PATH = $outputPath
& npx.cmd --yes wrangler@4.129.1 pages deploy public --project-name $project --branch $branch --commit-hash $releaseHash --commit-message $message --commit-dirty=true
$deployment = Get-Content -LiteralPath $outputPath | ForEach-Object { $_ | ConvertFrom-Json } | Where-Object type -eq 'pages-deploy-detailed' | Select-Object -Last 1

$historyDirectory = Join-Path $PSScriptRoot 'deployment-history'
New-Item -ItemType Directory -Path $historyDirectory -Force | Out-Null
$history = [ordered]@{
  version = $version
  commitHash = $releaseHash
  commitMessage = $message
  deploymentId = $deployment.deployment_id
  url = $deployment.url
  environment = $deployment.environment
  productionBranch = $deployment.production_branch
  releasedAt = $now.ToString('o')
}
[IO.File]::WriteAllText((Join-Path $historyDirectory "$version.json"), ($history | ConvertTo-Json -Depth 4), $utf8)
Remove-Item -LiteralPath $outputPath
$history | ConvertTo-Json -Depth 4
