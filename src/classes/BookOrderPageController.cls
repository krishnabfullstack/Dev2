/*==============================================
* Apex Class Name : BookList
* Version             : 1.0 
* Created Date        : 23 February 2017
* Function            : Book Order Controller
* Modification Log 
* Developer                   Date                    Description
* -----------------------------------------------------------------------------------------------------------
* Krishna Bogavelli           02/23/2016            Final version
-------------------------------------------------------------------------------------------------------------
=================================================*/
global with sharing class BookOrderPageController  {

    public String CurrentId {get;set;}
    public Book_Order__c bookOrderRec; 
    public Map<id,Product2> mapProducts = new Map<id,Product2>();
    public string selectedBookID {get; set;}
    public string selectedLineItemID {get; set;}
    public List<Product2> productlistforSelection { get;set;}
    public List<Line_Item__c> shoppingCart {get;set;}
    public List<Product2> AvailableProducts { get;set;}
    public string Userinput {get;set;}
    public Decimal TotalCount {get; set;}

    public BookOrderPageController(ApexPages.StandardController controller) { 

      CurrentId = ApexPages.currentPage().getParameters().get('id');
      if (CurrentId != Null){
         bookOrderRec = [SELECT Contact__r.id,Contact__r.Accountid, Contact__r.MailingCity, Contact__r.MailingState, 
                                   Contact__r.MailingCountry,  Contact__r.MailingPostalCode 
                           FROM Book_Order__c 
                          WHERE Id =: CurrentId];

       //  Id AcctBookSellerId = bookOrderRec.Contact__r.Accountid;

         shoppingCart = [SELECT Id,Name,Price_Each__c,Quantity__c,Book__c,Book_Order__c, Extended_Price__c
                           FROM Line_Item__c 
                          WHERE Book_Order__c =: CurrentId];

         AvailableProducts =  [SELECT id,Name,Account__c ,Current_Price__c,CreatedDate from Product2 
                                WHERE Account__c =: bookOrderRec.Contact__r.Accountid 
                             ORDER BY CreatedDate Desc ]; 

        for (Product2 prd : AvailableProducts){
            mapProducts.put(prd.id, prd); 
        }
      }
      else{
          ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, 'Book Order ID is Missing'));
      }


   }

 
  //Method To display Available Book list in Orders Tab(Books from Products) vf page
  public List<Product2> getAvailableBookList() { 
    Set<id> LineItemIDs =  new Set<id>();

    for (Line_Item__c eachLT: shoppingCart){
      LineItemIDs.add(eachLT.Book__c);
    }

    String qString = 'Select id,Name,Account__c ,Current_Price__c,CreatedDate from  Product2 where id in: AvailableProducts ';

    if(!LineItemIDs.isEmpty()){ 
      qstring += ' and id not in: LineItemIDs '; 
    }

    if(Userinput != Null ){  
      qString+= '  and  Name like \'%' + Userinput + '%\'  order by Name Desc Limit 10 ';
    } 
    else{
      qString+= ' order by Name Desc Limit 10 ';
    }

    productlistforSelection =  database.query(qString); 

    return productlistforSelection; 
  }

  //Method To display Selected Books in This Order tab(Books from Line Items) vf page
  public List<Line_Item__c> getAvailableLineItemList(){ 
    TotalCount = 0.00;
    for (Line_Item__c eachPrd: shoppingCart){   
       if(eachPrd.Extended_Price__c != Null) TotalCount += eachPrd.Extended_Price__c;
    } system.debug('test'+TotalCount);

    return shoppingCart;
  }

  //Method To add Books to This Order Tab (Line Items) vf page
  public void addToShoppingCart(){ 
  try{
      if(mapProducts.get(selectedBookID) != Null){  
        shoppingCart.add(new Line_Item__c(Name = mapProducts.get(selectedBookID).name,
                                        Book_Order__c = CurrentId,
                                        Book__c = selectedBookID,
                                        Quantity__c = 1, 
                                        Price_Each__c = mapProducts.get(selectedBookID).Current_Price__c));

         
      } 
      upsert shoppingCart;  
    }
   catch (exception e) {  
      ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, e.getMessage()));
    }
    //this will update the Shopping cart records display on VF page
    getAvailableLineItemList();
  }
   
  //Method To remove Books from This Order Tab (Line Items) vf page
  public void removeFromShoppingCart(){  
   List<Line_Item__c> forDeletion = new List<Line_Item__c>();
    Integer count = 0;

    for(Line_Item__c lstLI: shoppingCart){
      if((String)lstLI.id == selectedLineItemID){
        forDeletion.add(lstLI);system.debug('Count1--'+Count);

        shoppingCart.remove(0); system.debug('Count2--'+Count);
        break;          
      }
      Count++;
    }
  try{
         Delete forDeletion; 
     }
    catch (exception  e) {
      ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, e.getMessage());
      ApexPages.addMessage(msg);
    }

    getAvailableLineItemList(); 
    getAvailableBookList();
    //this will update the Shopping cart records display on VF page
  }


  //Method to Submit Order, this will on Book Order Level
  public pagereference ShipOrder(){
    try{
      bookOrderRec.Order_Status__c = 'Ordered';
      update bookOrderRec;
    }
    catch (exception e) {
      ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, e.getMessage());
      ApexPages.addMessage(msg);
    }

    String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
    PageReference BookOrderPage =  new PageReference(baseURL+'/'+CurrentId);

    return BookOrderPage;
  }
 
  //Method to update Shopping cart when quantity is increased
  public pagereference updateFromShoppingCart(){
    try{
      update shoppingCart;
    }
    catch (exception e) {
      ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, e.getMessage());
      ApexPages.addMessage(msg);
    }

    //this will update the Shopping cart records display on VF page
    getAvailableLineItemList();
    String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
    PageReference BookOrderPage =  new PageReference(baseURL+'/apex/BookOrderPage?id='+CurrentId);

    return BookOrderPage;
  }
}