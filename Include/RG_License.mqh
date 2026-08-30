#ifndef __RG_LICENSE_MQH__
#define __RG_LICENSE_MQH__

//====================================================
// RiskGuard Simple Private License
// RG065
//====================================================

void RG_MainStatus(string text);

// Comma-separated list of licensed MT4 account numbers.
// Add/remove account numbers here without changing the validation logic.
#define RG_LICENSE_ACCOUNTS "180033829"
#define RG_LICENSE_SERVER  "Inveslo-Demo"

bool RG_LicenseAccountMatches()
{
   string list=RG_LICENSE_ACCOUNTS;
   string current=IntegerToString(AccountNumber());
   int len=StringLen(list);
   int start=0;

   if(len<=0)
      return(false);

   while(start<len)
   {
      int comma=StringFind(list,",",start);
      if(comma<0)
         comma=len;

      string item=StringSubstr(list,start,comma-start);
      StringTrimLeft(item);
      StringTrimRight(item);

      if(item==current)
         return(true);

      start=comma+1;
   }

   return(false);
}

bool RG_LicenseServerMatches()
{
   if(StringLen(RG_LICENSE_SERVER)<=0)
      return(false);
   return(AccountServer()==RG_LICENSE_SERVER);
}

bool RG_LicenseIsConfigured()
{
   return(StringLen(RG_LICENSE_ACCOUNTS)>0 && StringLen(RG_LICENSE_SERVER)>0);
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
