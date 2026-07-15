#ifndef __RG_INPUT_V2_MQH__
#define __RG_INPUT_V2_MQH__

//====================================================
// Input Types
//====================================================
enum ENUM_RG_INPUT_TYPE
{
   RG_INPUT_INT = 0,
   RG_INPUT_DOUBLE,
   RG_INPUT_LOT,
   RG_INPUT_PRICE,
   RG_INPUT_PERCENT
};

//====================================================
// Input Structure
//====================================================
struct RGInput
{
   string Name;

   ENUM_RG_INPUT_TYPE Type;

   double Value;
   double MinValue;
   double MaxValue;
};

//====================================================
// Create Input
//====================================================
void RG_InputCreate(
   RGInput &ctrl,
   const string name,
   const ENUM_RG_INPUT_TYPE type,
   const double value,
   const double minValue,
   const double maxValue)
{
   ctrl.Name     = name;
   ctrl.Type     = type;

   ctrl.Value    = value;

   ctrl.MinValue = minValue;
   ctrl.MaxValue = maxValue;
}

//====================================================
// Set Value
//====================================================
bool RG_InputSetValue(
   RGInput &ctrl,
   const double value)
{
   if(value < ctrl.MinValue)
      return(false);

   if(value > ctrl.MaxValue)
      return(false);

   ctrl.Value = value;

   return(true);
}

//====================================================
// Get Value
//====================================================
double RG_InputGetValue(
   const RGInput &ctrl)
{
   return(ctrl.Value);
}

#endif