
class ColorThemes
{
public:
    
    color CONTROLS_EDIT_ENABLE_COLOR, CONTROLS_EDIT_DISABLE_COLOR, CONTROLS_EDIT_BORDER_COLOR, CONTROLS_EDIT_BACKGROUND_COLOR, CONTROLS_BUTTON_ENABLE_COLOR,
          CONTROLS_BUTTON_DISABLE_COLOR, CONTROLS_BUTTON_TEXT_COLOR, CONTROLS_BUTTON_BORDER_COLOR, CONTROLS_BUTTON_BACKGROUND_COLOR, CONTROLS_BORDER_COLOR,
          CONTROLS_BACK_COLOR, CONTROLS_CLIENTBACK_COLOR, CONTROLS_CAPTION_TEXT_COLOR, CONTROLS_CAPTION_MAIN_BACKGROUND_COLOR, CONTROLS_CAPTION_BACK_BACKGROUND_COLOR,
          CONTROLS_LABEL_TEXT_COLOR, CONTROLS_LABEL_TEXT_CAPION_COLOR, CONTROLS_LABEL_TEXT_TITLE_COLOR, CONTROLS_LABEL_TEXT_CONFIRMATION_COLOR, CONTROLS_PICTURE_BORDER_COLOR;
   
    // enum SET_COLOR_THEMES
    // {
    //    SET_COLOR_THEMES_ABSENT,
    //    SET_COLOR_THEMES_BANNER,
    //    SET_COLOR_THEMES_BRAVE,
    //    SET_COLOR_THEMES_BLINK,
    //    SET_COLOR_THEMES_CODECOURSE,
    //    SET_COLOR_THEMES_DOWNPOUR,
    //    SET_COLOR_THEMES_FODDER,
    //    SET_COLOR_THEMES_MUD,
    //    SET_COLOR_THEMES_VIOLACEOUS,
    //    SET_COLOR_THEMES_VISION,
    // };

    // enum TYPE_THEMES
    // {
    //     Dark,
    //     Light
    // };
    
    void ApplyTheme(int theme,int type)
    {
        switch (theme)
        {
        default:    
        case SET_COLOR_THEMES_VISION:
            
            if (type == Light)
            {
                CONTROLS_EDIT_ENABLE_COLOR              = C'255,255,255';
                CONTROLS_EDIT_DISABLE_COLOR             = C'255,255,255';
                CONTROLS_EDIT_BORDER_COLOR              = C'255,255,255';
                CONTROLS_EDIT_BACKGROUND_COLOR          = C'255,255,255';

                CONTROLS_BUTTON_ENABLE_COLOR            = C'161,212,236';   //.
                CONTROLS_BUTTON_DISABLE_COLOR           = C'255,255,255';
                CONTROLS_BUTTON_TEXT_COLOR              = C'53,47,212';     //.
                CONTROLS_BUTTON_BORDER_COLOR            = C'40,40,41';      //.
                CONTROLS_BUTTON_BACKGROUND_COLOR        = C'255,255,255';   //.

                CONTROLS_BORDER_COLOR                   = C'174,170,185';   //.
                CONTROLS_BACK_COLOR                     = clrBlue;      //.
                CONTROLS_CLIENTBACK_COLOR               = C'255,255,255';   //.

                CONTROLS_CAPTION_TEXT_COLOR             = C'12,12,12';      //.
                CONTROLS_CAPTION_MAIN_BACKGROUND_COLOR  = C'189,172,238';   //.
                CONTROLS_CAPTION_BACK_BACKGROUND_COLOR  = C'165,243,19';    //.

                CONTROLS_LABEL_TEXT_COLOR               = C'12,12,12';      //.
                CONTROLS_LABEL_TEXT_CAPION_COLOR        = C'53,47,212';     //.
                CONTROLS_LABEL_TEXT_TITLE_COLOR         = C'0,8,210';       //.

                CONTROLS_LABEL_TEXT_CONFIRMATION_COLOR  = C'25,140,25';     //.

                CONTROLS_PICTURE_BORDER_COLOR           = C'25,140,25';     //.
                
            }
            else
            {
                CONTROLS_EDIT_ENABLE_COLOR              = C'255,255,255';
                CONTROLS_EDIT_DISABLE_COLOR             = C'255,255,255';
                CONTROLS_EDIT_BORDER_COLOR              = C'255,255,255';
                CONTROLS_EDIT_BACKGROUND_COLOR          = C'255,255,255';

                CONTROLS_BUTTON_ENABLE_COLOR            = C'255,255,255';
                CONTROLS_BUTTON_DISABLE_COLOR           = C'255,255,255';
                CONTROLS_BUTTON_TEXT_COLOR              = C'255,255,255';
                CONTROLS_BUTTON_BORDER_COLOR            = C'255,255,255';
                CONTROLS_BUTTON_BACKGROUND_COLOR        = C'255,255,255';

                CONTROLS_BORDER_COLOR                   = C'255,255,255';
                CONTROLS_BACK_COLOR                     = C'255,255,255';
                CONTROLS_CLIENTBACK_COLOR               = C'85,111,228';

                CONTROLS_CAPTION_TEXT_COLOR             = C'255,255,255';
                CONTROLS_CAPTION_MAIN_BACKGROUND_COLOR  = C'255,255,255';
                CONTROLS_CAPTION_BACK_BACKGROUND_COLOR  = C'255,255,255';
                CONTROLS_LABEL_TEXT_TITLE_COLOR         = C'255,255,255';     

                CONTROLS_LABEL_TEXT_COLOR               = C'255,255,255';
                CONTROLS_LABEL_TEXT_CAPION_COLOR        = C'255,255,255';

                CONTROLS_LABEL_TEXT_CONFIRMATION_COLOR  = C'255,255,255';

                CONTROLS_PICTURE_BORDER_COLOR           = C'255,255,255';
            }
            
        break;

        
        }
    }
};

/*
CCTR_EDIT_EN_COL         = C'64,240,102';
      CCTR_EDIT_DIS_COL        = C'238,182,182';
      CCTR_EDIT_BOR_COL        = C'248,5,5';
      CCTR_EDIT_BG_COL         = C'39,51,231';

      CCTR_BUTTON_EN_COL       = C'161,212,236';   //.
      CCTR_BUTTON_DIS_COL      = C'255,255,255';
      CCTR_BUTTON_TXT_COL      = C'0,165,243';     //
      CCTR_BUTTON_BOR_COL      = C'40,40,41';      //
      CCTR_BUTTON_BG_COL       = C'255,255,255';   // 

      CCTR_BOR_COL             = C'174,170,185';
      CCTR_BACK_COL            = C'65,64,64';
      CCTR_CLIENTBACK_COL      = C'255,255,255';

      CCTR_CAP_TXT_COL         = C'12,12,12';      //
      CCTR_CAP_MAIN_BG_COL     = C'189,172,238';   //
      CCTR_CAP_BACK_BG_COL     = C'165,243,19';    //

      CCTR_LBL_TXT_COL         = C'12,12,12';    //    
      CCTR_LBL_TXT_CAP_COL     = C'0,165,243';         

      
ColorThemes myThemes;

// Apply the SET_COLOR_THEMES_VISION theme
myThemes.ApplyTheme(SET_COLOR_THEMES_VISION);

// Access individual color properties if needed
color editEnCol = myThemes.CCTR_EDIT_EN_COL;
color buttonTxtCol = myThemes.CCTR_BUTTON_TXT_COL;

// Apply the SET_COLOR_THEMES_BANNER theme
myThemes.ApplyTheme(SET_COLOR_THEMES_BANNER);
