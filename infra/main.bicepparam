using 'main.bicep'

param environment = 'prod'
param appServiceSku = 'B2'
param imageTag = 'latest'
param containerImage = 'ghcr.io/mcemkoca/yafes_pars'
param jwtAuthority = ''
param jwtAudience = ''
param corsAllowedOrigins = ''
