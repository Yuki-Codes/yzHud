class YZH_UiPowerups : YZH_UiInventoryBase
{
    override void Initialize()
    {
        foreach (actorClass : AllActorClasses)
        {
            class<Powerup> itemType = (class<Powerup>)(actorClass);
            if (itemType == null)
                continue;

            self.AddItem(itemType);
        }
    }

    override void Draw(float deltaTime)
    {
        int x = (self.GetWidth() / 2) - 130;
        int y = self.GetHeight() - 23;
        int step = -20;

        self.DrawBar(deltaTime, x, y, step);
    }

    override int GetItemValue(Inventory item)
    {
        Powerup pup = Powerup(item);

        if(pup.MaxEffectTics == 1)
            return 0;

        return int(Ceil(double(pup.EffectTics) / GameTicRate));
    }
}