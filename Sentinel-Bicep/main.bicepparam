using './main.bicep'

param orgName = 'jmacleandev' // This value is mandatory. 
param LogAnalyticsWorkspaceName = '${orgName}-LAW'
param retentionPeriod = 90 // This is the period of retention in days that logs will be retained for, when Sentinel is added on-top of a LAW 90 days is included for free!
param logIngestionCap = 5 // This is the cap in GB of ingested logs per day. 
param allowPublicIngestion = 'enabled'
param rgLocation = 'australiaeast' // This value is optional. Bicep will use the default value of the resource group location if the line is commented out or deleted.
param UsageTagValue = 'Test'  // Accepted Values are Test, Development, Production
param purposeTagValue = 'SIEM'
param tagValues = {
  Usage: UsageTagValue
  Purpose: purposeTagValue
}
