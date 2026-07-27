#ifndef __RG_LABEL_MQH__
#define __RG_LABEL_MQH__

#include "RG_Control.mqh"

//====================================================
// RiskGuard MT4
// GUI v3
// RG-017-001
//====================================================

class CRGLabel : public CRGControl
{
private:

   string m_text;
   color  m_color;
   int    m_fontSize;
   string m_font;

public:

   //--------------------------------------------------
   // Constructor
   //--------------------------------------------------

   CRGLabel()
   {
      m_text     = "";
      m_color    = clrWhite;
      m_fontSize = 10;
      m_font     = "Arial";
   }

   //--------------------------------------------------
   // Create
   //--------------------------------------------------

   bool Create(
      string name,
      string text,
      int x,
      int y,
      color textColor = clrWhite,
      int fontSize = 10)
   {
      SetName(name);
      SetBounds(x,y,0,0);

      m_text     = text;
      m_color    = textColor;
      m_fontSize = fontSize;

      if(ObjectFind(0,name)>=0)
         ObjectDelete(0,name);

      if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0))
         return(false);

      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);

      ObjectSetString(0,name,OBJPROP_TEXT,text);

      ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);

      ObjectSetString(0,name,OBJPROP_FONT,m_font);

      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontSize);

      ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,false);

      return(true);
   }

   //--------------------------------------------------
   // Text
   //--------------------------------------------------

   void SetText(string text)
   {
      m_text=text;

      if(ObjectFind(0,Name())>=0)
         ObjectSetString(0,Name(),OBJPROP_TEXT,text);
   }

   string Text() const
   {
      return(m_text);
   }

   //--------------------------------------------------
   // Color
   //--------------------------------------------------

   void SetColor(color c)
   {
      m_color=c;

      if(ObjectFind(0,Name())>=0)
         ObjectSetInteger(0,Name(),OBJPROP_COLOR,c);
   }

   //--------------------------------------------------
   // Font Size
   //--------------------------------------------------

   void SetFontSize(int size)
   {
      m_fontSize=size;

      if(ObjectFind(0,Name())>=0)
         ObjectSetInteger(0,Name(),OBJPROP_FONTSIZE,size);
   }

};

#endif