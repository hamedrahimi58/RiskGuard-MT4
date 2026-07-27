#ifndef __RG_WINDOW_MQH__
#define __RG_WINDOW_MQH__

//====================================================
// RiskGuard MT4
// GUI v3
// RG-017-012
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



      // Background layer
      ObjectSetInteger(0,m_name,OBJPROP_BACK,true);

      ObjectSetInteger(0,m_name,OBJPROP_ZORDER,0);



      ObjectSetInteger(0,m_name,OBJPROP_HIDDEN,true);

      ObjectSetInteger(0,m_name,OBJPROP_SELECTABLE,false);

      ObjectSetInteger(0,m_name,OBJPROP_SELECTED,false);



      return(true);
   }



   void Destroy()
   {
      if(ObjectFind(0,m_name)>=0)
         ObjectDelete(0,m_name);
   }



   void Show()
   {
      if(ObjectFind(0,m_name)>=0)
         ObjectSetInteger(0,m_name,OBJPROP_HIDDEN,false);
   }



   void Hide()
   {
      if(ObjectFind(0,m_name)>=0)
         ObjectSetInteger(0,m_name,OBJPROP_HIDDEN,true);
   }



   string Name()
   {
      return(m_name);
   }

};


#endif