// Parameters 
param orgName string = 'default'
param LogAnalyticsWorkspaceName string = '${orgName}-LAW'
param retentionPeriod int = 90 
param logIngestionCap int = 5 
param allowPublicIngestion string = 'enabled'
param rgLocation string = resourceGroup().location
 @allowed([
  'Test'
  'Development'
  'Production'
])
param UsageTagValue string = 'Test'
param purposeTagValue string = 'SIEM'
param tagValues object = {
    Usage: UsageTagValue
    Purpose: purposeTagValue
}

// Resources
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: LogAnalyticsWorkspaceName
  location: rgLocation
  tags: tagValues
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccessForIngestion: allowPublicIngestion
    publicNetworkAccessForQuery: allowPublicIngestion
    retentionInDays: retentionPeriod
    sku: {
      name: 'PerGB2018'
    }
    workspaceCapping: {
      dailyQuotaGb: logIngestionCap
    }
  }
}

resource Sentinel 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'SecurityInsights(${LogAnalyticsWorkspaceName})'
  location: rgLocation
  tags: tagValues
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id // IMPLICIT Dependency
  }
  plan: {
    name: 'SecurityInsights(${LogAnalyticsWorkspaceName})'
    product: 'OMSGallery/SecurityInsights'
    promotionCode: '' // This value is required by the API
    publisher: 'Microsoft'
  }
}
