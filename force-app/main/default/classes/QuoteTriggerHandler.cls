public class QuoteTriggerHandler {
    @InvocableMethod(label='Approval Process')
    public static void approvalRequest(List<Quote> quotesForApproval)
    {
        Set<Id> userIds = new Set<Id>();
        for(Quote currQuote : quotesForApproval)
        {
            userIds.add(currQuote.OwnerId);
        }
        Map<Id,User> userRoleMap = new Map<Id,User>([Select Id, userRole.Name from User where Id in : userIds]);
        
        List<Approval.processSubmitRequest> approvalRequests = new List<Approval.processSubmitRequest>();
        for(Quote currQuote : quotesForApproval){
            if(userRoleMap.get(currQuote.OwnerId).userRole.Name == 'Sales Team')
            {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(currQuote.Id);
                req.setSkipEntryCriteria(true);
                req.setSubmitterId(UserInfo.getUserId());
                req.setProcessDefinitionNameOrId('Quote_Approval_Process_Sales'); 
                approvalRequests.add(req);
            }
            else
                if(userRoleMap.get(currQuote.OwnerId).userRole.Name == 'Support Team')
            {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(currQuote.Id);
                req.setSkipEntryCriteria(true);
                req.setSubmitterId(UserInfo.getUserId());
                req.setProcessDefinitionNameOrId('Quote_Approval_Process_Support'); 
                approvalRequests.add(req);
            }
            
        }
        System.debug(approvalRequests);
        Approval.process(approvalRequests);
    }
    
    public static void opportunitySync(List <Quote> approvedQuotes)
    {
        Set<Id> oppIds = new Set<Id>();
        for(Quote currQuote : approvedQuotes)
        {
            oppIds.add(currQuote.OpportunityId);
        }
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity> ([Select Id,SyncedQuoteId from Opportunity where Id in :oppIds]);
        for(Quote currQuote : approvedQuotes)
        {
            Opportunity currOpp = oppMap.get(currQuote.OpportunityId);
            currOpp.SyncedQuoteId = currQuote.Id;
        }
    }
    public static void convertQuoteToOrder(List <Quote> quotesToConvert) {
        
        List <Order> ordersToInsert = new List<Order>();
        for (Quote q : quotesToConvert) {
            Order newOrder = new Order();
            newOrder.AccountId = q.AccountId;
            newOrder.QuoteId = q.Id;
            newOrder.OpportunityId = q.OpportunityId;
            newOrder.Status = 'Draft';
            newOrder.EffectiveDate = Date.today();
            ordersToInsert.add(newOrder);
        }
        insert ordersToInsert;
        
        Map<Id,Order> quoteToOrderMap =  new Map<Id,Order>();
        for (Order currOrder : ordersToInsert) {
            quoteToOrderMap.put(currOrder.QuoteId, currOrder);
        }
        Map<Id,List<QuoteLineItem>> quoteIdWithItems = new Map<Id,List<QuoteLineItem>>();
        List <QuoteLineItem> qli = [SELECT Id, Product2Id, Quantity, UnitPrice, TotalPrice, Discount, QuoteId FROM QuoteLineItem WHERE QuoteId = :quoteToOrderMap.keySet()];
        
        for(QuoteLineItem currItem : qli)
        {
            if(!quoteIdWithItems.containsKey(currItem.QuoteId))
            {
                quoteIdWithItems.put(currItem.QuoteId,new List<QuoteLineItem>{currItem});
            }
            else
            {
                quoteIdWithItems.get(currItem.QuoteId).add(currItem);
            }
        }
        
        Pricebook2 newPriceBook = new Pricebook2(Name = 'Custom Price Book', IsActive = true);
        insert newPriceBook;
        
        List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
        for (QuoteLineItem item : qli) {
            Decimal discountedPrice = item.UnitPrice - (item.UnitPrice * (item.Discount / 100));
            PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = newPriceBook.Id,
                Product2Id = item.Product2Id,
                UnitPrice = discountedPrice,
                IsActive = true,
                UseStandardPrice = false
            );
            priceBookEntries.add(pbe);
        }
        
        insert priceBookEntries;
        
        List<OrderItem> orderItems = new List<OrderItem>();
        for(Id qId : quoteToOrderMap.keySet()){
            List<quoteLineItem> currQuoteItems = quoteIdWithItems.get(qId);
            Order currOrder = quoteToOrderMap.get(qId);
            for(quoteLineItem item : currQuoteItems)
            {
                OrderItem newItem = new OrderItem();
                newItem.OrderId = currOrder.Id;
                newItem.Product2Id = item.Product2Id;
                newItem.Quantity = item.Quantity;
                newItem.ListPrice = item.UnitPrice;
                if(item.discount!=null)
                {
                    newItem.UnitPrice = item.UnitPrice-(item.UnitPrice*item.Discount/100);
                }
                else
                {
                    newItem.UnitPrice = item.UnitPrice;
                }
                orderItems.add(newItem);
            }
        }

        if (!orderItems.isEmpty()) {
            insert orderItems;
        }
    }
    
   
}