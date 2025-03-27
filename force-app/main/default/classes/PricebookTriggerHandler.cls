public class PricebookTriggerHandler {
    public static void handleDiscountUpdate(Map<Id,List<Decimal>> updatedPBwithDiscounts){
       System.debug(updatedPBwithDiscounts);
        List<PricebookEntry> PBEs = [Select Id, UnitPrice,Pricebook2Id,Product2Id from PricebookEntry where Pricebook2Id in : updatedPBwithDiscounts.keySet()];
        Map<Id, list<PricebookEntry>> entriesWithPBMap = new Map<Id, list<PricebookEntry>>();
        
        for(PricebookEntry currPBE : PBEs)
        {
            if(!entriesWithPBMap.containsKey(currPBE.Pricebook2Id))
            {
                entriesWithPBMap.put(currPBE.Pricebook2Id, new list<PricebookEntry>{currPBE});
            }
            else
            {
                entriesWithPBMap.get(currPBE.Pricebook2Id).add(currPBE);
            }
        }
        List <PricebookEntry> PBEtoUpdate = new List<PricebookEntry>();
        for(PricebookEntry currPBE : PBEs)
        {
            List<Decimal> discounts = updatedPBwithDiscounts.get(currPBE.Pricebook2Id);
            Decimal listPrice = currPBE.UnitPrice /(1-Discounts[0]/100);
            currPBE.UnitPrice = listPrice - (listPrice*discounts[1]/100);
            
            
            PBEtoUpdate.add(currPBE);
        }
        Update PBEtoUpdate;
    }
}