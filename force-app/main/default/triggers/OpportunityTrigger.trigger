trigger OpportunityTrigger on Opportunity (before insert) {
    if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            OpportunityTriggerHandler.priceBookUodate(Trigger.new);
        }
    }
}