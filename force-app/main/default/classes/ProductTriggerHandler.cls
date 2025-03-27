public class ProductTriggerHandler {
    public static void createPBE(List <Product2> newProducts)
    {
        List<PricebookEntry> PBEToInsert = new List<PricebookEntry>();
        Pricebook2 standardPricebook = [Select Id from Pricebook2 where IsStandard = true];
        for(Product2 currProd : newProducts)
        {
            PricebookEntry newPBE = new PricebookEntry();
            newPBE.Pricebook2Id = standardPricebook.Id;
            newPBE.UnitPrice = currProd.List_Price__c;
            newPBE.Product2Id = currProd.Id;
            newPBE.IsActive= true;
            PBEToInsert.add(newPBE);
        }
        List<Pricebook2> discountedPricebooks = [Select Id, Discount__c  from Pricebook2 where Name like '%Tier%'];
        for(Product2 currProd : newProducts)
        {
            for(Pricebook2 customPB : discountedPricebooks)
            {
                PricebookEntry customPBE = new PricebookEntry();
                customPBE.Pricebook2Id = customPB.Id;
                customPBE.Product2Id = currProd.Id;
                customPBE.UnitPrice =currProd.List_Price__c-(currProd.List_Price__c*customPB.Discount__c/100);
                customPBE.IsActive = true;
                PBEToInsert.add(customPBE);
            }
        }
        insert PBEToInsert;
    }
    public static void handleUpdate(List<Product2> updatedProducts)
    {
        Set<Id> prodIds = new Set<Id>();
        for(Product2 currProd : updatedProducts)
        {
            prodIds.add(currProd.Id);
        }
        Map<Id,Product2> productsWithIdsMap = new Map<Id,Product2>([Select Id, List_Price__c from Product2 where Id in:prodIds]);
        Map<Id,Pricebook2> pricebooksWithIdsMap = new Map<Id,Pricebook2>([Select Id,Discount__c from Pricebook2 where Name like '%Tier%']);
        List<PricebookEntry> productEntries = [Select Id, UnitPrice from PricebookEntry where Product2Id in : prodIds];
        List<PricebookEntry> PBEtoUpdate = new List<PricebookEntry>();
        for(PricebookEntry currEntry : productEntries)
        {
            Pricebook2 currPB = pricebooksWithIdsMap.get(currEntry.Pricebook2Id);
            Product2 currProd = productsWithIdsMap.get(currEntry.Product2Id);
            currEntry.UnitPrice = currProd.List_Price__c - (currProd.List_Price__c*currPB.Discount__c/100);
            PBEtoUpdate.add(currEntry);
        }
        Update PBEtoUpdate;
    }
}