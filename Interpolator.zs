class Interpolator
{
    float Target;
    
    private float m_current;
    
    float Update(float deltaTime)
    {
        return UpdateInternal(deltaTime);
    }
    
    private virtual float UpdateInternal(float deltaTime)
    {
        float delta = (self.Target - self.m_current) * (deltaTime * 10.0);
        
        if (delta < 0.01f && delta > -0.001)
        {
            self.m_current = Target;
        }
        else
        {
            self.m_current += delta;
        }
        
        return m_current;
    }
}