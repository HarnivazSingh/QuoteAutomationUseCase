public class QuoteLineItemTriggerHandler {

    public static void handleItemDiscount(List<QuoteLineItem> createdItems){
        
        Set<Id> productIds = new Set<Id>();
        for(QuoteLineItem item :createdItems)
        {
            productIds.add(item.Product2Id);
        }
        Map<Id,Product2> productsWithIdsMap = new Map <Id,Product2> ([Select Id,Discount_Percentage__c from Product2 where Id in : productIds]);
        for(QuoteLineItem currItem :createdItems){
            Product2 currProduct = productsWithIdsMap.get(currItem.Product2Id);
            currItem.Discount = currProduct.Discount_Percentage__c;
        }
    }
}