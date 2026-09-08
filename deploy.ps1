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
$html = [regex]::Replace($html, '(<meta name="app-version" content=")[^"]*(">)', { param($match) $match.Groups[1].Value + $version + $match.Groups[2].Value })
$html = [regex]::Replace($html, '(<span class="release-version" id="releaseVersion">)[^<]*(</span>)', { param($match) $match.Groups[1].Value + $version + $match.Groups[2].Value })
$html = [regex]::Replace($html, '(?<=href="styles\.css)(?:\?v=[^"]*)?(?=")', "?v=$version")
$html = [regex]::Replace($html, '(?<=src="app\.js)(?:\?v=[^"]*)?(?=")', "?v=$version")
[IO.File]::WriteAllText($indexPath, $html, $utf8)

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
  assets = @("/styles.css?v=$version", "/app.js?v=$version")
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
