version "5.00"

#include "PowerupBar.zs"
#include "KeyBar.zs"
#include "InteractPrompt.zs"

class YzHud : BaseStatusBar
{
    PowerupBar m_powerups;
    KeyBar m_keys;
    InteractPrompt m_interactPrompt;
    
    HUDFont m_bigFont;
    HUDFont m_smallFont;
    
    override void Init()
    {
        super.Init();
        m_bigFont = HUDFont.Create(Font.FindFont('BigFont'));
        m_smallFont = HUDFont.Create(Font.FindFont('SmallFont'));
        
        m_powerups = new("PowerupBar");
        m_powerups.m_hud = self;
        m_powerups.m_font = m_smallFont;
        
        m_keys = new("KeyBar");
        m_keys.m_hud = self;
        m_keys.m_font = m_smallFont;
        
        m_interactPrompt = new("InteractPrompt");
        m_interactPrompt.m_hud = self;
        m_interactPrompt.m_font = m_smallFont;
    }

    override void Draw(int state, double ticFrac)
    {
        super.Draw(state, TicFrac);
        if (state != HUD_Fullscreen)
        {
            return;
        }

        BeginHUD();
        
        // BG Shade
        DrawTexture(
            TexMan.CheckForTexture("shade"),
            (0, 0),
            DI_SCREEN_CENTER_BOTTOM | DI_ITEM_CENTER_BOTTOM);
        
        // Mugshot
        DrawTexture(
            GetMugShot(5),
            (0, -5),
            DI_SCREEN_CENTER_BOTTOM | DI_ITEM_CENTER_BOTTOM);

        // Health
        DrawString(
            m_bigFont,
            String.Format("%d", CPlayer.health),
            (-18, -20),
            DI_SCREEN_CENTER_BOTTOM | DI_TEXT_ALIGN_RIGHT,
            translation: Font.CR_Red);
            
        // Armor
        let armor = BasicArmor(CPlayer.mo.FindInventory('BasicArmor', true));
        if (armor && armor.amount > 0)
        {
            DrawString(
                m_smallFont,
                String.Format("%d", armor.amount),
                (-18, -30),
                DI_SCREEN_CENTER_BOTTOM | DI_TEXT_ALIGN_RIGHT,
                translation: Font.CR_Red);
        }
        
        // Ammo
        let [am1, am2, am1amt, am2amt] = GetCurrentAmmo();
        if (am1)
        {
            DrawString(
                m_bigFont,
                String.Format("%d", am1amt),
                (18, -20),
                DI_SCREEN_CENTER_BOTTOM | DI_TEXT_ALIGN_LEFT,
                translation: Font.CR_Red);
        }
        if (am2 && am2.amount > 0)
        {
            DrawString(
                m_smallFont,
                String.Format("%d", am2amt),
                (18, -30),
                DI_SCREEN_CENTER_BOTTOM | DI_TEXT_ALIGN_LEFT,
                translation: Font.CR_Red);
        }
        
        m_powerups.Draw(cPlayer, ticFrac, -70, -15);
        m_keys.Draw(cPlayer, ticFrac, 70, -15);
        m_interactPrompt.Draw(cPlayer, ticFrac);
    }
}