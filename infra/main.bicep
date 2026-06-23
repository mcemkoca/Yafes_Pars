@description('Environment name (dev, staging, prod)')
param environment string = 'prod'

@description('Azure region')
param location string = resourceGroup().location

@description('App Service plan SKU')
@allowed(['B1', 'B2', 'B3', 'S1', 'S2', 'P1v3', 'P2v3'])
param appServiceSku string = 'B2'

@description('Docker image tag to deploy')
param imageTag string = 'latest'

@description('GitHub Container Registry image (e.g. ghcr.io/mcemkoca/yafes_pars)')
param containerImage string

@description('JWT Authority URL')
param jwtAuthority string

@description('JWT Audience')
param jwtAudience string

@description('Allowed CORS origins (comma-separated)')
param corsAllowedOrigins string = ''

var appName = 'yafespars-${environment}'
var kvName = 'kv-yafespars-${environment}'

// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: kvName
  location: location
  properties: {
    sku: { family: 'A', name: 'standard' }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 30
  }
}

// Log Analytics Workspace
resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'log-${appName}'
  location: location
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: 30
  }
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'ai-${appName}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logWorkspace.id
  }
}

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: 'asp-${appName}'
  location: location
  kind: 'linux'
  sku: {
    name: appServiceSku
  }
  properties: {
    reserved: true
  }
}

// App Service (Container)
resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerImage}:${imageTag}'
      alwaysOn: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      appSettings: [
        { name: 'ASPNETCORE_ENVIRONMENT', value: 'Production' }
        { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', value: appInsights.properties.ConnectionString }
        { name: 'Authentication__Authority', value: jwtAuthority }
        { name: 'Authentication__Audience', value: jwtAudience }
        { name: 'Cors__AllowedOrigins__0', value: corsAllowedOrigins }
        { name: 'YAFES_SQL_CONNECTION_STRING', value: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=sql-connection-string)' }
        { name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE', value: 'false' }
      ]
    }
  }
}

// Grant App Service managed identity access to Key Vault secrets
resource kvSecretsUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, appService.id, '4633458b-17de-408a-b874-0445c86b69e0')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e0')
    principalId: appService.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output appServiceUrl string = 'https://${appService.properties.defaultHostName}'
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output keyVaultName string = keyVault.name
