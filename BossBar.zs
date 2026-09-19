#include "UiAddOn.zs"
#include "Interpolator.zs"

class BossBar : UiAddOn
{
    private Array<actor> m_bosses;
    private ui TextureId m_barBgTextureId;
    private ui TextureId m_barFgTextureId;
    private ui TextureId m_barFillTextureId;
    private ui Font m_font;
    
    override void Initialize()
    {
        m_barBgTextureId = TexMan.CheckForTexture("barbg");
        m_barFgTextureId = TexMan.CheckForTexture("barfg");
        m_barFillTextureId = TexMan.CheckForTexture("barfill");
        m_font = Font.FindFont('SmallFont');
    }
    
    override void Draw(double ticFrac)
    {
        int posY = 10;
        
        for (int i = 0; i < m_bosses.Size(); i++)
        {
			if (!m_bosses[i].target || !m_bosses[i].target.player)
            {
				continue;
			}
            
            double healthRatio = m_bosses[i].health / Double(m_bosses[i].SpawnHealth());
			healthRatio = clamp(healthRatio, 0, 1);
        
            self.DrawTexture(
                m_barBgTextureId,
                (GetWidth() / 2) - 128,
                posY,
                width: 256,
                height: 16,
                alpha: 1.0);
                
            self.DrawTexture(
                m_barFillTextureId,
                (GetWidth() / 2) - 128 + 2,
                posY + 1,
                width: (healthRatio * 252),
                height: 16,
                alpha: 1.0);
                
            self.DrawTexture(
                m_barFgTextureId,
                (GetWidth() / 2) - 128,
                posY,
                width: 256,
                height: 16,
                alpha: 1.0);
                
            self.DrawText(
                m_font,
                m_bosses[i].GetTag(),
                (GetWidth() / 2),
                posY + 2,
                color: Font.CR_White,
                align: 0.5);
            
            posY += 16;
        }
    }
    
    override void WorldThingSpawned(WorldEvent event)
    {
		if (event.Thing.bBOSS)
        {
			m_bosses.Push(event.Thing);
		}
	}
	
	override void WorldThingDied(WorldEvent event)
    {
		if (event.Thing.bBOSS && m_bosses.Find(event.Thing) != m_bosses.Size())
        {
			m_bosses.Delete(m_bosses.Find(event.Thing));
		}
	}
	
	override void WorldThingDestroyed(WorldEvent event)
    {
		if (event.Thing.bBOSS && m_bosses.Find(event.Thing) != m_bosses.Size())
        {
			m_bosses.Delete(m_bosses.Find(event.Thing));
		}
	}
}