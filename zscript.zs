version "5.00"

#include "PowerupBar.zs"
#include "KeyBar.zs"
#include "InteractPrompt.zs"
#include "InteractHighlight.zs"
#include "WeaponsList.zs"
#include "BossBar.zs"

class YzHud : BaseStatusBar
{
    PowerupBar m_powerups;

    HUDFont m_bigFont;
    HUDFont m_smallFont;

    Weapon m_lastWeapon;
    Interpolator m_ammo1Interpolator;
    Interpolator m_ammo2Interpolator;
    Interpolator m_healthInterpolator;
    Interpolator m_armourInterpolator;
    private ui float m_prevDrawTime;

    override void Init()
    {
        super.Init();
        m_bigFont = HUDFont.Create(Font.FindFont('BigFont'));
        m_smallFont = HUDFont.Create(Font.FindFont('SmallFont'));

        m_powerups = new("PowerupBar");
        m_powerups.m_hud = self;
        m_powerups.m_font = m_smallFont;

        m_ammo1Interpolator = new("Interpolator");
        m_ammo1Interpolator.Step = 3;
        m_ammo2Interpolator = new("Interpolator");
        m_ammo2Interpolator.Step = 3;
        m_healthInterpolator = new("Interpolator");
        m_healthInterpolator.Step = 3;
        m_armourInterpolator = new("Interpolator");
        m_armourInterpolator.Step = 3;
    }

    override void Draw(int state, float ticFrac)
    {
        super.Draw(state, TicFrac);

        float drawTime = MSTimeF();
        float deltaTime = (drawTime - m_prevDrawTime) / 1000;
        deltaTime = clamp(deltaTime, 0, 0.1);
        m_prevDrawTime = drawTime;

        if (state == HUD_None)
            return;

        m_ammo1Interpolator.Update(deltaTime);
        m_ammo2Interpolator.Update(deltaTime);
        m_healthInterpolator.Update(deltaTime);
        m_armourInterpolator.Update(deltaTime);

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
            String.Format("%d", m_healthInterpolator.Current),
            (-22, -20),
            DI_SCREEN_CENTER_BOTTOM | DI_TEXT_ALIGN_RIGHT);

        // Armor
        if (m_armourInterpolator.Current > 0)
        {
            DrawString(
                m_smallFont,
                String.Format("%d", m_armourInterpolator.Current),
                (-22, -30),
                DI_SCREEN_CENTER_BOTTOM | DI_TEXT_ALIGN_RIGHT);
        }

        // Ammo
        let [am1, am2, am1amt, am2amt] = GetCurrentAmmo();
        if (am1)
        {
            DrawString(
                m_bigFont,
                String.Format("%d", m_ammo1Interpolator.Current),
                (18, -20),
                DI_SCREEN_CENTER_BOTTOM | DI_TEXT_ALIGN_LEFT);
        }

        if (m_ammo2Interpolator.Current > 0)
        {
            DrawString(
                m_smallFont,
                String.Format("%d", m_ammo2Interpolator.Current),
                (18, -30),
                DI_SCREEN_CENTER_BOTTOM | DI_TEXT_ALIGN_LEFT);
        }

        m_powerups.Draw(cPlayer, ticFrac, -75, -10);
    }

    override void Tick()
    {
        super.Tick();

        // Update ammo interpolators
        Weapon currentWeapon = cPlayer.readyWeapon;
        let [am1, am2, am1amt, am2amt] = GetCurrentAmmo();

        if (currentWeapon != m_lastWeapon)
        {
            m_ammo1Interpolator.Current = am1amt;
            m_ammo1Interpolator.Step = 3; // TODO: based on the max ammo
            m_ammo2Interpolator.Current = am2amt;
            m_ammo2Interpolator.Step = 3; // TODO: based on the max ammo
            m_lastWeapon = currentWeapon;
        }

        m_ammo1Interpolator.Target = am1amt;
        m_ammo2Interpolator.Target = am2amt;

        // Update helath interpolators
        m_healthInterpolator.Target = cPlayer.health;

        BasicArmor armor = BasicArmor(CPlayer.mo.FindInventory('BasicArmor', true));
        if (armor == null)
        {
            m_armourInterpolator.Target = 0;
        }
        else
        {
            m_armourInterpolator.Target = armor.amount;
            ////m_armourSaveInterpolator.Target = armor.SavePercent * 100;
        }
    }
}