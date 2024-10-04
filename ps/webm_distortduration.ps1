param(
    $inputFilePath,
    $outputFilePath
)
if (!$inputFilePath) {return}
function Echoo {return "[$($MyInvocation.MyCommand.Name)]: $($args[0])"}

if ( !(Test-Path $inputFilePath -PathType Leaf)) {return Echoo "'$inputFilePath' not found."}
$inputFilePath = ((Resolve-Path $inputFilePath).Path).ToString()

if (!$outputFilePath) {
    $outputFilePath = $inputFilePath -replace '^(.*\\)([^\\]+)(\.[^\\]+?)$','$1$2_distorted$3'
} else {
    $outputFilePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($outputFilePath)
}

if (Test-Path $outputFilePath -PathType Leaf) {Remove-Item $outputFilePath -ErrorAction SilentlyContinue}

# Define the hex values to search and replace
$searchHex = "448988[0-9A-Fa-f]{8}"
$replaceHex = "448988408D7DB0"

# Read the binary file into a byte array
$fileBytes = [System.IO.File]::ReadAllBytes($inputFilePath)

# Convert the byte array to a hex string
$hexString = -join ($fileBytes | ForEach-Object { $_.ToString("X2") })

if ($hexString -notmatch $searchHex) {return Echoo "Hex search pattern not found."}

# Replace the search hex value with the replace hex value
$modifiedHexString = $hexString -replace $searchHex, $replaceHex

# Ensure the modified hex string length is even
if ($modifiedHexString.Length % 2 -ne 0) {
    return Echoo "The length of the modified hex string is not even."
}

# Convert the modified hex string back to a byte array
$modifiedBytes = for ($i = 0; $i -lt $modifiedHexString.Length; $i += 2) {
    [Convert]::ToByte($modifiedHexString.Substring($i, 2), 16)
}

# Write the modified byte array to the output file
[System.IO.File]::WriteAllBytes($outputFilePath, $modifiedBytes)

return Echoo "Hex replacement completed successfully."