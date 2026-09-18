#include "alignments.zs"

class PowerupBar ui
{
    YzHud m_hud;
    HUDFont m_font;
        
    void Draw(PlayerInfo player, double ticFrac, int xPos, int yPos)
    {                
        for (let iitem = player.mo.Inv; iitem != NULL; iitem = iitem.Inv)
		{
            Powerup powerup = Powerup(iitem);
            if (powerup)
			{            
                TextureID icon = GetPowerupIcon(powerup);
                
                // Get the amount of seconds left (tics / ticrate).
                int secondsLeft = int(Ceil(double(powerup.EffectTics) / GameTicRate));
                
                if (icon.IsValid())
                {
                    if (powerup.GetClass() == "PowerStrength")
                    {
                        m_hud.DrawTexture(
                            icon,
                            (xPos, yPos),
                            VerticalAlignment.Bottom | HorizontalAlignment.Center | VerticalPivot.Center | HorizontalPivot.Center,
                            1.0,
                            (16, 12));
                        
                        xPos -= 12;
                    }
                    else
                    {
                        m_hud.DrawTexture(
                            icon,
                            (xPos, yPos),
                            VerticalAlignment.Bottom | HorizontalAlignment.Center | VerticalPivot.Center | HorizontalPivot.Center,
                            1.0,
                            (12, 12));
                    
                        m_hud.DrawString(
                            m_font,
                            String.Format("%d", secondsLeft),
                            (xPos, yPos + 1),
                            VerticalAlignment.Bottom | HorizontalAlignment.Center | TextAlignment.Left,
                            translation: Font.CR_WHITE);
                            
                        xPos -= 25;
                    }
                }
                else
                {
                    m_hud.DrawString(
                        m_font,
                        String.Format("%s: %d", powerup.GetclassName(), secondsLeft),
                        (xPos - 6, yPos + 1),
                        VerticalAlignment.Bottom | HorizontalAlignment.Center | TextAlignment.Left);
                        
                    xPos -= 50;
                }
            }
        }
    }
    
    private TextureID GetPowerupIcon(Powerup powerup)
    {
        if (powerup.GetClass() == "PowerIronFeet"
            || powerup.GetClassName() == "PowerDimIronFeet")
            return TexMan.CheckForTexture("rad");
            
        if (powerup.GetClass() == "PowerInvisibility")
            return TexMan.CheckForTexture("PINSA0");
            
        if (powerup.GetClass() == "PowerInvulnerable")
            return TexMan.CheckForTexture("PINVA0");
            
        if (powerup.GetClass() == "PowerStrength")
            return TexMan.CheckForTexture("PSTRA0");
            
        /*
        if (powerup.GetClass() == "PowerLightAmp")
        if (powerup.GetClass() == "PowerFlight")
        */
            
        return powerup.GetPowerupIcon();
    }
}