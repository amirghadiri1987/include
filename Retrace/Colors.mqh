
enum ThemeType {
    Midnight_Blue,
    Periwinkle_Dream,
    Lime_Breeze,
    Autumn_Spice,
    Winter_Wonderland,
    Spring_Blossom,
    Summer_Breeze,
    Midnight_Dream,
    Tropical_Paradise,
    // Midnight_Blue,
    Forest_Green,
    Sunset_Orange,
    Calm_Pastel,
    Ocean_Breeze,
    Desert_Sand,
  Crimson_Rose,
    Cool_Mint,
    Black_Theme,
    Brown_Theme,
    White_Theme_1,
    White_Theme_2
    // Add more themes here as needed
};

    

class CThemes 
{
public:
    color   CONTROLS_BUTTON_TEXT, CONTROLS_BUTTON_ENABLE, CONTROLS_BUTTON_DISABLE,
            CONTROLS_LABEL_TEXT, CONTROLS_LABEL_BACKGROUND, CONTROLS_LABEL_TEXT_TOOLTIP, CONTROLS_LABEL_TEXT_TITLE, CONTROLS_LABEL_TITLE_BACKGROUND, CONTROLS_LABEL_TEXT_ARM, CONTROLS_LABEL_TEXT_ANSWER,
            CONTROLS_LABEL_LOG_TEXT,
            CONTROL_EDIT_TEXT, CONTROL_EDIT_BACKGROUND, CONTROL_EDIT_BORDER,
            CONTROL_COMBOBOX_BACKGROUND, CONTROL_COMBOBOX_BORDER, CONTROL_COMBOBOX_BACKGROUND_ITEM, CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL,
            CONTROL_BACK_BACGROUND, CONTROL_BORDER_BACKGROUND,
            CONTROL_CLINET, CONTROL_CLINET_BACKGROUND,
            CONTROL_CAPTION_TEXT, CONTROL_CAPTION_BACKGROUND, CONTROL_CAPTION_BORDERP,
            CONTROL_PROGRESS_BACKGROUND, CONTROL_PROGRESS_FORGROUND,
            CONTROL_LICENSE_BIGGER, CONTROL_LICENSE_SMALLER;
// CONTROLS_LABEL_TEXT_ARM
// CONTROLS_LABEL_LOG_TEXT
// CONTROLS_LABEL_TEXT_ANSWER

    virtual color               AdjustBrightness(color baseColor, double factor);
    virtual void                ApplyThemeBrightness(bool isDarkMode);
 void ApplyTheme(int theme)
 {
    switch (theme)
    {
        default:
        case Midnight_Blue:
        {
            CONTROLS_BUTTON_TEXT                = C'255,255,255';  // C'182,182,182'
            CONTROLS_BUTTON_ENABLE              = C'0,0,139';     
            CONTROLS_BUTTON_DISABLE             = C'169,169,169';  
            CONTROLS_LABEL_TEXT                 = C'224,255,255';  
            CONTROLS_LABEL_TEXT_ARM             = C'255,255,0'; 
            CONTROLS_LABEL_LOG_TEXT             = C'205,247,21'; 
            CONTROLS_LABEL_TEXT_ANSWER          = C'160,252,252'; 
            CONTROLS_LABEL_BACKGROUND           = C'0,0,139';      
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'224,255,255'; 
            CONTROLS_LABEL_TEXT_TITLE           = C'255,255,0';    
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'0,0,139';     
            CONTROL_EDIT_TEXT                   = C'255,255,255';  
            CONTROL_EDIT_BORDER                 = C'0,191,255';   
            CONTROL_EDIT_BACKGROUND             = C'0,0,139';      
            CONTROL_COMBOBOX_BACKGROUND         = C'0,0,139';      
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'255,255,0';    
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'224,255,255';  
            CONTROL_BACK_BACGROUND              = C'0,211,217';      
            CONTROL_BORDER_BACKGROUND           = C'0,191,255';    
            CONTROL_CLINET                      = C'255,255,255';  
            CONTROL_CLINET_BACKGROUND           = C'0,0,139';      
            CONTROL_CAPTION_TEXT                = C'255,255,255';  
            CONTROL_CAPTION_BACKGROUND          = C'0,0,139';      
            CONTROL_CAPTION_BORDERP             = C'0,191,255'; 
            CONTROL_PROGRESS_BACKGROUND         = C'114,235,1'; 
            CONTROL_PROGRESS_FORGROUND          = C'255,255,255'; 
            CONTROL_LICENSE_BIGGER              = C'236,184,39'; 
            CONTROL_LICENSE_SMALLER             = C'231,21,21'; 
        }
        break;

        case Periwinkle_Dream:
        {
            CONTROLS_BUTTON_TEXT                = C'78,73,73';    // White
            CONTROLS_BUTTON_ENABLE              = C'106,90,205';     // Slate Blue
            CONTROLS_BUTTON_DISABLE             = C'204,204,255';    // Periwinkle
            CONTROLS_LABEL_TEXT                 = C'26,66,245';      // Crimson
            CONTROLS_LABEL_TEXT_ARM             = C'129,79,160';
            CONTROLS_LABEL_LOG_TEXT             = C'26,194,245';
            CONTROLS_LABEL_TEXT_ANSWER          = C'88,114,231';
            CONTROLS_LABEL_BACKGROUND           = C'218,112,214';    // Orchid
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'0,128,128';      // Teal
            CONTROLS_LABEL_TEXT_TITLE           = C'43,35,48';     // Coral
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'106,90,205';     // Slate Blue
            CONTROL_EDIT_TEXT                   = C'255,255,255';    // White
            CONTROL_EDIT_BORDER                 = C'218,165,32';     // Goldenrod
            CONTROL_EDIT_BACKGROUND             = C'94,94,201';    // Periwinkle
            CONTROL_COMBOBOX_BACKGROUND         = C'94,94,201';    // Orchid
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'106,90,205';     // Slate Blue
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'255,127,80'; // Coral
            CONTROL_BACK_BACGROUND              = C'204,204,255';    // Periwinkle
            CONTROL_BORDER_BACKGROUND           = C'218,165,32';     // Goldenrod
            CONTROL_CLINET                      = C'255,255,255';    // White
            CONTROL_CLINET_BACKGROUND           = C'218,112,214';    // Orchid
            CONTROL_CAPTION_TEXT                = C'255,255,255';    // White
            CONTROL_CAPTION_BACKGROUND          = C'106,90,205';     // Slate Blue
            CONTROL_CAPTION_BORDERP             = C'0,128,128';      // Teal
        }
        break;

        case Lime_Breeze:
        {
            CONTROLS_BUTTON_TEXT                = C'0,100,0';       // Dark Green
            CONTROLS_BUTTON_ENABLE              = C'83,197,149';     // Lawn Green
            CONTROLS_BUTTON_DISABLE             = C'173,255,47';    // Green Yellow
            CONTROLS_LABEL_TEXT                 = C'50,205,50';     // Lime Green
            CONTROLS_LABEL_TEXT_ARM             = C'11,141,228';
            CONTROLS_LABEL_LOG_TEXT             = C'136,136,85';
            CONTROLS_LABEL_TEXT_ANSWER          = C'4,255,4';
            CONTROLS_LABEL_BACKGROUND           = C'240,255,240';   // Honeydew
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'154,205,50';    // Yellow Green
            CONTROLS_LABEL_TEXT_TITLE           = C'24,24,22';     // Yellow
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'124,252,0';     // Lawn Green
            CONTROL_EDIT_TEXT                   = C'85,107,47';     // Dark Olive Green
            CONTROL_EDIT_BORDER                 = C'173,255,47';    // Green Yellow
            CONTROL_EDIT_BACKGROUND             = C'240,255,240';   // Honeydew
            CONTROL_COMBOBOX_BACKGROUND         = C'124,252,0';     // Lawn Green
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'85,107,47';     // Dark Olive Green
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'255,255,0'; // Yellow
            CONTROL_BACK_BACGROUND              = C'173,255,47';    // Green Yellow
            CONTROL_BORDER_BACKGROUND           = C'85,107,47';     // Dark Olive Green
            CONTROL_CLINET                      = C'255,255,255';   // White
            CONTROL_CLINET_BACKGROUND           = C'240,255,240';   // Honeydew
            CONTROL_CAPTION_TEXT                = C'73,50,205';     // Lime Green
            CONTROL_CAPTION_BACKGROUND          = C'124,252,0';     // Lawn Green
            CONTROL_CAPTION_BORDERP             = C'154,205,50';    // Yellow Green

        }
        break;

        case Autumn_Spice:
        {
            CONTROLS_BUTTON_TEXT                = C'82,41,11';    // Saddle Brown
            CONTROLS_BUTTON_ENABLE              = C'210,105,30';   // Chocolate
            CONTROLS_BUTTON_DISABLE             = C'160,82,45';    // Sienna
            CONTROLS_LABEL_TEXT                 = C'255,228,181';  // Moccasin
            CONTROLS_LABEL_TEXT_ARM             = C'4,0,252';
            CONTROLS_LABEL_LOG_TEXT             = C'125,240,110';
            CONTROLS_LABEL_TEXT_ANSWER          = C'247,191,94';
            CONTROLS_LABEL_BACKGROUND           = C'139,69,19';    // Saddle Brown
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'255,140,0';    // Dark Orange
            CONTROLS_LABEL_TEXT_TITLE           = C'94,92,205';    // Indian Red
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'210,105,30';   // Chocolate
            CONTROL_EDIT_TEXT                   = C'255,255,255';  // White
            CONTROL_EDIT_BORDER                 = C'205,133,63';   // Peru
            CONTROL_EDIT_BACKGROUND             = C'139,69,19';    // Saddle Brown
            CONTROL_COMBOBOX_BACKGROUND         = C'210,105,30';   // Chocolate
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'255,228,181';  // Moccasin
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'139,69,19'; // Saddle Brown
            CONTROL_BACK_BACGROUND              = C'160,82,45';    // Sienna
            CONTROL_BORDER_BACKGROUND           = C'205,133,63';   // Peru
            CONTROL_CLINET                      = C'255,245,238';  // Seashell
            CONTROL_CLINET_BACKGROUND           = C'210,105,30';   // Chocolate
            CONTROL_CAPTION_TEXT                = C'139,69,19';    // Saddle Brown
            CONTROL_CAPTION_BACKGROUND          = C'255,228,181';  // Moccasin
            CONTROL_CAPTION_BORDERP             = C'205,92,92';    // Indian Red
        }
        break;

        case Winter_Wonderland:
        {
            CONTROLS_BUTTON_TEXT                = C'255,255,255';  // White
            CONTROLS_BUTTON_ENABLE              = C'70,130,180';   // Steel Blue
            CONTROLS_BUTTON_DISABLE             = C'121,168,230';  // Pale Turquoise
            CONTROLS_LABEL_TEXT                 = C'240,248,255';  // Alice Blue
            CONTROLS_LABEL_TEXT_ANSWER          = C'215,233,250';
            CONTROLS_LABEL_TEXT_ARM             = C'0,0,255';
            CONTROLS_LABEL_LOG_TEXT             = C'21,255,21';
            CONTROLS_LABEL_BACKGROUND           = C'70,130,180';   // Steel Blue
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'255,215,0';    // Gold
            CONTROLS_LABEL_TEXT_TITLE           = C'0,0,139';      // Dark Blue
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'70,130,180';   // Steel Blue
            CONTROL_EDIT_TEXT                   = C'0,0,0';        // Black
            CONTROL_EDIT_BORDER                 = C'176,224,230';  // Powder Blue
            CONTROL_EDIT_BACKGROUND             = C'151,185,216';  // Alice Blue
            CONTROL_COMBOBOX_BACKGROUND         = C'151,185,216';   // Steel Blue
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'255,255,255';  // White
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'0,0,139'; // Dark Blue
            CONTROL_BACK_BACGROUND              = C'175,238,238';  // Pale Turquoise
            CONTROL_BORDER_BACKGROUND           = C'176,224,230';  // Powder Blue
            CONTROL_CLINET                      = C'255,250,250';  // Snow
            CONTROL_CLINET_BACKGROUND           = C'70,130,180';   // Steel Blue
            CONTROL_CAPTION_TEXT                = C'255,255,255';  // White
            CONTROL_CAPTION_BACKGROUND          = C'70,130,180';   // Steel Blue
            CONTROL_CAPTION_BORDERP             = C'255,215,0';    // Gold
        }
        break;

        case Spring_Blossom:
        {
            CONTROLS_BUTTON_TEXT                = C'255,105,180';  // Hot Pink
            CONTROLS_BUTTON_ENABLE              = C'144,238,144';  // Light Green
            CONTROLS_BUTTON_DISABLE             = C'255,182,193';  // Light Pink
            CONTROLS_LABEL_TEXT                 = C'0,0,236';  // Lavender Blush
            CONTROLS_LABEL_TEXT_ARM             = C'255,20,147';
            CONTROLS_LABEL_LOG_TEXT             = C'40,223,236';
            CONTROLS_LABEL_TEXT_ANSWER          = C'109,109,236';
            CONTROLS_LABEL_BACKGROUND           = C'144,238,144';  // Light Green
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'255,69,0';     // Red Orange
            CONTROLS_LABEL_TEXT_TITLE           = C'255,20,147';   // Deep Pink
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'144,238,144';  // Light Green
            CONTROL_EDIT_TEXT                   = C'0,0,0';        // Black
            CONTROL_EDIT_BORDER                 = C'0,255,127';    // Spring Green
            CONTROL_EDIT_BACKGROUND             = C'255,228,225';  // Lavender Blush
            CONTROL_COMBOBOX_BACKGROUND         = C'144,238,144';  // Light Green
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'255,255,240';  // Ivory
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'255,20,147'; // Deep Pink
            CONTROL_BACK_BACGROUND              = C'255,182,193';  // Light Pink
            CONTROL_BORDER_BACKGROUND           = C'0,255,127';    // Spring Green
            CONTROL_CLINET                      = C'255,250,250';  // Snow
            CONTROL_CLINET_BACKGROUND           = C'144,238,144';  // Light Green
            CONTROL_CAPTION_TEXT                = C'255,105,180';  // Hot Pink
            CONTROL_CAPTION_BACKGROUND          = C'255,228,225';  // Lavender Blush
            CONTROL_CAPTION_BORDERP             = C'255,20,147';   // Deep Pink
        }
        break;

        case Summer_Breeze:
        {
            CONTROLS_BUTTON_TEXT                = C'0,0,0';        // Black
            CONTROLS_BUTTON_ENABLE              = C'0,204,102';    // Medium Sea Green
            CONTROLS_BUTTON_DISABLE             = C'192,192,192';   // Light Gray
            CONTROLS_LABEL_TEXT                 = C'0,102,204';    // Dodger Blue
            CONTROLS_LABEL_TEXT_ARM             = C'255,99,71';
            CONTROLS_LABEL_LOG_TEXT             = C'122,138,136';
            CONTROLS_LABEL_TEXT_ANSWER          = C'98,145,192';
            CONTROLS_LABEL_BACKGROUND           = C'255,255,255';  // White
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'255,69,0';     // Red Orange
            CONTROLS_LABEL_TEXT_TITLE           = C'255,99,71';    // Tomato
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'0,204,102';    // Medium Sea Green
            CONTROL_EDIT_TEXT                   = C'0,0,0';        // Black
            CONTROL_EDIT_BORDER                 = C'0,204,204';    // Turquoise
            CONTROL_EDIT_BACKGROUND             = C'255,255,255';  // White
            CONTROL_COMBOBOX_BACKGROUND         = C'0,204,102';    // Medium Sea Green
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'173,216,230';  // Light Blue
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'0,0,0'; // Black
            CONTROL_BACK_BACGROUND              = C'255,215,0';    // Gold
            CONTROL_BORDER_BACKGROUND           = C'0,204,204';    // Turquoise
            CONTROL_CLINET                      = C'255,250,205';  // Lemon Chiffon
            CONTROL_CLINET_BACKGROUND           = C'240,248,255';  // Alice Blue
            CONTROL_CAPTION_TEXT                = C'0,0,0';        // Black
            CONTROL_CAPTION_BACKGROUND          = C'173,216,230';  // Light Blue
            CONTROL_CAPTION_BORDERP             = C'255,69,0';     // Red Orange
        }
        break;


        case Midnight_Dream:
        {
            CONTROLS_BUTTON_TEXT                = C'224,102,255';  // Medium Purple
            CONTROLS_BUTTON_ENABLE              = C'75,0,130';     // Indigo
            CONTROLS_BUTTON_DISABLE             = C'138,43,226';   // Blue Violet
            CONTROLS_LABEL_TEXT                 = C'255,250,250';  // Snow
            CONTROLS_LABEL_TEXT_ARM             = C'0,49,211';
            CONTROLS_LABEL_LOG_TEXT             = C'5,248,208';
            CONTROLS_LABEL_TEXT_ANSWER          = C'250,206,206';
            CONTROLS_LABEL_BACKGROUND           = C'75,0,130';     // Indigo
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'148,0,211';    // Dark Orchid
            CONTROLS_LABEL_TEXT_TITLE           = C'186,85,211';   // Orchid
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'75,0,130';     // Indigo
            CONTROL_EDIT_TEXT                   = C'255,255,255';  // White
            CONTROL_EDIT_BORDER                 = C'123,104,238';  // Medium Slate Blue
            CONTROL_EDIT_BACKGROUND             = C'75,0,130';     // Indigo
            CONTROL_COMBOBOX_BACKGROUND         = C'75,0,130';     // Indigo
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'224,102,255';  // Medium Purple
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'255,250,250'; // Snow
            CONTROL_BACK_BACGROUND              = C'138,43,226';   // Blue Violet
            CONTROL_BORDER_BACKGROUND           = C'123,104,238';  // Medium Slate Blue
            CONTROL_CLINET                      = C'240,248,255';  // Alice Blue
            CONTROL_CLINET_BACKGROUND           = C'75,0,130';     // Indigo
            CONTROL_CAPTION_TEXT                = C'224,102,255';  // Medium Purple
            CONTROL_CAPTION_BACKGROUND          = C'255,250,250';  // Snow
            CONTROL_CAPTION_BORDERP             = C'148,0,211';    // Dark Orchid
        }
        break;

        case Tropical_Paradise:
        {
            CONTROLS_BUTTON_TEXT                = C'48,47,45';    // Gold
            CONTROLS_BUTTON_ENABLE              = C'0,255,127';    // Spring Green
            CONTROLS_BUTTON_DISABLE             = C'255,140,0';    // Dark Orange
            CONTROLS_LABEL_TEXT                 = C'255,228,196';  // Misty Rose
            CONTROLS_LABEL_TEXT_ARM             = C'0,60,255';
            CONTROLS_LABEL_LOG_TEXT             = C'131,136,153';
            CONTROLS_LABEL_TEXT_ANSWER          = C'250,207,154';
            CONTROLS_LABEL_BACKGROUND           = C'0,191,255';    // Deep Sky Blue
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'255,69,0';     // Red Orange
            CONTROLS_LABEL_TEXT_TITLE           = C'0,60,255';    // Magenta
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'0,191,255';    // Deep Sky Blue
            CONTROL_EDIT_TEXT                   = C'0,0,0';        // Black
            CONTROL_EDIT_BORDER                 = C'60,179,113';   // Medium Sea Green
            CONTROL_EDIT_BACKGROUND             = C'255,228,196';  // Misty Rose
            CONTROL_COMBOBOX_BACKGROUND         = C'0,191,255';    // Deep Sky Blue
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'255,255,224';  // Light Yellow
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'0,255,127'; // Spring Green
            CONTROL_BACK_BACGROUND              = C'255,140,0';    // Dark Orange
            CONTROL_BORDER_BACKGROUND           = C'60,179,113';   // Medium Sea Green
            CONTROL_CLINET                      = C'255,250,250';  // Snow
            CONTROL_CLINET_BACKGROUND           = C'0,191,255';    // Deep Sky Blue
            CONTROL_CAPTION_TEXT                = C'41,138,230';    // Gold
            CONTROL_CAPTION_BACKGROUND          = C'255,228,196';  // Misty Rose
            CONTROL_CAPTION_BORDERP             = C'255,69,0';     // Red Orange
        }
        break;

        case Forest_Green:
        {
            CONTROLS_BUTTON_TEXT                = C'240,255,240';  // Honeydew
            CONTROLS_BUTTON_ENABLE              = C'34,139,34';    // Forest Green
            CONTROLS_BUTTON_DISABLE             = C'120,128,105';   // Olive Green
            CONTROLS_LABEL_TEXT                 = C'245,245,220';  // Beige
            CONTROLS_LABEL_TEXT_ARM             = C'173,255,47';
            CONTROLS_LABEL_LOG_TEXT             = C'118,170,238';
            CONTROLS_LABEL_TEXT_ANSWER          = C'250,250,185';
            CONTROLS_LABEL_BACKGROUND           = C'34,139,34';    // Forest Green
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'255,255,240';  // Ivory
            CONTROLS_LABEL_TEXT_TITLE           = C'173,255,47';   // Light Green
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'34,139,34';    // Forest Green
            CONTROL_EDIT_TEXT                   = C'240,255,240';  // Honeydew
            CONTROL_EDIT_BORDER                 = C'0,100,0';      // Dark Green
            CONTROL_EDIT_BACKGROUND             = C'107,142,35';   // Olive Green
            CONTROL_COMBOBOX_BACKGROUND         = C'34,139,34';    // Forest Green
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'173,255,47';   // Light Green
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'255,255,240';  // Ivory
            CONTROL_BACK_BACGROUND              = C'107,142,35';   // Olive Green
            CONTROL_BORDER_BACKGROUND           = C'0,100,0';      // Dark Green
            CONTROL_CLINET                      = C'255,255,255';  // White
            CONTROL_CLINET_BACKGROUND           = C'34,139,34';    // Forest Green
            CONTROL_CAPTION_TEXT                = C'255,255,240';  // Ivory
            CONTROL_CAPTION_BACKGROUND          = C'34,139,34';    // Forest Green
            CONTROL_CAPTION_BORDERP             = C'0,100,0';
        }
        break;

        case Sunset_Orange:
        {
            CONTROLS_BUTTON_TEXT                = C'255,255,255';  // White
            CONTROLS_BUTTON_ENABLE              = C'255,69,0';     // Orange Red
            CONTROLS_BUTTON_DISABLE             = C'139,0,0';      // Dark Red
            CONTROLS_LABEL_TEXT                 = C'255,228,181';  // Light Beige
            CONTROLS_LABEL_TEXT_ARM             = C'255,255,0'; 
            CONTROLS_LABEL_LOG_TEXT             = C'179,163,114'; 
            CONTROLS_LABEL_TEXT_ANSWER          = C'252,213,147';
            CONTROLS_LABEL_BACKGROUND           = C'255,140,0';    // Dark Orange
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'255,165,0';    // Orange
            CONTROLS_LABEL_TEXT_TITLE           = C'255,255,0';    // Bright Yellow
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'255,140,0';    // Dark Orange
            CONTROL_EDIT_TEXT                   = C'255,255,255';  // White
            CONTROL_EDIT_BORDER                 = C'255,69,0';     // Orange Red
            CONTROL_EDIT_BACKGROUND             = C'139,0,0';      // Dark Red
            CONTROL_COMBOBOX_BACKGROUND         = C'255,140,0';    // Dark Orange
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'255,255,0';    // Bright Yellow
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'255,228,181';  // Light Beige
            CONTROL_BACK_BACGROUND              = C'255,69,0';     // Orange Red
            CONTROL_BORDER_BACKGROUND           = C'139,0,0';      // Dark Red
            CONTROL_CLINET                      = C'255,255,255';  // White
            CONTROL_CLINET_BACKGROUND           = C'255,140,0';    // Dark Orange
            CONTROL_CAPTION_TEXT                = C'255,255,255';  // White
            CONTROL_CAPTION_BACKGROUND          = C'255,140,0';    // Dark Orange
            CONTROL_CAPTION_BORDERP             = C'255,69,0';
        }
        break;

        case Calm_Pastel:
        {
            CONTROLS_BUTTON_TEXT                = C'0,0,0';        // Black
            CONTROLS_BUTTON_ENABLE              = C'255,182,193';  // Light Pink
            CONTROLS_BUTTON_DISABLE             = C'176,224,230';  // Powder Blue
            CONTROLS_LABEL_TEXT                 = C'19,80,248';  // Medium Aquamarine
            CONTROLS_LABEL_TEXT_ARM             = C'250,128,114';
            CONTROLS_LABEL_LOG_TEXT             = C'137,250,114';
            CONTROLS_LABEL_TEXT_ANSWER          = C'97,138,250';
            CONTROLS_LABEL_BACKGROUND           = C'255,228,196';  // Pastel Peach
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'255,218,185';  // Peach Puff
            CONTROLS_LABEL_TEXT_TITLE           = C'250,128,114';  // Salmon
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'255,228,196';  // Pastel Peach
            CONTROL_EDIT_TEXT                   = C'0,0,0';        // Black
            CONTROL_EDIT_BORDER                 = C'139,182,231';  // Powder Blue
            CONTROL_EDIT_BACKGROUND             = C'255,228,196';  // Pastel Peach
            CONTROL_COMBOBOX_BACKGROUND         = C'255,228,196';  // Pastel Peach
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'255,218,185';  // Peach Puff
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'102,205,170';  // Medium Aquamarine
            CONTROL_BACK_BACGROUND              = C'255,228,196';  // Pastel Peach
            CONTROL_BORDER_BACKGROUND           = C'255,182,193';  // Light Pink
            CONTROL_CLINET                      = C'0,0,0';        // Black
            CONTROL_CLINET_BACKGROUND           = C'255,228,196';  // Pastel Peach
            CONTROL_CAPTION_TEXT                = C'0,0,0';        // Black
            CONTROL_CAPTION_BACKGROUND          = C'255,228,196';  // Pastel Peach
            CONTROL_CAPTION_BORDERP             = C'255,182,193';
        }
        break;

        case Ocean_Breeze:
        {
            CONTROLS_BUTTON_TEXT                = C'255,255,255';  // White
            CONTROLS_BUTTON_ENABLE              = C'0,105,148';    // Deep Sea Blue
            CONTROLS_BUTTON_DISABLE             = C'100,149,237';  // Cornflower Blue
            CONTROLS_LABEL_TEXT                 = C'240,255,255';  // Azure
            CONTROLS_LABEL_TEXT_ARM             = C'173,216,230';
            CONTROLS_LABEL_LOG_TEXT             = C'173,216,230';
            CONTROLS_LABEL_TEXT_ANSWER          = C'117,255,225';
            CONTROLS_LABEL_BACKGROUND           = C'70,130,180';   // Steel Blue
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'255,255,240';  // Ivory
            CONTROLS_LABEL_TEXT_TITLE           = C'173,216,230';  // Light Blue
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'0,105,148';    // Deep Sea Blue
            CONTROL_EDIT_TEXT                   = C'255,255,255';  // White
            CONTROL_EDIT_BORDER                 = C'100,149,237';  // Cornflower Blue
            CONTROL_EDIT_BACKGROUND             = C'0,105,148';    // Deep Sea Blue
            CONTROL_COMBOBOX_BACKGROUND         = C'70,130,180';   // Steel Blue
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'173,216,230';  // Light Blue
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'240,255,255';  // Azure
            CONTROL_BACK_BACGROUND              = C'0,105,148';    // Deep Sea Blue
            CONTROL_BORDER_BACKGROUND           = C'70,130,180';   // Steel Blue
            CONTROL_CLINET                      = C'255,255,255';  // White
            CONTROL_CLINET_BACKGROUND           = C'0,105,148';    // Deep Sea Blue
            CONTROL_CAPTION_TEXT                = C'255,255,255';  // White
            CONTROL_CAPTION_BACKGROUND          = C'0,105,148';    // Deep Sea Blue
            CONTROL_CAPTION_BORDERP             = C'100,149,237';
        }
        break;

        case Desert_Sand:
        {
            CONTROLS_BUTTON_TEXT                = C'139,69,19';    // Saddle Brown
            CONTROLS_BUTTON_ENABLE              = C'210,180,140';  // Tan
            CONTROLS_BUTTON_DISABLE             = C'244,164,96';   // Sandy Brown
            CONTROLS_LABEL_TEXT                 = C'255,228,181';  // Moccasin
            CONTROLS_LABEL_TEXT_ARM             = C'82,80,78';
            CONTROLS_LABEL_LOG_TEXT             = C'183,189,129';
            CONTROLS_LABEL_TEXT_ANSWER          = C'253,244,227';
            CONTROLS_LABEL_BACKGROUND           = C'210,180,140';  // Tan
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'255,235,205';  // Blanched Almond
            CONTROLS_LABEL_TEXT_TITLE           = C'82,80,78';   // Sandy Brown
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'139,69,19';    // Saddle Brown
            CONTROL_EDIT_TEXT                   = C'139,69,19';    // Saddle Brown
            CONTROL_EDIT_BORDER                 = C'117,113,110';   // Sandy Brown
            CONTROL_EDIT_BACKGROUND             = C'255,228,181';  // Moccasin
            CONTROL_COMBOBOX_BACKGROUND         = C'210,180,140';  // Tan
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'255,235,205';  // Blanched Almond
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'244,164,96';  // Sandy Brown
            CONTROL_BACK_BACGROUND              = C'139,69,19';    // Saddle Brown
            CONTROL_BORDER_BACKGROUND           = C'210,180,140';  // Tan
            CONTROL_CLINET                      = C'139,69,19';    // Saddle Brown
            CONTROL_CLINET_BACKGROUND           = C'210,180,140';  // Tan
            CONTROL_CAPTION_TEXT                = C'54,100,228';  // Moccasin
            CONTROL_CAPTION_BACKGROUND          = C'210,180,140';  // Tan
            CONTROL_CAPTION_BORDERP             = C'244,164,96';
        }
        break;

        case Crimson_Rose:
        {
            CONTROLS_BUTTON_TEXT                = C'255,255,255';  // White
            CONTROLS_BUTTON_ENABLE              = C'220,20,60';    // Crimson
            CONTROLS_BUTTON_DISABLE             = C'216,141,182';  // Light Pink
            CONTROLS_LABEL_TEXT                 = C'255,240,245';  // Lavender Blush
            CONTROLS_LABEL_TEXT_ARM             = C'255,69,0';
            CONTROLS_LABEL_LOG_TEXT             = C'0,217,255';
            CONTROLS_LABEL_TEXT_ANSWER          = C'250,201,217';
            CONTROLS_LABEL_BACKGROUND           = C'255,105,180';  // Hot Pink
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'255,182,193';  // Light Pink
            CONTROLS_LABEL_TEXT_TITLE           = C'255,69,0';     // Orange Red
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'220,20,60';    // Crimson
            CONTROL_EDIT_TEXT                   = C'255,255,255';  // White
            CONTROL_EDIT_BORDER                 = C'255,105,180';  // Hot Pink
            CONTROL_EDIT_BACKGROUND             = C'255,69,0';     // Orange Red
            CONTROL_COMBOBOX_BACKGROUND         = C'220,20,60';    // Crimson
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'255,182,193';  // Light Pink
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'255,240,245';  // Lavender Blush
            CONTROL_BACK_BACGROUND              = C'255,69,0';     // Orange Red
            CONTROL_BORDER_BACKGROUND           = C'255,105,180';  // Hot Pink
            CONTROL_CLINET                      = C'255,255,255';  // White
            CONTROL_CLINET_BACKGROUND           = C'255,105,180';  // Hot Pink
            CONTROL_CAPTION_TEXT                = C'255,255,255';  // White
            CONTROL_CAPTION_BACKGROUND          = C'255,69,0';     // Orange Red
            CONTROL_CAPTION_BORDERP             = C'220,20,60';
        }
        break;

        case Cool_Mint:
        {
            CONTROLS_BUTTON_TEXT                = C'0,100,0';      // Dark Green
            CONTROLS_BUTTON_ENABLE              = C'0,245,0';  // Pale Green
            CONTROLS_BUTTON_DISABLE             = C'0,250,154';    // Medium Spring Green
            CONTROLS_LABEL_TEXT                 = C'165,84,46';  // Mint Cream
            CONTROLS_LABEL_TEXT_ARM             = C'25,106,199';
            CONTROLS_LABEL_LOG_TEXT             = C'25,199,63';
            CONTROLS_LABEL_TEXT_ANSWER          = C'165,84,46';
            CONTROLS_LABEL_BACKGROUND           = C'152,251,152';  // Pale Green
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'245,255,250';  // Mint Cream
            CONTROLS_LABEL_TEXT_TITLE           = C'25,106,199';      // Green
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'0,250,154';    // Medium Spring Green
            CONTROL_EDIT_TEXT                   = C'0,100,0';      // Dark Green
            CONTROL_EDIT_BORDER                 = C'70,100,89';    // Medium Spring Green
            CONTROL_EDIT_BACKGROUND             = C'245,255,250';  // Mint Cream
            CONTROL_COMBOBOX_BACKGROUND         = C'152,251,152';  // Pale Green
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'0,250,154';    // Medium Spring Green
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'0,100,0';  // Dark Green
            CONTROL_BACK_BACGROUND              = C'0,250,154';    // Medium Spring Green
            CONTROL_BORDER_BACKGROUND           = C'152,251,152';  // Pale Green
            CONTROL_CLINET                      = C'0,100,0';      // Dark Green
            CONTROL_CLINET_BACKGROUND           = C'152,251,152';  // Pale Green
            CONTROL_CAPTION_TEXT                = C'0,100,0';      // Dark Green
            CONTROL_CAPTION_BACKGROUND          = C'152,251,152';  // Pale Green
            CONTROL_CAPTION_BORDERP             = C'0,250,154';
        }
        break;

        case Black_Theme:
        {
            CONTROLS_BUTTON_TEXT                = C'255,255,255';  // White
            CONTROLS_BUTTON_ENABLE              = C'50,50,50';     // Dark Gray
            CONTROLS_BUTTON_DISABLE             = C'128,128,128';  // Gray
            CONTROLS_LABEL_TEXT                 = C'255,255,255';  // White
            CONTROLS_LABEL_TEXT_ARM             = C'255,215,0';
            CONTROLS_LABEL_LOG_TEXT             = C'255,166,0';
            CONTROLS_LABEL_TEXT_ANSWER          = C'252,204,204';
            CONTROLS_LABEL_BACKGROUND           = C'0,0,0';        // Black
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'255,69,0';     // Red Orange
            CONTROLS_LABEL_TEXT_TITLE           = C'255,215,0';    // Gold
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'50,50,50';     // Dark Gray
            CONTROL_EDIT_TEXT                   = C'255,255,255';  // White
            CONTROL_EDIT_BORDER                 = C'128,128,128';  // Gray
            CONTROL_EDIT_BACKGROUND             = C'30,30,30';     // Darker Gray
            CONTROL_COMBOBOX_BACKGROUND         = C'50,50,50';     // Dark Gray
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'180,171,171';     // Darker Gray
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'255,255,255'; // White
            CONTROL_BACK_BACGROUND              = C'128,128,128';        // Black
            CONTROL_BORDER_BACKGROUND           = C'128,128,128';  // Gray
            CONTROL_CLINET                      = C'50,50,50';     // Dark Gray
            CONTROL_CLINET_BACKGROUND           = C'30,30,30';     // Darker Gray
            CONTROL_CAPTION_TEXT                = C'255,255,255';  // White
            CONTROL_CAPTION_BACKGROUND          = C'0,0,0';        // Black
            CONTROL_CAPTION_BORDERP             = C'255,215,0';    // Gold
        }
        break;

        case Brown_Theme:
        {
            CONTROLS_BUTTON_TEXT                = C'255,255,255';  // White
            CONTROLS_BUTTON_ENABLE              = C'139,69,19';    // Saddle Brown
            CONTROLS_BUTTON_DISABLE             = C'218,161,76';    // Sienna
            CONTROLS_LABEL_TEXT                 = C'255,228,181';  // Moccasin
            CONTROLS_LABEL_BACKGROUND           = C'139,69,19';    // Saddle Brown
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'255,140,0';     // Dark Orange
            CONTROLS_LABEL_TEXT_TITLE           = C'92,94,205';    // Indian Red
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'210,105,30';   // Chocolate
            CONTROL_EDIT_TEXT                   = C'255,255,255';  // White
            CONTROL_EDIT_BORDER                 = C'205,133,63';   // Peru
            CONTROL_EDIT_BACKGROUND             = C'139,69,19';    // Saddle Brown
            CONTROL_COMBOBOX_BACKGROUND         = C'210,105,30';   // Chocolate
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'255,228,181';  // Moccasin
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'139,69,19'; // Saddle Brown
            CONTROL_BACK_BACGROUND              = C'160,82,45';    // Sienna
            CONTROL_BORDER_BACKGROUND           = C'205,133,63';   // Peru
            CONTROL_CLINET                      = C'255,245,238';  // Seashell
            CONTROL_CLINET_BACKGROUND           = C'210,105,30';   // Chocolate
            CONTROL_CAPTION_TEXT                = C'255,255,255';  // White
            CONTROL_CAPTION_BACKGROUND          = C'139,69,19';    // Saddle Brown
            CONTROL_CAPTION_BORDERP             = C'205,92,92';    // Indian Red
        }
        break;

        case White_Theme_1:
        {
            CONTROLS_BUTTON_TEXT                = C'0,0,0';        // Black
            CONTROLS_BUTTON_ENABLE              = C'220,220,220';  // Light Gray
            CONTROLS_BUTTON_DISABLE             = C'192,192,192';  // Gray
            CONTROLS_LABEL_TEXT                 = C'0,0,0';        // Black
            CONTROLS_LABEL_TEXT_ARM             = C'0,102,204';
            CONTROLS_LABEL_LOG_TEXT             = C'0,180,204';
            CONTROLS_LABEL_TEXT_ANSWER          = C'83,82,82';
            CONTROLS_LABEL_BACKGROUND           = C'255,255,255';  // White
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'255,69,0';     // Red Orange
            CONTROLS_LABEL_TEXT_TITLE           = C'0,102,204';    // Dodger Blue
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'220,220,220';  // Light Gray
            CONTROL_EDIT_TEXT                   = C'0,0,0';        // Black
            CONTROL_EDIT_BORDER                 = C'192,192,192';  // Gray
            CONTROL_EDIT_BACKGROUND             = C'255,255,255';  // White
            CONTROL_COMBOBOX_BACKGROUND         = C'220,220,220';  // Light Gray
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'255,255,255';  // White
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'0,0,0'; // Black
            CONTROL_BACK_BACGROUND              = C'255,255,255';  // White
            CONTROL_BORDER_BACKGROUND           = C'192,192,192';  // Gray
            CONTROL_CLINET                      = C'255,250,205';  // Lemon Chiffon
            CONTROL_CLINET_BACKGROUND           = C'255,255,255';  // White
            CONTROL_CAPTION_TEXT                = C'0,0,0';        // Black
            CONTROL_CAPTION_BACKGROUND          = C'220,220,220';  // Light Gray
            CONTROL_CAPTION_BORDERP             = C'255,69,0';     // Red Orange
        }
        break;

        case White_Theme_2:
        {
            CONTROLS_BUTTON_TEXT                = C'0,0,0';        // Black
            CONTROLS_BUTTON_ENABLE              = C'240,240,240';  // Very Light Gray
            CONTROLS_BUTTON_DISABLE             = C'192,192,192';  // Gray
            CONTROLS_LABEL_TEXT                 = C'0,0,0';        // Black
            CONTROLS_LABEL_TEXT_ARM             = C'0,102,204';
            CONTROLS_LABEL_LOG_TEXT             = C'240,113,176';
            CONTROLS_LABEL_TEXT_ANSWER          = C'83,82,82';
            CONTROLS_LABEL_BACKGROUND           = C'255,255,255';  // White
            CONTROLS_LABEL_TEXT_TOOLTIP         = C'255,140,0';    // Dark Orange
            CONTROLS_LABEL_TEXT_TITLE           = C'0,102,204';    // Dodger Blue
            CONTROLS_LABEL_TITLE_BACKGROUND     = C'240,240,240';  // Very Light Gray
            CONTROL_EDIT_TEXT                   = C'0,0,0';        // Black
            CONTROL_EDIT_BORDER                 = C'192,192,192';  // Gray
            CONTROL_EDIT_BACKGROUND             = C'255,255,255';  // White
            CONTROL_COMBOBOX_BACKGROUND         = C'240,240,240';  // Very Light Gray
            CONTROL_COMBOBOX_BACKGROUND_ITEM    = C'255,255,255';  // White
            CONTROL_COMBOBOX_BACKGROUND_ITEM_TEXT_SELL = C'0,0,0'; // Black
            CONTROL_BACK_BACGROUND              = C'255,255,255';  // White
            CONTROL_BORDER_BACKGROUND           = C'192,192,192';  // Gray
            CONTROL_CLINET                      = C'240,248,255';  // Alice Blue
            CONTROL_CLINET_BACKGROUND           = C'255,255,255';  // White
            CONTROL_CAPTION_TEXT                = C'0,0,0';        // Black
            CONTROL_CAPTION_BACKGROUND          = C'240,240,240';  // Very Light Gray
            CONTROL_CAPTION_BORDERP             = C'255,140,0';    // Dark Orange
        }
        break;

    }

 }   
};

// Function to adjust brightness of a color
color CThemes::AdjustBrightness(color baseColor, double factor) {
    // Extract the RGB components using bitwise operations
    int r = int(((baseColor >> 16) & 0xFF) * factor);
    int g = int(((baseColor >> 8) & 0xFF) * factor);
    int b = int((baseColor & 0xFF) * factor);

    // Ensure the color values are within the valid range (0-255)
    r = MathMin(r, 255);
    g = MathMin(g, 255);
    b = MathMin(b, 255);

    // Combine the adjusted RGB values back into a color
    return (color)((r << 16) | (g << 8) | b);
}

// Example usage
/*
void CThemes::ApplyThemeBrightness(bool isDarkMode) {
    
    double factor = isDarkMode ? 0.8 : 1.2; // Adjust factor for dark/light mode
    // Adjust brightness for each color attribute
    CONTROLS_BUTTON_TEXT                = AdjustBrightness(CONTROLS_BUTTON_TEXT, factor);
    CONTROLS_BUTTON_ENABLE              = AdjustBrightness(CONTROLS_BUTTON_ENABLE, factor);
    CONTROLS_BUTTON_DISABLE             = AdjustBrightness(CONTROLS_BUTTON_DISABLE, factor);
    CONTROLS_LABEL_TEXT                 = AdjustBrightness(CONTROLS_LABEL_TEXT, factor);
    CONTROLS_LABEL_BACKGROUND           = AdjustBrightness(CONTROLS_LABEL_BACKGROUND, factor);
    CONTROLS_LABEL_TEXT_TOOLTIP         = AdjustBrightness(CONTROLS_LABEL_TEXT_TOOLTIP, factor);
    CONTROLS_LABEL_TEXT_TITLE           = AdjustBrightness(CONTROLS_LABEL_TEXT_TITLE, factor);
    CONTROLS_LABEL_TITLE_BACKGROUND     = AdjustBrightness(CONTROLS_LABEL_TITLE_BACKGROUND, factor);
    CONTROL_EDIT_TEXT                   = AdjustBrightness(CONTROL_EDIT_TEXT, factor);
    CONTROL_EDIT_BACKGROUND             = AdjustBrightness(CONTROL_EDIT_BACKGROUND, factor);
    CONTROL_EDIT_BORDER                 = AdjustBrightness(CONTROL_EDIT_BORDER, factor);
    CONTROL_COMBOBOX_BACKGROUND         = AdjustBrightness(CONTROL_COMBOBOX_BACKGROUND, factor);
    CONTROL_COMBOBOX_BACKGROUND_ITEM    = AdjustBrightness(CONTROL_COMBOBOX_BACKGROUND_ITEM, factor);
    CONTROL_BACK_BACGROUND              = AdjustBrightness(CONTROL_BACK_BACGROUND, factor);
    CONTROL_BORDER_BACKGROUND           = AdjustBrightness(CONTROL_BORDER_BACKGROUND, factor);
    CONTROL_CLINET                      = AdjustBrightness(CONTROL_CLINET, factor);
    CONTROL_CLINET_BACKGROUND           = AdjustBrightness(CONTROL_CLINET_BACKGROUND, factor);
    CONTROL_CAPTION_TEXT                = AdjustBrightness(CONTROL_CAPTION_TEXT, factor);
    CONTROL_CAPTION_BACKGROUND          = AdjustBrightness(CONTROL_CAPTION_BACKGROUND, factor);
    CONTROL_CAPTION_BORDERP             = AdjustBrightness(CONTROL_CAPTION_BORDERP, factor);

    Print("Theme brightness adjusted for ", isDarkMode ? "dark mode" : "light mode");
}