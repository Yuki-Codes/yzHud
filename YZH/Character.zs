#include "YZH/StatusbarAddOn.zs"

class YZH_Character : YZH_StatusbarAddOn
{
    private HUDFont m_bigFont;
    private HUDFont m_smallFont;

    private YZH_Interpolator m_ammo1Interpolator;
    private YZH_Interpolator m_ammo2Interpolator;
    private YZH_Interpolator m_healthInterpolator;
    private YZH_Interpolator m_armourInterpolator;

    private Weapon m_lastWeapon;

    override void Init()
    {
        m_bigFont = HUDFont.Create(Font.FindFont('BigFont'));
        m_smallFont = HUDFont.Create(Font.FindFont('SmallFont'));

        m_ammo1Interpolator = new("YZH_Interpolator");
        m_ammo1Interpolator.Step = 3;
        m_ammo2Interpolator = new("YZH_Interpolator");
        m_ammo2Interpolator.Step = 3;
        m_healthInterpolator = new("YZH_Interpolator");
        m_healthInterpolator.Step = 3;
        m_armourInterpolator = new("YZH_Interpolator");
        m_armourInterpolator.Step = 3;
    }

    override void Draw(float deltaTime)
    {
        m_ammo1Interpolator.Update(deltaTime);
        m_ammo2Interpolator.Update(deltaTime);
        m_healthInterpolator.Update(deltaTime);
        m_armourInterpolator.Update(deltaTime);

        // BG Shade
        DrawTexture(
            TexMan.CheckForTexture("shade"),
            position: (0, 0),
            anchor: (0.5, 1.0),
            pivot: (0.5, 1.0));

        // Mugshot
        DrawTexture(
            GetStatusBar().GetMugShot(5),
            position: (0, -5),
            anchor: (0.5, 1.0),
            pivot: (0.5, 1.0));

        // Health
        DrawString(
            m_bigFont,
            String.Format("%d", m_healthInterpolator.Current),
            position: (-22, -20),
            anchor: (0.5, 1.0),
            pivot: (1.0, 0.0));

        // Armor
        if (m_armourInterpolator.Current > 0)
        {
            DrawString(
                m_smallFont,
                String.Format("%d", m_armourInterpolator.Current),
                position: (-22, -30),
                anchor: (0.5, 1.0),
                pivot: (1.0, 0.0));
        }

        // Ammo
        let [am1, am2, am1amt, am2amt] = GetStatusBar().GetCurrentAmmo();
        if (am1)
        {
            DrawString(
                m_bigFont,
                String.Format("%d", m_ammo1Interpolator.Current),
                position: (18, -20),
                anchor: (0.5, 1.0),
                pivot: (0.0, 0.0));
        }

        if (m_ammo2Interpolator.Current > 0)
        {
            DrawString(
                m_smallFont,
                String.Format("%d", m_ammo2Interpolator.Current),
                position: (18, -30),
                anchor: (0.5, 1.0),
                pivot: (0.0, 0.0));
        }
    }

    override void Tick()
    {
        // Update ammo interpolators
        Weapon currentWeapon = GetPlayer().readyWeapon;
        let [am1, am2, am1amt, am2amt] = GetStatusBar().GetCurrentAmmo();

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
        m_healthInterpolator.Target = GetPlayer().health;

        BasicArmor armor = BasicArmor(GetPlayerPawn().FindInventory('BasicArmor', true));
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