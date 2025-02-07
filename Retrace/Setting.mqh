#include <Controls/CheckBox.mqh>
#include <Controls/Label.mqh>
#include <Arrays/List.mqh>


enum TYPE_THEMES
{
  Dark,
  Light
};
enum SET_COLOR_THEMES
{
  SET_COLOR_THEMES_ABSENT,     // Absent
  SET_COLOR_THEMES_BANNER,     // Banner    
  SET_COLOR_THEMES_BRAVE,      // Brave
  SET_COLOR_THEMES_BLINK,      // Blink
  SET_COLOR_THEMES_CODECOURSE, // Codecourse
  SET_COLOR_THEMES_DOWNPOUR,   // Downpour
  SET_COLOR_THEMES_FODDER,     // Fodder
  SET_COLOR_THEMES_MUD,        // Mud
  SET_COLOR_THEMES_VIOLACEOUS, // Violaceous   
  SET_COLOR_THEMES_VISION,     // Vision
};


enum SYMBOL_CHART_CHANGE_REACTION
{
  SYMBOL_CHART_CHANGE_EACH_OWN,   // Each symbol - own settings
  SYMBOL_CHART_CHANGE_HARD_RESET, // Reset to defaults on symbol change
};


enum TABS
{
  OverviewTab,
  SettingTab,
  SettingInputsEATab,
  SettingPanelEATab,
  PerformanceTab,
  GlobalMetricsTab,
  OptimizerTab,
  LogsTab,
  SecurityTab,
  PerformanceSummaryTab,
  PerformanceEquityTab,
  PerformanceDayTab,
  PerformanceWeekTab,
  PerformanceMonthTab,
  PerformanceYearTab,
  PerformanceReturnTab
};

struct Coordinates
{
  int x1;
  int y1;
  int x2;
  int y2;
};

struct Settings
{
  // panel
  SYMBOL_CHART_CHANGE_REACTION symbolchange;
  bool IsPanelMinimized;
  TABS SelectedTab;
  uint LastRecalc;
  long TimFrames;
  long Streak;
  long Condition;
  long MaxBuy;
  long MaxSell;
  long TypePositions;
  long RiskReward;
  long Expiryations;
  double RiskManagments;
  double LotSize;
  double MaximumRiskAouto;
  long InpSl;
  long SlEntry;
  long Telorance;
  long ZeroLots;
  long StrategyRisk;
  long SaveProfit;
  long SaveType;
  long SaveTrigger;
  long SaveValue;
  long Tls;
  long TlsType;
  long TlsTrigger;
  long TlsValue;
  long ComisionInOut;
  long ComisionMethod;
  double ComisionFirstInput;
  double ComisionFirstInput2;
  double ComisionFirstValue;
  double ComisionSecondInput;
  double ComisionSecondInput2;
  double ComisionSecondValue;
  long SymbolChange;
  long Minimized;
  long Privacy;
  long TesterHide;
  long TesterReport;
  long FontName;
  long Themes;
  // License
  string LoginUserID;
  string LoginExpiry;
  bool CheckVerifyLicense;
  string SHowExpiry;
  string ShowDaysLeft;
}Sets;

enum  ControlType { Label, EditText, Button, ComboBox, Progrees, Graphic, Pictur};

struct ControlLayout {
  ControlType type;
  int width;
  int height;
  int xOffset;  
  int yOffset;  
  string text;
};


struct TooltipMapping {
  int labelIndex;  // The index of the label
  string tooltip;  // Tooltip text
};

// An object class for a list of panel objects with their names for fields located on a given tab of the panel. There will be one list per tab.
class CStringForList : public CObject
{
  public:
    string      Name;
    CWnd*       Obj;
    bool        Hidden; // Used only in the Trading tab to avoid deleting the extra TPs but keep them hidden after removal.
    CStringForList() {Hidden = false;}
};

class CPanelList : public CList
{
  public:
    void DeleteListElementByName(const string name);
    void MoveListElementByName(const string name, const int index);
    void CreateListElementByName(CObject &obj, const string name);
    void SetHiddenByName(const string name, const bool hidden);
};


