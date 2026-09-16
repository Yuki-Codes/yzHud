version "5.00"

class YzHud : BaseStatusBar
{
    HUDFont m_bigFont;
    HUDFont m_smallFont;
    
    override void Init()
    {
        super.Init();
        m_bigFont = HUDFont.Create(Font.FindFont('BigFont'));
        m_smallFont = HUDFont.Create(Font.FindFont('SmallFont'));
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
        DrawTexture(GetMugShot(5), (0, -5), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_CENTER_BOTTOM);

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
        
        // Keys
        for (int i = 0; i < Key.GetKeyTypeCount(); i++)
        {
            class<Key> keyclass = Key.GetKeyType(i);
            let key = CPlayer.mo.FindInventory(keyclass);
            if (key)
            {
                DrawInventoryIcon(
                    key,
                    (75 + (i * 9), -10),
                    DI_SCREEN_CENTER_BOTTOM | DI_ITEM_CENTER,
                    boxSize: (32, 32));
            }
        }
        
        // powerups
        int index = 0;
        for (let iitem = CPlayer.mo.Inv; iitem != NULL; iitem = iitem.Inv)
		{    
            int xPos = -80 - (index * 38);
            int yPos = -15;
            let powerup = Powerup(iitem);
            if (powerup)
			{
                TextureID icon = GetPowerupIcon(powerup);
                
                if (icon.IsValid())
                {
                    DrawTexture(
                        icon,
                        (xPos, yPos),
                        DI_SCREEN_CENTER_BOTTOM | DI_ITEM_RIGHT | DI_ITEM_TOP,
                        1.0,
                        (10, 10));
                }
                
                // Get the amount of seconds left (tics / ticrate).
                int secondsLeft = int(Ceil(double(powerup.EffectTics) / GameTicRate));
                
                DrawString(
                    m_smallFont,
                    FormatNumber(secondsLeft, 4),
                    (xPos - 6, yPos + 1),
                    DI_SCREEN_CENTER_BOTTOM | DI_TEXT_ALIGN_LEFT,
                    translation: Font.CR_GREY);
                    
                index++;
            }
        }
    }
    
    TextureID GetPowerupIcon(Powerup powerup)
    {
        if (powerup.GetClass() == "PowerIronFeet")
            return TexMan.CheckForTexture("rad");
            
        if (powerup.GetClass() == "PowerInvisibility")
            return TexMan.CheckForTexture("PINSA0");
            
        if (powerup.GetClass() == "PowerInvulnerable")
            return TexMan.CheckForTexture("PINVA0");
            
        /*
        if (powerup.GetClass() == "PowerStrength")
        if (powerup.GetClass() == "PowerInvisibility")
        if (powerup.GetClass() == "PowerLightAmp")
        if (powerup.GetClass() == "PowerFlight")
        */
            
        return powerup.GetPowerupIcon();
    }
}