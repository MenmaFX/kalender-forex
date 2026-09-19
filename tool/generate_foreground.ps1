Add-Type -AssemblyName System.Drawing

$srcPath = "D:\Bongkaran\kalender-forex\assets\icons\app_logo.png"
$outPath = "D:\Bongkaran\kalender-forex\assets\icons\app_logo_foreground.png"

$src = [System.Drawing.Image]::FromFile($srcPath)
$canvasSize = 1024
# Safe zone standar adaptive icon Android (66% dari 1024 = ~675px)
$targetSize = 680
$offset = [int](($canvasSize - $targetSize) / 2)

$dest = New-Object System.Drawing.Bitmap $canvasSize, $canvasSize
$g = [System.Drawing.Graphics]::FromImage($dest)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.Clear([System.Drawing.Color]::Transparent)

$destRect = New-Object System.Drawing.Rectangle $offset, $offset, $targetSize, $targetSize
$g.DrawImage($src, $destRect)

$g.Dispose()
$src.Dispose()

$dest.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$dest.Dispose()

Write-Host "SUCCESS: Generated $outPath"

