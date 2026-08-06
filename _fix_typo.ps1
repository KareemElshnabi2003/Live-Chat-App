Get-ChildItem -Path 'c:\Users\Afraad.User01.WATANYAROADS\Desktop\LiveChat_2-main\LiveChat_2-main\lib' -Recurse -Filter '*.dart' | ForEach-Object {
  $content = [System.IO.File]::ReadAllText($_.FullName)
  if ($content.Contains('sacndaryColor')) {
    $content = $content.Replace('sacndaryColor', 'secondaryColor')
    [System.IO.File]::WriteAllText($_.FullName, $content)
    Write-Host "Fixed: $($_.Name)"
  }
}
