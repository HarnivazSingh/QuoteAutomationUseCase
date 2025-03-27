trigger ProductTrigger on Product2 (after insert, after update) {
    if(Trigger.isAfter)
    {
        if(trigger.IsInsert)
        {
            ProductTriggerHandler.createPBE(Trigger.new);
        }
        if(trigger.isUpdate)
        {
            ProductTriggerHandler.handleUpdate(Trigger.new);
        }
    }
}