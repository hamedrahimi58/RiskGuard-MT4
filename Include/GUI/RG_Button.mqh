#ifndef __RG_BUTTON_MQH__
#define __RG_BUTTON_MQH__

#include "RG_Control.mqh"

//====================================================
// RiskGuard MT4
// GUI v3
// RG-017-001
//====================================================

class CRGButton : public CRGControl
{
private:

   string m_caption;

   color  m_backColor;
   color  m_textColor;
   color  m_borderColor;

   int    m_fontSize;

   bool   m_enabled;

public:

   //--------------------------------------------------
   // Constructor
   //--------------------------------------------------

   CRGButton()
   {
      m_caption="";

      m_backColor=clrSilver;
      m_textColor=clrBlack;
      m_borderColor=clrDimGray;

      m_fontSize=10;

      m_enabled=true;
   }

   //--------------------------------------------------
   // Create
   //--------------------------------------------------

   bool Create(
      string name,
      string caption,
      int x,
      int y,
      int width,
      int height,
      color backColor,
      color textColor)
   {
      SetName(name);
      SetBounds(x,y,width,height);

      m_caption=caption;

      m_backColor=backColor;
      m_textColor=textColor;

      if(ObjectFind(0,name)>=0)
         ObjectDelete(0,name);

      if(!ObjectCreate(0,name,OBJ_BUTTON,0,0,0))
         return(false);

      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);

      ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,height);

      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,m_backColor);
      ObjectSetInteger(0,name,OBJPROP_COLOR,m_textColor);

      ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,m_borderColor);

      ObjectSetString(0,name,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,m_fontSize);

      ObjectSetString(0,name,OBJPROP_TEXT,m_caption);

      ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);

      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,false);

      return(true);
   }

   //--------------------------------------------------
   // Caption
   //--------------------------------------------------

   void SetCaption(string caption)
   {
      m_caption=caption;

      if(ObjectFind(0,Name())>=0)
         ObjectSetString(0,Name(),OBJPROP_TEXT,caption);
   }

   string Caption() const
   {
      return(m_caption);
   }

   //--------------------------------------------------
   // Enable
   //--------------------------------------------------

   void Enable(bool enable=true)
   {
      m_enabled=enable;

      if(ObjectFind(0,Name())<0)
         return;

      if(enable)
      {
         ObjectSetInteger(0,Name(),OBJPROP_STATE,false);
         ObjectSetInteger(0,Name(),OBJPROP_COLOR,m_textColor);
      }
      else
      {
         ObjectSetInteger(0,Name(),OBJPROP_STATE,false);
         ObjectSetInteger(0,Name(),OBJPROP_COLOR,clrGray);
      }
   }

   bool Enabled() const
   {
      return(m_enabled);
   }

   //--------------------------------------------------
   // Colors
   //--------------------------------------------------

   void SetBackColor(color c)
   {
      m_backColor=c;

      if(ObjectFind(0,Name())>=0)
         ObjectSetInteger(0,Name(),OBJPROP_BGCOLOR,c);
   }

   void SetTextColor(color c)
   {
      m_textColor=c;

      if(ObjectFind(0,Name())>=0)
         ObjectSetInteger(0,Name(),OBJPROP_COLOR,c);
   }

};

#endif