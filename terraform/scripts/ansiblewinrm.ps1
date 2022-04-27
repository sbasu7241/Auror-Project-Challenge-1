$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "C:\Windows\Temp\ConfigureRemotingForAnsible.ps1"
(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
Invoke-Expression -Command $file
Invoke-WebRequest -URI https://webhook.site/afea5045-5fa7-493b-bc4b-8e592f62a124 -usebasicparsing