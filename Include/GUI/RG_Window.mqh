#ifndef __RG_WINDOW_MQH__
#define __RG_WINDOW_MQH__

//====================================================
// RiskGuard MT4
// GUI v3
// RG-017-001
//====================================================

class CRGWindow
{
private:

   string m_name;

   int m_x;
   int m_y;

   int m_width;
   int m_height;

   color m_backColor;
   color m_borderColor;

public:

   //--------------------------------------------------
   // Constructor
   //--------------------------------------------------

   CRGWindow()
   {
      m_name="";

      m_x=0;
      m_y=0;

      m_width=0;
      m_height=0;

      m_backColor=clrBlack;
      m_borderColor=clrDimGray;
   }

   //--------------------------------------------------
   // Create
   //--------------------------------------------------

   bool Create(
      string name,
      int x,
      int y,
      int width,
      int height,
      color backColor=clrBlack,
      color borderColor=clrDimGray)
   {
      m_name=name;

      m_x=x;
      m_y=y;

      m_width=width;
      m_height=height;

      m_backColor=backColor;
      m_borderColor=borderColor;

      if(ObjectFind(0,m_name)>=0)
         ObjectDelete(0,m_name);

      if(!ObjectCreate(0,m_name,OBJ_RECTANGLE_LABEL,0,0,0))
         return(false);

      ObjectSetInteger(0,m_name,OBJPROP_XDISTANCE,m_x);
      ObjectSetInteger(0,m_name,OBJPROP_YDISTANCE,m_y);

      ObjectSetInteger(0,m_name,OBJPROP_XSIZE,m_width);
      ObjectSetInteger(0,m_name,OBJPROP_YSIZE,m_height);

      ObjectSetInteger(0,m_name,OBJPROP_BGCOLOR,m_backColor);
      ObjectSetInteger(0,m_name,OBJPROP_BORDER_COLOR,m_borderColor);

      ObjectSetInteger(0,m_name,OBJPROP_BACK,false);
      ObjectSetInteger(0,m_name,OBJPROP_HIDDEN,true);

      ObjectSetInteger(0,m_name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,m_name,OBJPROP_SELECTED,false);

      return(true);
   }

   //--------------------------------------------------
   // Destroy
   //--------------------------------------------------

   void Destroy()
   {
      if(ObjectFind(0,m_name)>=0)
         ObjectDelete(0,m_name);
   }

   //--------------------------------------------------
   // Show
   //--------------------------------------------------

   void Show()
   {
      if(ObjectFind(0,m_name)>=0)
         ObjectSetInteger(0,m_name,OBJPROP_HIDDEN,false);
   }

   //--------------------------------------------------
   // Hide
   //--------------------------------------------------

   void Hide()
   {
      if(ObjectFind(0,m_name)>=0)
         ObjectSetInteger(0,m_name,OBJPROP_HIDDEN,true);
   }

   //--------------------------------------------------
   // Name
   //--------------------------------------------------

   string Name()
   {
      return(m_name);
   }

};

#endif