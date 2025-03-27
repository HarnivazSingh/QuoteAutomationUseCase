public class OpportunityTriggerHandler {
    public static void priceBookUodate(List<Opportunity> updatedOpps)
    {
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity currOpp : updatedOpps)
        {
            accountIds.add(currOpp.AccountId);
        }
        List<Pricebook2> priceBooks = [Select Id, Name from Pricebook2 where name like '%Tier%'];
        Map<Id,Account> oppAccounts = new Map<Id,Account>([Select Id,customer_Tier__c from Account where Id in :accountIds]);
        for(Opportunity currOpp : updatedOpps)
        {
            Account currAcc = oppAccounts.get(currOpp.AccountId);
            for(Pricebook2 currPB : priceBooks)
            {
                if(currPB.name == currAcc.customer_Tier__c)
                {
                    currOpp.Pricebook2Id = currPB.Id;
                }
            }
        }
    }
}