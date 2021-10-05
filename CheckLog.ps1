#region CONFIG STARTS
$ProgramName = "";
$LogPath = "";
$CountRecordPath = "${PSScriptRoot}\${ProgramName}-record.txt";

$MailUsername = "";
$MailPassword = "";
$ToMailAddress = ""

$QQAddress = "";
$QQPort = "";
$QQRecieverID = "";
#endregion CONFIG ENDS

#region FUNCTIONS START
function Send-ToEmail([string]$email, [string]$body) {

    $message = new-object Net.Mail.MailMessage;
    $message.From = $MailUsername;
    $message.To.Add($email);
    $message.Subject = "New Error in $ProgramName";
    $message.Body = $body;

    $smtp = new-object Net.Mail.SmtpClient("smtp.qq.com", 587);
    $smtp.EnableSSL = $true;
    $smtp.Credentials = New-Object System.Net.NetworkCredential($MailUsername, $MailPassword);
    $smtp.Timeout = 10000;
    $smtp.send($message);
    write-host "Mail Sent"; 
}

function Send-ToQQ([string]$content) {
    $message = "New Error on $ProgramName%0A";
    $message += $content;
    $Uri = "http://${QQAddress}:${QQPort}/send_private_msg?user_id=${QQRecieverID}&message=${message}";

    Invoke-WebRequest -Uri $Uri;
}

function GetLogs([int]$line) {
    For($i=-3; $i -le 3; $i++) {
        $Content.GetValue($line + $i);
        echo "";
    }
}

function GetQQLogs([int]$line) {
    For($i=-3; $i -le 3; $i++) {
        $Content.GetValue($line + $i);
        echo "%0A";
    }
}
#endregion FUNCTIONS END

#region MAIN PROCESS STARTS
if($(Test-Path -Path $CountRecordPath) -eq $False ) {
    Set-Content -Path $CountRecordPath '0';
}

$PrevCount = Get-Content $CountRecordPath -Encoding UTF8;
$Content = Get-Content $LogPath -Encoding UTF8;
$Matches = $Content | Select-String -CaseSensitive -Pattern 'Error' -AllMatches
$LineNumbers = $Matches | Select LineNumber;
$CurCount = $Matches.Matches.Count;

if($CurCount -gt $PrevCount) {
    Send-ToQQ -content $(GetQQLogs -line $LineNumbers[$LineNumbers.Length - 1].LineNumber);
    Send-ToEmail -email $ToMailAddress -Body $(GetLogs -line $LineNumbers[$LineNumbers.Length - 1].LineNumber);
} else {
    write-host 'pass';
}

Out-File -FilePath $CountRecordPath -InputObject $CurCount -Encoding utf8;
#endregion MAIN PROCESS ENDS
