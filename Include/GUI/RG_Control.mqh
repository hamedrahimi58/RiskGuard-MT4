#ifndef __RG_CONTROL_MQH__
#define __RG_CONTROL_MQH__

//====================================================
// RiskGuard MT4
// GUI v3
// RG-017-001
//====================================================

class CRGControl
{
protected:

   string m_name;

   int m_x;
   int m_y;

   int m_width;
   int m_height;

   bool m_visible;

public:

   //--------------------------------------------------
   // Constructor
   //--------------------------------------------------

   CRGControl()
   {
      m_name="";

      m_x=0;
      m_y=0;

      m_width=0;
      m_height=0;

      m_visible=true;
   }

   //--------------------------------------------------
   // Destructor
   //--------------------------------------------------

   virtual ~CRGControl(){}

   //--------------------------------------------------
   // Name
   //--------------------------------------------------

   void SetName(string name)
   {
      m_name=name;
   }

   string Name() const
   {
      return(m_name);
   }

   //--------------------------------------------------
   // Bounds
   //--------------------------------------------------

   void SetBounds(
      int x,
      int y,
      int width,
      int height)
   {
      m_x=x;
      m_y=y;

      m_width=width;
      m_height=height;
   }

   //--------------------------------------------------
   // Position
   //--------------------------------------------------

   int Left()   const { return(m_x);      }
   int Top()    const { return(m_y);      }

   int Width()  const { return(m_width);  }
   int Height() const { return(m_height); }

   //--------------------------------------------------
   // Visibility
   //--------------------------------------------------

   virtual void Show()
   {
      m_visible=true;

      if(ObjectFind(0,m_name)>=0)
         ObjectSetInteger(0,m_name,OBJPROP_HIDDEN,false);
   }

   virtual void Hide()
   {
      m_visible=false;

      if(ObjectFind(0,m_name)>=0)
         ObjectSetInteger(0,m_name,OBJPROP_HIDDEN,true);
   }

   bool Visible() const
   {
      return(m_visible);
   }

   //--------------------------------------------------
   // Destroy
   //--------------------------------------------------

   virtual void Destroy()
   {
      if(ObjectFind(0,m_name)>=0)
         ObjectDelete(0,m_name);
   }

};

#endif