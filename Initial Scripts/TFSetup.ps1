## This script should be run initially to setup the proper resources in Azure for the Terraform Github action to interact with.
## A Client Secret and App ID will be output which needs to be put into the repos secrets.

#Parameters
$SiteName = "YetiOpsOSP"
$Region = "westcentralus"
$SubscritpionID = "3366cc54-ec64-4456-a5c1-526fece3cf7d"

# Create set the username for the IAM user to be used as $SiteName + Terraform
$IAMUserName = $SiteName + "Terraform"

# Login via device code
az login --use-device-code

# Create the terraform user and client secret. SAves these as:
# AZURE_AD_CLIENT_ID = appId 
# AZURE_AD_CLIENT_SECRET = password 
# AZURE_AD_TENANT_ID = tenant 
# AZURE_AD_SUBSCRIPTION_ID = subscriptionID
az account set --subscription="$SubscritpionID"
az ad sp create-for-rbac -n "$IAMUserName"

# Create the Storage Account for Terraform TS STate
$StateRGName = $SiteName.ToLower() + "tftate"
$StateStorageName = $SiteName.ToLower() + "tf"
$StateContainerName = "tfstate" + $SiteName.ToLower() 

az group create -n $StateRGName -l $Region
az storage account create -n $StateStorageName -g $StateRGName -l $Region --sku Standard_LRS
az storage container create --account-name $StateStorageName -n $StateContainerName