﻿<# 
SYNOPSIS:
Data Collection Script for Power BI Report Server Issues

Objective:
This script has the objective to cover and simplify the data collection for the majority of troubleshooting scenarios related to Power BI Report Server.

Important Disclaimer:
The script is not supported under any Microsoft standard support program or service. 
The script is provided AS IS without warranty of any kind. 
Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of 
fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation 
remains with you. In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of 
the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, 
business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the 
sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages. 

The collected data may contain Personally Identifiable Information (PII) and/or sensitive data, such as usernames.
Therefore we advice that you review the created files before sharing it with anyone. 
#>


#-------- Disclaimer to Start Process ------------
Add-Type -AssemblyName Microsoft.VisualBasic
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'Info'
$message = 'Description: 
Please be informed that this "Power BI Report Server Data Collection" script is designed to collect information that will help Microsoft Customer Support Services (CSS) troubleshoot an issue you may be experiencing with your report server.
The script zips data from various sources to a destination you determine in a following step. The files will not automatically be shared with anyone but yourself. 

Please select scope in subsequent step from topics such as:
- various report server database tables
- RS configuration info such as rsreportserver.config
- all RS ".log" files.
- system and application log: Error/warnings

Disclaimer: Review the created files
The collected data may contain Personally Identifiable Information (PII) and/or sensitive data, such as usernames.
Therefore we advice that you review the created files before sharing it with anyone. 

Do you would like to proceed?'
$confirm = [Microsoft.VisualBasic.Interaction]::MsgBox(
    $message,
    [Microsoft.VisualBasic.MsgBoxStyle]::Information + [Microsoft.VisualBasic.MsgBoxStyle]::YesNo,
    $title
)
if ($confirm -eq 'No') {
    Write-Host 'Execution aborted by user.' -ForegroundColor Red
    exit
}

#-------- Names for selection Options ------------ 
$SelectionOption1 = "RS configuration info"
$SelectionOption2 = "RS logs"
$SelectionOption3 = "ExecutionLog3"
$SelectionOption4 = "subscription / schedule refresh / event table"
$SelectionOption5 = "System and application log: Error/Warnings"
$SelectionOption6 = "authentication scripts from aka.ms/authscripts"

#-------- PopUp to determine which data will be collected ------------ 
Add-Type -AssemblyName System.Windows.Forms
$title = 'Topic Selector'
$msg   = 
$options = @($SelectionOption1,$SelectionOption2, $SelectionOption3, $SelectionOption4, $SelectionOption5, $SelectionOption6)
$checkedListBox = New-Object System.Windows.Forms.CheckedListBox
$checkedListBox.Items.AddRange($options)
$checkedListBox.CheckOnClick = $true # set CheckOnClick property to true
$checkedListBox.Top = 20 # adjust position from the top
$checkedListBox.Left = 20 # adjust position to the right
$checkedListBox.Width = 250
$form = New-Object System.Windows.Forms.Form
$form.StartPosition = 'CenterScreen' # set StartPosition property to CenterScreen
$form.Text = $title
$form.Width = 300
$form.Height = 200 # increase height to avoid overlapping
$form.Controls.Add($checkedListBox)
$label = New-Object System.Windows.Forms.Label
$label.Text = 'Select the topics you want to collect:'
$label.Left = 20 # adjust position to the right
$label.Width = 250
$form.Controls.Add($label)
$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$okButton.Left = 150 - $okButton.Width / 2
$okButton.Top = 120 # increase top position to avoid overlapping
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

# set the first four checkboxes to be checked by default
for ($i = 0; $i -lt 4; $i++) {
    $checkedListBox.SetItemChecked($i, $true)
}

$result = $form.ShowDialog()
$SelectedOption = @{}
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    foreach ($option in $options) {
        $SelectedOption[$option] = $checkedListBox.CheckedItems.Contains($option)
    }
}

Write-Host $SelectionOption1": $($SelectedOption[$SelectionOption1])"
Write-Host $SelectionOption2": $($SelectedOption[$SelectionOption2])"
Write-Host $SelectionOption3": $($SelectedOption[$SelectionOption3])"
Write-Host $SelectionOption4": $($SelectedOption[$SelectionOption4])"
Write-Host $SelectionOption5": $($SelectedOption[$SelectionOption5])"
Write-Host $SelectionOption6": $($SelectedOption[$SelectionOption6])"


#-------- Determining Input Varibles Through PopUp Message Boxes ------------ 
Add-Type -AssemblyName Microsoft.VisualBasic
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'Instancename'
$msg   = 'Enter your Instancename here:'
$serverInstancename = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title, 'localhost')

[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'Report Server Database Name'
$msg   = 'Enter your Report Server Database Name here:'
$ReportserverDB = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title, 'ReportServer')

[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'PBIRS Installation Path'
$msg   = 'Enter your PBIRS Installation Path here:'
$PBIRSInstallationPath = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title, 'C:\Program Files\Microsoft Power BI Report Server\')

$Folder = Join-Path $env:USERPROFILE "\Documents\ReportServerInvestigation"

[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'Path Result Folder'
$msg   = 'This will be the path the collected documents will be saved in'
$Folder = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title, $Folder)

$ResultFileName = (Get-Date).ToString("yyMMdd") + $env:USERNAME + "Result.zip" 
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'Name Zip File'
$msg   = 'This will be the name of the zip file'
$ResultFileName = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title, $ResultFileName)

if ($SelectedOption[$SelectionOption5]) {
$startDate = (Get-Date).AddDays(-1)
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'Start of Event Log'
$msg   = 'This will be the starting day the application and system log will be collected from. 

If you had the issue earlier please modify'
$startDate = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title, $startDate)
}

if ($SelectedOption[$SelectionOption5]) {
$endDate = Get-Date
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'End of Event Log'
$msg   = 'The application and system log will be collected till today. 

To limit the data selection feel free to modify the collection to end at an earlier day.'
$endDate = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title, $endDate)
}

[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'Time of Error'
$msg   = 'Please provide one or multiple precise timestamp(s) when you experienced the error. 

Just enter the date and time as text.'
$ErrorTime = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title, "Unknown")

[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'Report with Error'
$msg   = 'Please provide one or multiple report names you are having issues with. 

If you have issues with all reports please leave ALL'
$ImpactedReport = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title, "All")

#-------- Checking if a variable is empty and aborting the process if so ------------
if ([string]::IsNullOrEmpty($ResultFileName) -or [string]::IsNullOrEmpty($Folder) -or [string]::IsNullOrEmpty($PBIRSInstallationPath) -or [string]::IsNullOrEmpty($ReportserverDB) -or [string]::IsNullOrEmpty($serverInstancename) -or [string]::IsNullOrEmpty($ErrorTime)) {
    Write-Host "One or more required variables are empty. Aborting process." -ForegroundColor Red
    exit 1
}


#-------- Other variables ------------
$FolderLogs = Join-Path -Path $Folder "\Logs"
$PowerBILogs = $PBIRSInstallationPath + "PBIRS\LogFiles"
$RSreportserverConfigFile = $PBIRSInstallationPath + "PBIRS\ReportServer\RSreportserver.config"
$ApplicationLogFile = $Folder+"\ApplicationLog.csv"
$SystemLogFile = $Folder+"\SystemLog.csv"


#-------- SQL Command Subscription and Schedule Refresh ----------
$RenderFormatValue1 = '(//ParameterValue/Value[../Name="RenderFormat"])[1]'
$RenderFormatValue2 = '(//ParameterValue/Value[../Name="RENDER_FORMAT"])[1]'
$RenderFormatExpression = 'ISNULL(Convert(XML,sub.[ExtensionSettings]).value(' + "'$RenderFormatValue1', 'nvarchar(50)'), Convert(XML,sub.[ExtensionSettings]).value('$RenderFormatValue2', 'nvarchar(50)')) AS RenderFormat"
$SubjectValue = '(//ParameterValue/Value[../Name="Subject"])[1]'
$SubjectExpression = "Convert(XML,sub.[ExtensionSettings]).value('$SubjectValue', 'nvarchar(150)') AS [Subject]"

$sqlcmdSubscriptionScheduleRefresh = 
@"
SELECT rs.ReportID
,rs.SubscriptionID
,ROUND(TRY_CAST(cat.ContentSize AS FLOAT)/1048576,3) ContentSizeMB 
,SUBSTRING(cat.[Path],1,LEN(cat.[Path])-LEN(cat.[Name])) AS ReportFolder
,cat.[Name] AS ReportName
,sub.[Description] AS SubscriptionDescription
,sub.LastStatus
,sub.LastRunTime
,sub.EventType
,s.ScheduleID AS JobName
,'EXEC msdb.dbo.sp_start_job @job_name = ''' + CAST(s.ScheduleID AS VARCHAR(50)) + '''' AS RunSubscriptionManually
,s.StartDate
,s.EndDate
,CASE   WHEN s.RecurrenceType=1 THEN 'Once'  
    WHEN s.RecurrenceType=2 THEN 'Hourly'  
    WHEN s.RecurrenceType=3 THEN 'Daily'  
    WHEN s.RecurrenceType=4 AND s.WeeksInterval <= 1 THEN 'Daily'  
    WHEN s.RecurrenceType=4 AND s.WeeksInterval > 1 THEN 'Weekly'
        WHEN s.RecurrenceType=5 THEN 'Monthly (days)'  
        WHEN s.RecurrenceType=6 THEN 'Monthly (weeks)'  
END AS Recurrence
,s.MinutesInterval
,s.DaysInterval
,s.WeeksInterval
,s.DaysOfWeek
,s.DaysOfMonth
,s.[Month]
,s.MonthlyWeek
,$RenderFormatExpression
,$SubjectExpression
,sub.[Parameters]
,cat.[Path]
,cat.CreationDate  AS ReportCreateDate
,cat.ModifiedDate AS ReportSettingsModified
,u.UserName
,sub.DataSettings AS DataDrivenSettings
,sub.ExtensionSettings
,sub.OwnerID AS SubscriptionOwnerID
FROM dbo.ReportSchedule rs WITH (NOLOCK)
INNER JOIN dbo.Schedule s WITH (NOLOCK) ON rs.ScheduleID = s.ScheduleID
INNER JOIN dbo.[Catalog] cat WITH (NOLOCK) ON rs.ReportID = cat.ItemID
INNER JOIN dbo.Subscriptions sub WITH (NOLOCK) ON rs.SubscriptionID = sub.SubscriptionID
INNER JOIN dbo.Users u WITH (NOLOCK) ON sub.OwnerID = u.UserID
"@


#-------- SQL Command for Subscription History ----------
$sqlcmdSubscriptionScheduleRefreshHistory =
"
select *, 
DATEDIFF(MINUTE, StartTime , EndTime) AS MinuteDiff 
from dbo.SubscriptionHistory 
Order By MinuteDiff desc 
"


#--------- SQL Command for ExecutionLog3 ---------
$sqlcmdExecutionLog3 = "select * from executionlog3"


#--------- SQL Command for Event table -----------
$sqlcmdEvent = "select * from Event"

#--------- SQL Command for Configuration Info -----------
$sqlcmdConfigurationInfo = "SELECT * FROM [dbo].[ConfigurationInfo]"


#--------- Install Prereq SQL Module -------------
#install module
Install-Module -Name SqlServer -AllowClobber -Scope CurrentUser


#--------- Create Destination Folder and Subfolder -------
New-Item -ItemType Directory -Path  $Folder -Force
Write-Host "
New Folder created $Folder"

if ($SelectedOption[$SelectionOption2]) {
New-Item -ItemType Directory -Path  $FolderLogs -Force
Write-Host "
New Folder created $FolderLogs
"
}

#--------- Save Timestamp ----------------------------------------
$ErrorTime | Out-File -FilePath "$Folder\Timestamp.txt" -NoNewline -Encoding ASCII
Write-Host "Successfully Timestamp in txt file saved"

#--------- Save ReportName ----------------------------------------
$ImpactedReport | Out-File -FilePath "$Folder\ImpactedReportName.txt" -NoNewline -Encoding ASCII
Write-Host "Successfully ImpactedReport in txt file saved"

#--------- Retrieve the Windows application logs for the specified date range----
if ($SelectedOption[$SelectionOption5]) {
$Applicationlogs = Get-WinEvent -FilterHashtable @{
    LogName = "Application"
    StartTime = $startDate
    EndTime = $endDate
    Level = 1,2,3  # Warning, Error, Critical
}


# Output the logs to a CSV file
$Applicationlogs | Export-Csv -Path $ApplicationLogFile -NoTypeInformation

Write-Host "Successfully Application Logs as csv saved - Event Level Information and Verbose EXCLUDED"
}

#--------- Retrieve the Windows system logs for the specified date range----
if ($SelectedOption[$SelectionOption5]) {
$Systemlogs = Get-WinEvent -FilterHashtable @{
    LogName = "System"
    StartTime = $startDate
    EndTime = $endDate
    Level = 1,2,3  # Warning, Error, Critical
}

# Output the logs to a CSV file
$Systemlogs | Export-Csv -Path $SystemLogFile -NoTypeInformation

Write-Host "Successfully System Logs as csv saved - Event Level Information and Verbose EXCLUDED"
}


#--------- Logfiles ----------------------------------------
if ($SelectedOption[$SelectionOption2]) {
# Get all .log files in the source folder
$files = Get-ChildItem $PowerBILogs -Filter *.log -File

# Loop through each file and move it to the destination folder
foreach ($file in $files) {
    $destinationFile = Join-Path $FolderLogs $file.Name

    Copy-Item $file.FullName $destinationFile
}
Write-Host "Successfully Report Server Logs collected"
}

#--------- RSreportserver.config ---------------------------
if ($SelectedOption[$SelectionOption1]) {
  Copy-Item $RSreportserverConfigFile $Folder -Force
  Write-Host "Successfully collected the RSreportserver.config file
  "
  }


#---------- Getting Database tables -------------------------------
#execute SQL commands to collect data
#Write-Host "Collection of Data from Report Server Database"
if ($SelectedOption[$SelectionOption4]) {
Invoke-Sqlcmd -ServerInstance $serverInstancename -Database $ReportserverDB -Query $sqlcmdSubscriptionScheduleRefresh | Export-Csv -NoTypeInformation "$Folder\SubscriptionScheduleRefresh.csv" -Force
Invoke-Sqlcmd -ServerInstance $serverInstancename -Database $ReportserverDB -Query $sqlcmdSubscriptionScheduleRefreshHistory | Export-Csv -NoTypeInformation "$Folder\SubscriptionScheduleRefreshHistory.csv" -Force
Write-Host "Successfully collected Subscription and Schedule Refresh Last Status"
Write-Host "Successfully collected Subscription and Schedule Refresh History"
}
if ($SelectedOption[$SelectionOption3]) {
Invoke-Sqlcmd -ServerInstance $serverInstancename -Database $ReportserverDB -Query $sqlcmdExecutionLog3 | Export-Csv -NoTypeInformation "$Folder\ExecutionLog3.csv" -Force
Write-Host "Successfully collected ExecutionLog3 table"
}

if ($SelectedOption[$SelectionOption4]) {
Invoke-Sqlcmd -ServerInstance $serverInstancename -Database $ReportserverDB -Query $sqlcmdEvent  | Export-Csv -NoTypeInformation "$folder\Eventtable.csv" -Force
Write-Host "Successfully collected Event table"
}

if ($SelectedOption[$SelectionOption1]) {
Invoke-Sqlcmd -ServerInstance $serverInstancename -Database $ReportserverDB -Query $sqlcmdConfigurationInfo  | Export-Csv -NoTypeInformation "$folder\ConfigurationInfo.csv" -Force
Write-Host "Successfully collected ConfigurationInfo table
"
}

# Authentication Scripts
if ($SelectedOption[$SelectionOption6]) {
    
# Check if PowerShell is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as an administrator."
    [System.Windows.Forms.MessageBox]::Show("The authentication script has not been executed. For this step to complete please run Powershell as Admin")
}

if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Admin check completed, starting Auth script now"

Add-Type -AssemblyName System.Windows.Forms

# Define the URL of the zip file
$zipUrl = "https://aka.ms/authscript"
# Define the path where the zip file will be downloaded and extracted
$downloadPath = "$env:USERPROFILE\Downloads\AuthScript"
# Create the download directory if it does not exist
if (-not (Test-Path -Path $downloadPath)) {
    New-Item -ItemType Directory -Path $downloadPath -force
}

# Download the zip file
Invoke-WebRequest -Uri $zipUrl -OutFile "$downloadPath\auth.zip" 

# Extract the contents of the zip file
Expand-Archive -Path "$downloadPath\auth.zip" -DestinationPath $downloadPath -Force

# Define the script paths
$startScriptPath = "$downloadPath\start-auth.ps1"
$stopScriptPath = "$downloadPath\stop-auth.ps1"

# Define the form and controls
$form = New-Object System.Windows.Forms.Form
$form.Text = "Auth Script"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

$startButton = New-Object System.Windows.Forms.Button
$startButton.Location = New-Object System.Drawing.Point(10, 10)
$startButton.Size = New-Object System.Drawing.Size(80, 25)
$startButton.Text = "Start"
$startButton.Add_Click({
    # Execute the start-auth.ps1 script
    $startProcess = Start-Process powershell.exe "-File $startScriptPath" -PassThru
    $startButton.Enabled = $false
    $stopButton.Enabled = $true
    $cancelButton.Enabled = $true
})

$stopButton = New-Object System.Windows.Forms.Button
$stopButton.Location = New-Object System.Drawing.Point(100, 10)
$stopButton.Size = New-Object System.Drawing.Size(80, 25)
$stopButton.Text = "Stop"
$stopButton.Enabled = $false
$stopButton.Add_Click({
    # Execute the stop-auth.ps1 script
    & $stopScriptPath
    $startButton.Enabled = $true
    $stopButton.Enabled = $false
    $cancelButton.Enabled = $true
})

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(190, 10)
$cancelButton.Size = New-Object System.Drawing.Size(80, 25)
$cancelButton.Text = "Cancel"
$cancelButton.Enabled = $false
$cancelButton.Add_Click({
    # Stop the start-auth.ps1 script process
    if ($startProcess) {
        Stop-Process $startProcess.Id
    }
    $form.Close()
})

# Add the controls to the form
$form.Controls.Add($startButton)
$form.Controls.Add($stopButton)
$form.Controls.Add($cancelButton)

# Show the form
$form.ShowDialog() | Out-Null
}
}

#---------- Zipping all Files -------------------------------
$zipFile = Join-Path -Path $Folder $ResultFileName
Compress-Archive -Path $Folder -DestinationPath $zipFile -force

Write-Host "Successfully zipped the collected files"


#---------- Removing non zipped Files -------------------------------
Get-ChildItem $Folder | Where-Object { $_.Extension -ne '.zip' } | Remove-Item -Recurse -Force

Write-Host "Successfully deleted non-zipped files"

#---------- Finished Message Box -------------------------------
[System.Windows.Forms.MessageBox]::Show("Please check the successful completion in $Folder", "Script Completed", "OK", "Information")

#---------- Opening Folder Path with file -------------------------------
if(Test-Path $Folder) {
    Invoke-Item $Folder
}
else {
    Write-Host "Folder not found at specified location."
}
