
$auth = (ConvertFrom-Json -InputObject (Get-Content .\lib\client_secret.json -Encoding UTF8  -Raw)).web
$gcp = ConvertFrom-Json -InputObject (Get-Content .\lib\gcp.json -Encoding UTF8  -Raw)

Write-Host "New access token..."
$gsheets_scope = $gcp.gsheets_scope
$auth_url = $gcp.auth_url + $gsheets_scope
$auth_url += "&redirect_uri=$($auth.redirect_uris[0])"
$auth_url += "&client_id=$($auth.client_id)"
$auth_url += "&response_type=code&approval_prompt=force"
Start-Process $auth_url
$code = Read-Host "コードを入力"
$code = $code -replace "%2F","/"

$new_body = @{
    "client_id" = $auth.client_id;
    "client_secret" = $auth.client_secret;
    "redirect_uri" = $auth.redirect_uris[0];
    "grant_type" = "authorization_code";
    "code" = $code;
}
$new_credential = Invoke-RestMethod -Method Post -Uri $auth.token_uri -Body $new_body

$uri = "https://sheets.googleapis.com/v4/spreadsheets/$($gcp.sheet_id)/"
$Header = @{
    Authorization= "Bearer $($new_credential.access_token)";
}
Invoke-WebRequest $uri -Method GET -Headers $Header -ContentType "application/json"
