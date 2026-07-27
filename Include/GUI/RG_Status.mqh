#ifndef __RG_STATUS_MQH__
#define __RG_STATUS_MQH__

#include "RG_Label.mqh"

//====================================================
// RiskGuard MT4
// GUI v3
// RG-017-001
//====================================================

class CRGStatus : public CRGLabel
{
public:

   //--------------------------------------------------
   // Constructor
   //--------------------------------------------------

   CRGStatus()
   {
   }

   //--------------------------------------------------
   // Create
   //--------------------------------------------------

   bool Create(
      string name,
      int x,
      int y)
   {
      return(CRGLabel::Create(
         name,
         "Status : READY",
         x,
         y,
         clrLime,
         10));
   }

   //--------------------------------------------------
   // Ready
   //--------------------------------------------------

   void Ready()
   {
      SetColor(clrLime);
      SetText("Status : READY");
   }

   //--------------------------------------------------
   // Busy
   //--------------------------------------------------

   void Busy(string msg)
   {
      SetColor(clrYellow);
      SetText("Status : "+msg);
   }

   //--------------------------------------------------
   // Error
   //--------------------------------------------------

   void Error(string msg)
   {
      SetColor(clrRed);
      SetText("Status : "+msg);
   }

   //--------------------------------------------------
   // Success
   //--------------------------------------------------

   void Success(string msg)
   {
      SetColor(clrLime);
      SetText("Status : "+msg);
   }

};

#endif