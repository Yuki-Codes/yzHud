class YZH_UiKeys : YZH_UiInventoryBase
{
    override void Initialize()
    {
        foreach (actorClass : AllActorClasses)
        {
            class<Key> itemType = (class<Key>)(actorClass);
            if (itemType == null)
                continue;

            self.AddItem(itemType);
        }
    }

    override void Draw(float deltaTime)
    {
        int x = (self.GetWidth() / 2) + 100;
        int y = self.GetHeight() - 23;
        int step = 17;

        self.DrawBar(deltaTime, x, y, step);
    }
}