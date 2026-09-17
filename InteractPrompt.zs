#include "alignments.zs"

class InteractPrompt ui
{
    YzHud m_hud;
    HUDFont m_font;
    
    private PromptDetector m_tracer;
        
    void Draw(PlayerInfo player, double ticFrac)
    {
        let mo = player.mo;
        
		// Do nothing if this player is a voodoo doll, or is dead:
		if (!mo || mo.health <= 0 || !mo.player || !mo.player.mo || mo.player.mo != mo)
            return;
            
        if (m_tracer == null)
            m_tracer = new('PromptDetector');
        
		// Fire from player's screen center:
		Vector3 start = (mo.pos.xy, player.viewz);
		Vector3 dir = (Actor.AngleToVector(mo.angle, cos(mo.pitch)), -sin(mo.pitch));
		m_tracer.Trace(
            start,
            mo.cursector,
            dir,
            mo.radius + mo.userange,
            traceflags: 0,
            wallmask: 0,
            ignore: mo);
        
		if (m_tracer.results.HitType == TRACE_HitWall)
		{
            let line = m_tracer.results.HitLine;
            if (line.activation == SPAC_Use || line.activation == SPAC_UseThrough)
            {
                let [useKey1, useKey2] = bindings.GetKeysForCommand("+use");
			    String keyname = bindings.NameKeys(useKey1, 0);
                String prompt = String.Format("[%s]",  keyname);
            
                m_hud.DrawString(
                    m_font,
                    prompt,
                    (-1, 32),
                    VerticalAlignment.Center | HorizontalAlignment.Center | TextAlignment.Center);
                    
                m_hud.DrawTexture(
                    TexMan.CheckForTexture("interact"),
                    (0, 0),
                    VerticalAlignment.Center | HorizontalAlignment.Center | VerticalPivot.Center | HorizontalPivot.Center,
                    0.75,
                    (3, 3));
            }
            /*else
            {
                String prompt = String.Format("[%d]", line.flags);
            
                m_hud.DrawString(
                    m_smallFont,
                    prompt,
                    (0, 64),
                    VerticalAlignment.Bottom | HorizontalAlignment.Center | TextAlignment.Center);
            }*/
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