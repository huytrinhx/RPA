#Import Modules for Power BI Login
Import-Module MicrosoftPowerBIMgmt
Import-Module MicrosoftPowerBIMgmt.Profile


<#
Created By: Hewitt Trinh
Created on: 12-Mar-2019
Purpose: This Power shell script will read the data from SQL Server with the query provided 
and execute the same to refresh the dataset mentioned in the endpoint of the streaming dataset
This applicable for Use Case 1, Use Case 2, Use Case 3 and Use Case 4

Modified By: Hewitt Trinh
Modified on: 1-Jul-2019
Purpose: Update additional requirement for Usecase3

Modified BY: Hewitt Trinh
On: Oct - 09 - 2019
Purpose: Update outdated rules on SQL of WorkForce Availability and 2 add. columns for Schedule

#>



<#
Read the Server Details form the .ini file. the file will be kept outside the script to control the Server details configurable

#>
$filepath = "~\Control.ini"
$Logfileu1 = "~\Logs\BluePrismUsecase1log.log"
$Logfileu2 = "~\Logs\BluePrismUsecase2log.log"
$Logfileu3 = "~\Logs\BluePrismUsecase3log.log"
$Logfileu4 = "~\Logs\BluePrismUsecase4log.log"

$ControlParameters = Get-Content $filepath 

# Read User Id password and password converted to secure string (Assume secure password key and aes key are created before)
$UserId = $ControlParameters[5].Substring($ControlParameters[5].IndexOf("=") + 1)
$Password = Get-Content ~Secure\password.txt | ConvertTo-SecureString -Key (Get-Content ~\Secure\aes.key)
$credential = New-Object System.Management.Automation.PsCredential($UserId,$Password)


#Login with the credentials

Connect-PowerBIServiceAccount -Credential $credential

#Get the SQL Server sepcific details from ini
$SqlServer = $ControlParameters[0].Substring($ControlParameters[0].IndexOf("=") +1)
$SqlDatabase = $ControlParameters[1].Substring($ControlParameters[1].IndexOf("=") +1 )
$Useridsql = $ControlParameters[2].Substring($ControlParameters[2].IndexOf("=") +1 )
$Passwordsql = $ControlParameters[3].Substring($ControlParameters[3].IndexOf("=") +1 )
$Interval = $ControlParameters[4].Substring($ControlParameters[4].IndexOf("=") +1 )
#form Connection string




#$SqlConnectionString = 'Data Source={0};Initial Catalog={1};Integrated Security=SSPI' -f $SqlServer, $SqlDatabase;
$SqlConnectionString = 'Data Source={0};Initial Catalog={1};User ID={2};password={3}' -f $SqlServer, $SqlDatabase, $Useridsql, $Passwordsql ;



#Set the connection    
$SqlConnection = New-Object -TypeName System.Data.SqlClient.SqlConnection -ArgumentList $SqlConnectionString;
$SqlConnection.Open();            

#Append Log file
function LogWrite
{
   Param ([string]$Logfile,[string]$logstring)

   Add-content $Logfile -value $logstring
}

#Write to New Log file
function LogWriteStart
{
   Param ([string]$Logfile,[string]$logstring)
   
   
  set-content $Logfile -value $logstring
}

<# Trigger Use Case 1: Workforce Availability#>>

function UseCase1refresh()
{
    


    Try
    {
    
        #Query to refresh the dataset
        
        $SqlQueryu1 = "~\_sql\WorkForceAvailability.sql";

            #Set the query
            $SqlCommandu1 = New-Object -TypeName System.Data.SqlClient.SqlCommand;
            $SqlCommandu1.CommandText = $SqlQueryu1;
            $SqlCommandu1.Connection = $SqlConnection;
        
        
            #Open and execute the query
            #$SqlConnection.Open();
            # Return the dataset and fill it in Dataset      
            $SqlAdapteru1 = New-Object System.Data.SqlClient.SqlDataAdapter;
            
            $SqlAdapteru1.SelectCommand = $SqlCommandu1;
            
            $DataSetu1 = New-Object System.Data.DataSet;

            $recrodsu1 = $SqlAdapteru1.Fill($DataSetu1);
           
          $NameValue = $DataSetu1.Tables[0].Rows[0].ItemArray[0]
          
          
            $SqlDatau1= ($DataSetu1.Tables[0] | select $DataSetu1.Tables[0].Columns.ColumnName ) | ConvertTo-Json
            
            
            if ($NameValue -eq "NA" -and $recrodsu1 -eq 1)
            {
            
            $SqlDatau1 = "[" + $SqlDatau1 + "]"
            }
            
            
            


            #prod
            $endpointu1 = "https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/b4981f65-3a95-46a8-bcbd-91f611b7683e/rows?key=mvf9SSis7OuJ5FgDssenjJsuGpgL%2FRHT%2F2wdaXCsxpZ3Pjy6Pet5wdrP%2BI%2B9mYoeBX99MAPnd8yD7GWeVK58uw%3D%3D"

            #qa
            #$endpointu1 = "https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/4e363e09-7a32-4579-bf96-e98da193d4a4/rows?key=ebc6KHPiGxqBm43K%2Ftx6nJ4gTn9%2FAw2jhaDj3EU%2FaJpEPZB5ef%2FNPx9yF1V1tMR0nYSOF6xTLBcROQ1wHeo9cA%3D%3D"

            #dev
            #$endpointu1  = "https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/ea585ac0-95c3-4b8d-876d-c51b2c61bb4e/rows?key=XG6X5nGbEoQgKNO5v0XdyvuQknhldEGIo0PwVjxHZqxcC71mTGGlRuboDZZG34I3zk6qqYc4RzgCnYmjSxyNrg%3D%3D"

                       
            Remove-PowerBIRow -Datasetid b4981f65-3a95-46a8-bcbd-91f611b7683e -TableName RealTimeData
            #dev
            #Remove-PowerBIRow -Datasetid ea585ac0-95c3-4b8d-876d-c51b2c61bb4e -TableName RealTimeData

            $Starttime = Get-Date
            LogWrite $Logfileu1 "Event: Refresh starts eventDate: $Starttime"

            Invoke-RestMethod -Method Post -Uri "$endpointu1" -Body ($SqlDatau1)
            $Starttime = Get-Date
            LogWrite $Logfileu1 "Event: Refresh ends eventDate: $Starttime"
         

            $SqlAdapteru1.Dispose();        
            $SqlCommandu1.Dispose();   
            [System.GC]::Collect();
            


                                      
    
    }
    Catch 
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $Starttime = Get-Date
        LogWrite $Logfileu1 "Event: Logging Error Catch Block eventDate: $Starttime"
        LogWrite $Logfileu1 "Error Message: $ErrorMessage" 
        [System.GC]::Collect();

    }

}


<#Trigger Use Case 3: Running Stages #>

function UseCase3Refresh()
{

    Try
    {
        $Starttime = Get-Date

        


         
           
            #Query to refresh the dataset

            $SqlQueryu3 = "~\_sql\ScheduleStatus.sql";

            #Set the query
            $SqlCommandu3 = New-Object -TypeName System.Data.SqlClient.SqlCommand;
            $SqlCommandu3.CommandText = $SqlQueryu3;
            $SqlCommandu3.Connection = $SqlConnection;
            

            
            $Starttime = Get-Date
            LogWrite $Logfileu3 "Event: Refresh starts eventDate: $Starttime"

            # Return the dataset and fill it in Dataset      
            $SqlAdapteru3 = New-Object System.Data.SqlClient.SqlDataAdapter;
            $SqlAdapteru3.SelectCommand = $SqlCommandu3;
            $DataSetu3 = New-Object System.Data.DataSet;
            $recrodsu3 = $SqlAdapteru3.Fill($DataSetu3);
         
            #Convert the dataset to Jason
           # $SqlDatau3= ($DataSetu3.Tables[0] | select $DataSetu3.Tables[0].Columns.ColumnName ) | ConvertTo-Json


           $Process = $DataSetu3.Tables[0].Rows[0].ItemArray[0]
          
            $SqlDatau3= ($DataSetu3.Tables[0] | select $DataSetu3.Tables[0].Columns.ColumnName ) | ConvertTo-Json
            
             
            if ($Process -eq "#*NA*#" -and $recrodsu3 -eq 1)
            {
            
            $SqlDatau3 = "[" + $SqlDatau3 + "]"
            }
            
            
            
            #This connection end point to be replaced for each report
            $endpointu3 ="https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/b9e5ac8f-44aa-4408-961b-b133214b708b/rows?key=t23XD%2F985k1RRypo3kEWUMFrm37D40IoMXCk%2FNWtUZ3Q2096RvXcZW7wekFAR3pb%2BIAdvmBnMyjnDg6MwKpEtQ%3D%3D";

            Remove-PowerBIRow -Datasetid b9e5ac8f-44aa-4408-961b-b133214b708b -TableName RealTimeData
            #echo "Refresh"

            Invoke-RestMethod -Method Post -Uri "$endpointu3" -Body ($SqlDatau3)

            $Starttime = Get-Date
            LogWrite $Logfileu3 "Event: Refresh ends eventDate: $Starttime"         

            $SqlAdapteru3.Dispose();        
            $SqlCommandu3.Dispose();   
            [System.GC]::Collect();
                                                  
    }
           
    
    Catch 
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $Starttime = Get-Date
        LogWrite $Logfileu3 "Event: Logging Error Catch Block eventDate: $Starttime"
        LogWrite $Logfileu3 "Error Message: $ErrorMessage"   
        [System.GC]::Collect();
    }
}


<# Trigger Use Case 4: Termination Count#>

function UseCase4refresh()
{
    


    Try
    {
    
        #Query to refresh the dataset
        
        $SqlQueryu4 = "~\_sql\Moving4HourTerminationCount.sql"

            #Set the query
            $SqlCommandu4 = New-Object -TypeName System.Data.SqlClient.SqlCommand;
            $SqlCommandu4.CommandText = $SqlQueryu4;
            
            
            $SqlCommandu4.Connection = $SqlConnection;
        
        
            #Open and execute the query
            #$SqlConnection.Open();
            # Return the dataset and fill it in Dataset      
            $SqlAdapteru4 = New-Object System.Data.SqlClient.SqlDataAdapter;
            
            $SqlAdapteru4.SelectCommand = $SqlCommandu4;
            
            $DataSetu4 = New-Object System.Data.DataSet;

            $recrodsu4 = $SqlAdapteru4.Fill($DataSetu4);
            
            $ProcessName = $DataSetu4.Tables[0].Rows[0].ItemArray[1]

         
            #Convert the dataset to Json
            $SqlDatau4= ($DataSetu4.Tables[0] | select $DataSetu4.Tables[0].Columns.ColumnName ) | ConvertTo-Json
            
            
             if ($ProcessName -eq "NA" -and $recrodsu4 -eq 1)
            {
            
            $SqlDatau4 = "[" + $SqlDatau4 + "]"
            }


            


            #QA
            $endpointu4 = "https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/73247372-9b26-40d0-b652-e5b1747911b0/rows?key=hXEpAHn7C2oztY4n%2BW3r7IA2foJ2SkrKartVMsNg4IxkWnslsHrkYMZTTG3xmiLLlbH89%2BGyba6Y5qhqRVlHVQ%3D%3D"
              
            Remove-PowerBIRow -Datasetid 73247372-9b26-40d0-b652-e5b1747911b0 -TableName RealTimeData
            
            $Starttime = Get-Date
            LogWrite $Logfileu4 "Event: Refresh starts eventDate: $Starttime"

            Invoke-RestMethod -Method Post -Uri "$endpointu4" -Body ($SqlDatau4)
            $Starttime = Get-Date
            LogWrite $Logfileu4 "Event: Refresh ends eventDate: $Starttime"

                  

            $SqlAdapteru4.Dispose();        
            $SqlCommandu4.Dispose();
            [System.GC]::Collect();
            


                                      
    
    }
    Catch 
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $Starttime = Get-Date
        LogWrite $Logfileu4 "Event: Logging Error Catch Block eventDate: $Starttime"
        LogWrite $Logfileu4 "Error Message: $ErrorMessage"
        [System.GC]::Collect();
        
    }

}


<# Trigger Use Case 2: Schedule Status#>
function UseCase2refresh()
{
    


    Try
    {
    
        #Query to refresh the dataset
        
        $SqlQueryu2 = "~\_sql\ScheduleStatus.sql"
            #Set the query
            $SqlCommandu2 = New-Object -TypeName System.Data.SqlClient.SqlCommand;
            $SqlCommandu2.CommandText = $SqlQueryu2;
            
            
            $SqlCommandu2.Connection = $SqlConnection;
        
        
            #Open and execute the query
            #$SqlConnection.Open();
            # Return the dataset and fill it in Dataset      
            $SqlAdapteru2 = New-Object System.Data.SqlClient.SqlDataAdapter;
            
            $SqlAdapteru2.SelectCommand = $SqlCommandu2;
            
            $DataSetu2 = New-Object System.Data.DataSet;

            $recrodsu2 = $SqlAdapteru2.Fill($DataSetu2);
           
          $ScheduleName = $DataSetu2.Tables[0].Rows[0].ItemArray[0]
          
          
            $SqlDatau2= ($DataSetu2.Tables[0] | select $DataSetu2.Tables[0].Columns.ColumnName ) | ConvertTo-Json
            
            
            if ($ScheduleName -eq "#*NA*#" -and $recrodsu2 -eq 1)
            {
            
            $SqlDatau2 = "[" + $SqlDatau2 + "]"
            }
            
                       


            #QA
            $endpointu2 = "https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/790210b2-d26d-4b7f-a3ba-c86d8967e1c2/rows?key=4%2F4Yr6HRq%2BShbEro8Imrnbi%2Fo3ha3fTg9ReD7loE0%2FutdA7bz73SiKGIo4QZhBUapyD48UTIe2VkH59JxvFiCg%3D%3D"

            #actual
            #$endpointu1 = "https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/4e363e09-7a32-4579-bf96-e98da193d4a4/rows?key=ebc6KHPiGxqBm43K%2Ftx6nJ4gTn9%2FAw2jhaDj3EU%2FaJpEPZB5ef%2FNPx9yF1V1tMR0nYSOF6xTLBcROQ1wHeo9cA%3D%3D"

            #working
            #$endpointu1  = "https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/ea585ac0-95c3-4b8d-876d-c51b2c61bb4e/rows?key=XG6X5nGbEoQgKNO5v0XdyvuQknhldEGIo0PwVjxHZqxcC71mTGGlRuboDZZG34I3zk6qqYc4RzgCnYmjSxyNrg%3D%3D"

                       
            Remove-PowerBIRow -Datasetid 790210b2-d26d-4b7f-a3ba-c86d8967e1c2 -TableName RealTimeData
            #working
            #Remove-PowerBIRow -Datasetid ea585ac0-95c3-4b8d-876d-c51b2c61bb4e -TableName RealTimeData

            $Starttime = Get-Date
            LogWrite $Logfileu2 "Event: Refresh starts eventDate: $Starttime"

            Invoke-RestMethod -Method Post -Uri "$endpointu2" -Body ($SqlDatau2)
            $Starttime = Get-Date
            LogWrite $Logfileu2 "Event: Refresh ends eventDate: $Starttime"

            #sleep for 10 Sec
            #Start-Sleep $Interval         

            $SqlAdapteru2.Dispose();        
            $SqlCommandu2.Dispose();
            #$SqlConnection.Close();   
            #$SqlConnection.Dispose();   
            [System.GC]::Collect();
            


                                      
    
    }
    Catch 
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $Starttime = Get-Date
        LogWrite $Logfileu2 "Event: Logging Error Catch Block eventDate: $Starttime"
        LogWrite $Logfileu2 "Error Message: $ErrorMessage"
        #$SqlAdapteru1.Dispose();  
        #$SqlCommandu1.Dispose();
        #$SqlConnection.Close();   
        #$SqlConnection.Dispose(); 
        [System.GC]::Collect();
       # Break

    }

}


<#MAIN #>
$n=1
$Count = 1
DO
{    

    $Starttime = Get-Date
    if ($n -eq 1)
    {
    LogWriteStart $Logfileu1 "Event: Logging started Start Time: $Starttime";
    }
    UseCase1Refresh;    

    $Starttime = Get-Date

    if ($n -eq 1)
    {
    LogWriteStart $Logfileu3 "Event: Logging started Start Time: $Starttime"
    }

    UseCase3Refresh;

    $Starttime = Get-Date

    if ($n -eq 1)
    {
    LogWriteStart $Logfileu4 "Event: Logging started Start Time: $Starttime"
    }

    UseCase4Refresh;

    $Starttime = Get-Date

    if ($n -eq 1)
    {
    LogWriteStart $Logfileu2 "Event: Logging started Start Time: $Starttime"
    }

    UseCase2Refresh;


    $n=0
    if ($Count -eq 17280)
    {
    
        if (Test-Path $Logfileu1) 
        {
            Remove-Item $Logfileu1
        }
        if (Test-Path $Logfileu3) 
        {
            Remove-Item $Logfileu3
        }
        if (Test-Path $Logfileu4) 
        {
            Remove-Item $Logfileu4
        }
        if (Test-Path $Logfileu2) 
        {
            Remove-Item $Logfileu2
        }
      $n = 1
      $Count = 1
    }
    

    $Count++
    

     #sleep for 10 Sec $Interval 
     Start-Sleep $Interval   

} While(1 -eq 1)

$SqlConnection.Close();  
$SqlConnection.Dispose();  
