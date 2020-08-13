$jobuserpswd = "Password"
$password = ConvertTo-SecureString $jobuserpswd -AsPlainText -Force
$username = "server/username"
$servername = "servername"
$cred = New-Object System.Management.Automation.PSCredential($username,$password)

try{
Invoke-Command -ComputerName $servername -Credential $cred -Authentication Credssp -ScriptBlock{
Add-PSSnapin Microsoft.SharePoint.Powershell -ErrorAction SilentlyContinue
$SearchServiceApplication = Get-SPEnterpriseSearchServiceApplication -Identity "Search Service Application" 

#Get the Local SharePoint sites content source  
$ContentSource = $SearchServiceApplication | Get-SPEnterpriseSearchCrawlContentSource -Identity "Your Search Application Content Source"  
  
  #Check if Crawler is not already running or Idle  
  if($ContentSource.CrawlState -eq "Idle")  
        {  
            Write-Host "Full Crawl Starts..." -ForegroundColor Green            
            $ContentSource.StartFullCrawl()
            
            Do{
            Write-Host "`r#" -NoNewline -ForegroundColor Yellow
            Start-Sleep 5
            } while ($ContentSource.CrawlState -ne "Idle")
            
            Write-Host "`Full Crawl Completed" -ForegroundColor Green
              
       }  
  else  
  {  
   Write-Host "Full Crawl is already Started!"  
   Write-Host "NAME: ", $ContentSource.Name, " - ", $ContentSource.CrawlStatus, $ContentSource.CrawlState -ForegroundColor Yellow
  }}
  }
 catch [Exception]{
Write-Error "Error while running script"
$exceptionMessage = ($_.Exception|format-list -force)
Write-Debug $exceptionMessage.ToString()
}
