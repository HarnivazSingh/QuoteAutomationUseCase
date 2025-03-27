trigger QuoteTrigger on Quote (after update) {
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        //QuoteTriggerHandler.approvalRequest(Trigger.new,Trigger.OldMap);
        //QuoteTriggerHandler.opportunitySync(Trigger.new);
        List <Quote> quotesForOrder = new List<Quote>();
        for(Quote q : Trigger.new)
        {
            if(q.Status =='Approved' && Trigger.oldMap.get(q.Id).Status != 'Approved')
            {
                quotesForOrder.add(q);
            }
        }
        //QuoteTriggerHandler.convertQuoteToOrder(quotesForOrder);
    }
}