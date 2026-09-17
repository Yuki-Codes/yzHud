#include "alignments.zs"

class YzKeyBar ui
{
    YzHud m_hud;
    HUDFont m_font;
        
    void Draw(PlayerInfo player, double ticFrac, int xPos, int yPos)
    {
        for (int i = 0; i < Key.GetKeyTypeCount(); i++)
        {
            class<Key> keyclass = Key.GetKeyType(i);
            let key = player.mo.FindInventory(keyclass);
            if (key)
            {
                TextureId icon = GetKeyIcon(Key(key));
                if (icon.IsValid())
                {
                    m_hud.DrawTexture(
                        icon,
                        (xPos, yPos),
                        VerticalAlignment.Bottom | HorizontalAlignment.Center | VerticalPivot.Center | HorizontalPivot.Center,
                        1.0,
                        (12, 12));
                        
                    xPos += 12;
                }
                else
                {
                    m_hud.DrawString(
                        m_font,
                        String.Format("%s", key.GetClassName()),
                        (xPos, yPos),
                        VerticalAlignment.Bottom | HorizontalAlignment.Center | TextAlignment.Left,
                        translation: Font.CR_GREY);
                        
                    xPos += 75;
                }
            }
        }           
    }
    
    private TextureID GetKeyIcon(Key key)
    {
        if (key.GetClass() == "RedCard")
            return TexMan.CheckForTexture("RKEYA0");
            
        if (key.GetClass() == "BlueCard")
            return TexMan.CheckForTexture("BKEYA0");
            
        if (key.GetClass() == "YellowCard")
            return TexMan.CheckForTexture("YKEYA0");
            
        if (key.GetClass() == "RedSkull")
            return TexMan.CheckForTexture("RSKUA0");
            
        if (key.GetClass() == "BlueSkull")
            return TexMan.CheckForTexture("BSKUA0");
            
        if (key.GetClass() == "YellowSkull")
            return TexMan.CheckForTexture("YSKUA0");
            
        return -1;
    }
}