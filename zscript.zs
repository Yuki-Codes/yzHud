version "5.00"

#include "powerups.zs"
#include "keys.zs"

class YzHud : BaseStatusBar
{
    YzPowerupBar m_powerups;
    YzKeyBar m_keys;
    
    HUDFont m_bigFont;
    HUDFont m_smallFont;
    
    override void Init()
    {
        super.Init();
        m_bigFont = HUDFont.Create(Font.FindFont('BigFont'));
        m_smallFont = HUDFont.Create(Font.FindFont('SmallFont'));
        
        m_powerups = new("YzPowerupBar");
        m_powerups.m_hud = self;
        m_powerups.m_font = m_smallFont;
        
        m_keys = new("YzKeyBar");
        m_keys.m_hud = self;
        m_keys.m_font = m_smallFont;
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
        
        DrawPrompt();
    }
    
    void DrawPrompt()
    {
		let player = players[consoleplayer];
		let mo = player.mo;
        
		// Do nothing if this player is a voodoo doll, or is dead:
		if (!mo || mo.health <= 0 || !mo.player || !mo.player.mo || mo.player.mo != mo)
            return;

		let tracer = new('PromptDetector');
		if (!tracer)
            return;
        
		// Fire from player's screen center:
		Vector3 start = (mo.pos.xy, player.viewz);
		Vector3 dir = (Actor.AngleToVector(mo.angle, cos(mo.pitch)), -sin(mo.pitch));
		tracer.Trace(start, mo.cursector, dir, mo.radius + mo.userange, traceflags: 0, wallmask: 0, ignore: mo);
        
		// And check that the actor is interactable:
		if (tracer.results.HitType == TRACE_HitWall)
		{
            let line = tracer.results.HitLine;
            if (line.activation == SPAC_Use || line.activation == SPAC_UseThrough)
            {
                let [useKey1, useKey2] = bindings.GetKeysForCommand("+use");
			    String keyname = bindings.NameKeys(useKey1, 0);
                String prompt = String.Format("[%s]",  keyname);
            
                DrawString(
                    m_smallFont,
                    prompt,
                    (-1, 32),
                    DI_SCREEN_CENTER | DI_TEXT_ALIGN_CENTER);
                    
                DrawTexture(
                    TexMan.CheckForTexture("interact"),
                    (0, 0),
                    DI_SCREEN_CENTER | DI_ITEM_CENTER,
                    0.75,
                    (3, 3));
            }
            else
            {
                String prompt = String.Format("[%d]", line.flags);
            
                DrawString(
                    m_smallFont,
                    prompt,
                    (0, 64),
                    DI_SCREEN_CENTER | DI_TEXT_ALIGN_CENTER);
            }
		}
    }
}

class PromptDetector : LineTracer
{
	override ETraceStatus TraceCallback()
	{
		switch (results.HitType)
		{
			case TRACE_HitActor:
			case TRACE_HitFloor:
			case TRACE_HitCeiling:
			case TRACE_HitWall:
            {
                if (results.HitLine)
                {
                    if (results.HitLine.activation == SPAC_Use
                        || results.HitLine.activation == SPAC_UseThrough)
                    {
				        return TRACE_Stop;
                    }
                }
            }
		}
        
		return TRACE_Skip;
	}
}