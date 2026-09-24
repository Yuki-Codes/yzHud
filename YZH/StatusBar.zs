class YZH_Statusbar : BaseStatusBar
{
    HUDFont m_bigFont;
    HUDFont m_smallFont;

    Weapon m_lastWeapon;
    YZH_Interpolator m_ammo1Interpolator;
    YZH_Interpolator m_ammo2Interpolator;
    YZH_Interpolator m_healthInterpolator;
    YZH_Interpolator m_armourInterpolator;
    private ui float m_prevDrawTime;

    override void Init()
    {
        super.Init();
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