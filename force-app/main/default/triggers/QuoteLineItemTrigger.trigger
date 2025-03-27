trigger QuoteLineItemTrigger on QuoteLineItem (before insert) {
    if(Trigger.IsBefore && Trigger.IsInsert)
    {
        QuoteLineItemTriggerHandler.handleItemDiscount(Trigger.new);
    }
}