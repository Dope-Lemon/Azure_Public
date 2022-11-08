$ResourceGroup = "Example1" #Declare your preferred resource group, if it does not exist it will be created.
$SenderEmail = "sender@example.com" #Preferred sending address in the tenant where the application will be deployed.
$RecipientEmail = "recipient@exmaple2.com" #Recipient for the report.
$TenantID = "Your Tenant ID goes here." #This variable is used to assign the MS Graph permissions
$LogicAppName = "Automated-Secret-Expiry-Notification" #Call the application whatever you like, this is the default.
$BicepFileName = "Biceptemplate.bicep" #Generic, can be changed but keep the .bicep suffix
Invoke-WebRequest -URI https://raw.githubusercontent.com/Dope-Lemon/Azure_Public/main/Automated-Secret-Expiry/Automated-Secret-Expiry-Notification.bicep -OutFile $BicepFileName
function Add-MSGraphPermissions 
{
    try 
    {
        Connect-MgGraph -Scopes 'Directory.ReadWrite.All','AppRoleAssignment.ReadWrite.All' -TenantId $TenantID
        Write-Output "Preparing to add permissions"
        #Edit the below permissions as required for any applications you deploy
        $Permissions = @(
        "Application.Read.All"
        "Mail.Send"
        )
        
        $GraphAppId = "00000003-0000-0000-c000-000000000000" # Don't change this.
        $AutomationServicePrincipal = Get-AzADServicePrincipal -Filter "displayName eq '$LogicAppName'"
        $GraphServicePrincipal = Get-AzADServicePrincipal -Filter "appId eq '$GraphAppId'"

        $Approle = $GraphServicePrincipal.AppRole | Where-Object {($_.Value -in $Permissions) -and ($_.AllowedMemberType -contains "Application")}

        foreach($AppRole in $AppRole)
        {
        $AppRoleAssignment = @{
            "PrincipalId" = $AutomationServicePrincipal.Id
            "ResourceId" = $GraphServicePrincipal.Id
            "AppRoleId" = $AppRole.Id
        }
        
        New-MgServicePrincipalAppRoleAssignment `
            -ServicePrincipalId $AppRoleAssignment.PrincipalId `
            -BodyParameter $AppRoleAssignment `
            -Verbose
        }
        Write-Output "Graph Permissions Assigned"
    }
    catch 
    {
        Write-Output "$_" 
    }
}
function New-ResourceGroup 
{
    try 
    {
        $ResourceGroupExists = Get-AzResourceGroup -ResourceGroupName $ResourceGroup -ErrorAction SilentlyContinue
        
        if ($Null -eq $ResourceGroupExists) 
        {
            Write-Output "The specified Resource Group does not exist, creating now"
            $ResourceGroupLocation = Read-Host -Prompt "Please enter your preferred resourcegroup location. Example: australiaeast, eastus"
            New-AzResourceGroup -Name $ResourceGroup -Location $ResourceGroupLocation
        }
        else 
        {
            Write-Output "$ResourceGroup already exists, no further action required" 
        }
    }
    catch 
    {
        Write-Output "$_" 
    }
}

function Remove-ExchangePermissions 
{
    try 
    {   $AutomationServicePrincipal = Get-AzADServicePrincipal -Filter "displayName eq '$LogicAppName'"
        Connect-ExchangeOnline
        New-DistributionGroup -Name "LogicApp Group" -Alias logicapp -members $SenderEmail -Type security
        New-ApplicationAccessPolicy -AppId $AutomationServicePrincipal.id -PolicyScopeGroupId "LogicApp Group" -AccessRight RestrictAccess -Description "Limit LogicApp  to only send emails as specified email"
    }
    catch 
    {
        Write-Output "$_" 
    }
}

Write-Output "Connecting to Azure"
Connect-AzAccount
Write-Output "Creating Resource Group"
New-ResourceGroup
Write-Output "Deploying Azure Bicep Template"
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateFile $BicepFileName -logicappname $LogicAppName -sender_email_address $SenderEmail -recipient_email_address $RecipientEmail
Write-Output "Adding Microsoft Graph Permissions, please sign-in"
Add-MSGraphPermissions
Write-Output "Limiting Exchange Permissions to the single mailbox required,"
Write-Output "Connecting to Exchange"
Start-Sleep -Seconds 3
Remove-ExchangePermissions
Write-Output "Script completed."
