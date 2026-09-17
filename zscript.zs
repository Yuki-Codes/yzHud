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
    
    Weapon m_lastWeapon;
    LinearValueInterpolator m_ammo1Interpolator;
    LinearValueInterpolator m_ammo2Interpolator;
    LinearValueInterpolator m_healthInterpolator;
    LinearValueInterpolator m_armourInterpolator;
    
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
        m_interactPrompt.Init();
        
        m_ammo1Interpolator = LinearValueInterpolator.Create(0, 3);
        m_ammo2Interpolator = LinearValueInterpolator.Create(0, 3);
        m_healthInterpolator = LinearValueInterpolator.Create(0, 3);
        m_armourInterpolator = LinearValueInterpolator.Create(0, 3);
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
            String.Format("%d", m_healthInterpolator.GetValue()),
            (-18, -20),
            DI_SCREEN_CENTER_BOTTOM | DI_TEXT_ALIGN_RIGHT,
            translation: Font.CR_Red);
            
        // Armor
        if (m_armourInterpolator.GetValue() > 0)
        {
            DrawString(
                m_smallFont,
                String.Format("%d", m_armourInterpolator.GetValue()),
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
                String.Format("%d", m_ammo1Interpolator.GetValue()),
                (18, -20),
                DI_SCREEN_CENTER_BOTTOM | DI_TEXT_ALIGN_LEFT,
                translation: Font.CR_Red);
        }
        if (am2 && am2.amount > 0)
        {
            DrawString(
                m_smallFont,
                String.Format("%d", m_ammo2Interpolator.GetValue()),
                (18, -30),
                DI_SCREEN_CENTER_BOTTOM | DI_TEXT_ALIGN_LEFT,
                translation: Font.CR_Red);
        }
        
        m_powerups.Draw(cPlayer, ticFrac, -70, -15);
        m_keys.Draw(cPlayer, ticFrac, 70, -15);
        m_interactPrompt.Draw(cPlayer, ticFrac);
    }
    
    override void Tick()
    {
        super.Tick();
        
        m_interactPrompt.Tick(cPlayer);
        
        // Update ammo interpolators
        Weapon currentWeapon = cPlayer.readyWeapon;
        let [am1, am2, am1amt, am2amt] = GetCurrentAmmo();
        
        if (currentWeapon != m_lastWeapon)
        {
            m_ammo1Interpolator = LinearValueInterpolator.Create(am1amt, 3);
            m_ammo2Interpolator = LinearValueInterpolator.Create(am2amt, 3);
            m_lastWeapon = currentWeapon;
        }
        else
        {
            m_ammo1Interpolator.Update(am1amt);
            m_ammo2Interpolator.Update(am2amt);
        }
        
        // Update helath interpolators
        m_healthInterpolator.Update(cPlayer.health);
        
        let armor = BasicArmor(CPlayer.mo.FindInventory('BasicArmor', true));
        if (armor == null)
        {
            m_armourInterpolator.Update(0);
        }
        else
        {
            m_armourInterpolator.Update(armor.amount);
        }
    }
}