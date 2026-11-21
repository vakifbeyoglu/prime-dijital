# Prime Dijital Çözümler: müşteri sitesini kalıcı linkle yayınlar (GitHub Pages, ücretsiz).
# Kullanım:  .\yayinla.ps1 -Kaynak "C:\yol\site-klasoru-veya-index.html" -Ad "sariyer-kombi"
# Sonuç:     https://<github-kullanici>.github.io/<repo>/<Ad>/
# Her müşteri bu depoda kendi klasöründe durur; arama motorlarına kapalıdır (noindex + robots.txt).
param(
  [Parameter(Mandatory)][string]$Kaynak,
  [Parameter(Mandatory)][string]$Ad
)
$ErrorActionPreference = "Stop"
$repo = $PSScriptRoot
if ($Ad -notmatch '^[a-z0-9-]+$') { throw "Ad yalnız küçük harf, rakam ve tire içermeli (ör. sariyer-kombi)." }
$hedef = Join-Path $repo $Ad
New-Item -ItemType Directory -Force $hedef | Out-Null

if (Test-Path $Kaynak -PathType Leaf) { Copy-Item $Kaynak (Join-Path $hedef "index.html") -Force }
else { Copy-Item (Join-Path $Kaynak "*") $hedef -Recurse -Force }

# Arama motorlarına kapat (müşteri onaylamadan Google'da çıkmasın)
$idx = Join-Path $hedef "index.html"
$h = [IO.File]::ReadAllText($idx)
if ($h -notmatch 'name="robots"') {
  $h = $h -replace '<head>', "<head>`n<meta name=""robots"" content=""noindex, nofollow"">"
  [IO.File]::WriteAllText($idx, $h, [Text.UTF8Encoding]::new($false))
}

Push-Location $repo
try {
  git add -A
  git commit -q -m "Yayınla: $Ad"
  git push -q origin main
} finally { Pop-Location }

$url = (git -C $repo remote get-url origin) -replace '^https://github.com/([^/]+)/([^/.]+)(\.git)?$', 'https://$1.github.io/$2'
Write-Host "Yayında (1-2 dk içinde açılır): $url/$Ad/"
