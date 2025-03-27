trigger PricebookTrigger on Pricebook2 (after update) {
    if(Trigger.IsAfter)
    {
        if(Trigger.isUpdate)
        {
            Map<Id,List<Decimal>> updatedPB = new Map<Id,List<Decimal>>();
            for(Pricebook2 currPB : Trigger.New)
            {
                if(currPB.Discount__c != Trigger.oldMap.get(currPB.id).Discount__c)
                {
                    updatedPB.put(currPB.Id,new List<Decimal>{Trigger.oldMap.get(currPB.id).Discount__c,currPB.Discount__c});
                }
            }
            PricebookTriggerHandler.handleDiscountUpdate(updatedPB);
        }
    }
}