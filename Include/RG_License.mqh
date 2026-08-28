#ifndef __RG_LICENSE_MQH__
#define __RG_LICENSE_MQH__

//====================================================
// RiskGuard Simple Private License
// RG065
//====================================================

void RG_MainStatus(string text);

#define RG_LICENSE_ACCOUNT 180033829
#define RG_LICENSE_SERVER  "Inveslo-Demo"

bool RG_LicenseAccountMatches()
{
   if(RG_LICENSE_ACCOUNT<=0)
      return(false);
   return(AccountNumber()==RG_LICENSE_ACCOUNT);
}

bool RG_LicenseServerMatches()
{
   if(StringLen(RG_LICENSE_SERVER)<=0)
      return(false);
   return(AccountServer()==RG_LICENSE_SERVER);
}

bool RG_LicenseIsConfigured()
{
   return(RG_LICENSE_ACCOUNT>0 && StringLen(RG_LICENSE_SERVER)>0);
}

bool RG_LicenseIsValid()
{
   return(
      RG_LicenseIsConfigured() &&
      RG_LicenseAccountMatches() &&
      RG_LicenseServerMatches()
   );
}

string RG_LicenseStatus()
{
   if(!RG_LicenseIsConfigured())
      return("LICENSE LOCKED - NOT CONFIGURED");
   if(!RG_LicenseAccountMatches())
      return("LICENSE LOCKED - INVALID ACCOUNT");
   if(!RG_LicenseServerMatches())
      return("LICENSE LOCKED - INVALID SERVER");
   return("LICENSE ACTIVE");
}

void RG_LicenseApplyStatus()
{
   RG_MainStatus(RG_LicenseStatus());
}

#endif
