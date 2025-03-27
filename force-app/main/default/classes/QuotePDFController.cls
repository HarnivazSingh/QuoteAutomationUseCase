public class QuotePDFController {
    public Quote quote { get; private set; }
    public String companyName { get; private set; }
    public List<QuoteLineItem> quoteLineItems { get; private set; }

    public QuotePDFController(ApexPages.StandardController controller) {
        Id quoteId = controller.getId();
        quote = [SELECT Id, Name, CreatedDate, Account.Name 
                 FROM Quote WHERE Id = :quoteId];

        companyName = quote.Account.Name;
        
        quoteLineItems = [SELECT Id, Product2.Name, Quantity, UnitPrice, TotalPrice 
                          FROM QuoteLineItem WHERE QuoteId = :quoteId];
    }
}