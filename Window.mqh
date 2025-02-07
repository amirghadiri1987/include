

//+------------------------------------------------------------------+
//|                                      ChartObjectsTxtControls.mqh |
//|                             Copyright 2000-2024, MetaQuotes Ltd. |
//+------------------------------------------------------------------+
#include "ChartObject.mqh"

// Global variable to store the edit control state
bool isEditing = false;
string textControlName = "MyText"; // Name of your text control

//+------------------------------------------------------------------+
//| Custom function for checking mouse over the text control         |
//+------------------------------------------------------------------+
bool IsMouseOverTextControl(int x, int y) {
    // Get the position and size of the text control
    long chart_id = ChartID();
    double price = Bid; // Example price, can be customized
    datetime time = TimeCurrent(); // Example time, can be customized
    
    // Get coordinates of the text control
    double textX, textY, textWidth, textHeight;
    if (!ObjectGetTextControlCoordinates(chart_id, textControlName, textX, textY, textWidth, textHeight)) {
        return false; // If we cannot get the coordinates, return false
    }
    
    // Check if mouse coordinates are within the text control area
    return (x >= textX && x <= textX + textWidth && y >= textY && y <= textY + textHeight);
}

//+------------------------------------------------------------------+
//| Function to remove focus from the text control                    |
//+------------------------------------------------------------------+
void RemoveFocusFromTextControl() {
    isEditing = false; // Reset editing state
    // Logic to update the chart if necessary
    // You may want to refresh the chart or do other operations here
}

//+------------------------------------------------------------------+
//| OnMouseMove event handler                                         |
//+------------------------------------------------------------------+
void OnMouseMove(int x, int y) {
    if (!isEditing) return; // Exit if not in editing mode
    
    // Check if mouse is over the text control
    if (!IsMouseOverTextControl(x, y)) {
        // Exit edit mode
        RemoveFocusFromTextControl();
    }
}

//+------------------------------------------------------------------+
//| OnClick event handler                                             |
//+------------------------------------------------------------------+
void OnClick() {
    // Logic to check if the text control was clicked
    if (ObjectFind(ChartID(), textControlName) != -1) {
        // If clicked on the text control, set editing state
        isEditing = true;
    }
}

//+------------------------------------------------------------------+
//| Function to create the text control                               |
//+------------------------------------------------------------------+
bool CreateTextControl() {
    long chart_id = ChartID();
    if (!ObjectCreate(chart_id, textControlName, OBJ_TEXT, 0, TimeCurrent(), Bid)) {
        return false;
    }
    ObjectSetInteger(chart_id, textControlName, OBJPROP_FONTSIZE, 12);
    ObjectSetString(chart_id, textControlName, OBJPROP_FONT, "Arial");
    ObjectSetInteger(chart_id, textControlName, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(chart_id, textControlName, OBJPROP_XSIZE, 100); // Width
    ObjectSetInteger(chart_id, textControlName, OBJPROP_YSIZE, 20);  // Height
    return true;
}

//+------------------------------------------------------------------+
//| Custom function to get text control coordinates                   |
//+------------------------------------------------------------------+
bool ObjectGetTextControlCoordinates(long chart_id, const string name, double &x, double &y, double &width, double &height) {
    // Retrieve properties of the text object
    x = ObjectGetDouble(chart_id, name, OBJPROP_X); // X position
    y = ObjectGetDouble(chart_id, name, OBJPROP_Y); // Y position
    width = ObjectGetInteger(chart_id, name, OBJPROP_XSIZE); // Width
    height = ObjectGetInteger(chart_id, name, OBJPROP_YSIZE); // Height
    return true;
}

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit() {
    CreateTextControl(); // Create the text control when the expert initializes
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    ObjectDelete(ChartID(), textControlName); // Clean up text control on deinitialization
}

//+------------------------------------------------------------------+
