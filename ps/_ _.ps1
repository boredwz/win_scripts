#  Get-GithubLatestReleaseURL (PowerShell)
#  
#  [Author]
#    boredwz | https://github.com/boredwz/
#  
#  [Usage]
#    iex "&{$(iwr -useb 'https://gist.githubusercontent.com/boredwz/e7872773f4c44671ca37fad7ca3912b7/raw/Get-GithubLatestReleaseUrl.ps1')} 'author' 'repo'"
#    Or download this file:
#    & ".\Get-GitHubLatestReleaseURL" author repo

param (
    [Parameter(Mandatory=$true)][string]$Author,
    [Parameter(Mandatory=$true)][string]$Repo
)

$api = Invoke-RestMethod "https://api.github.com/repos/$Author/$Repo/releases/latest"
return @{
    Files=$api.assets.browser_download_url;
    Zip=$api.zipball_url;
    Tar=$api.tarball_url;
}