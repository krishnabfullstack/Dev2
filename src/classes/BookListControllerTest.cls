@isTest
public class BookListControllerTest { 
 static id BookSellRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Book Seller').getRecordTypeId();  
 static id WhareRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Warehouse').getRecordTypeId(); 
 static Map<id,Account> mapGetBooks = New Map<id,Account>();
 static List<Account> lstWhareAcct = New List<Account>();
 static List<Account> lstSellerAcct = New List<Account>();
 static List<Product2> lstSellerBooks = new List<Product2>();
 static List<Product2> lstWhareBooks = new List<Product2>();
 static List<Product2> lstBooks = new List<Product2>();
 static List<Product2> lstPrd = new List<Product2>();
 static List<String> BookNames = New List<String>();
 static id acct;
 static Map<String,Product2> MapInventoryBooks = New Map<String,Product2>();
 static Map<String,Product2> MapBookSellerBooks = New Map<String,Product2>();
 static Contact contactRec = New Contact();
 static Book_Order__c bookOrderRec = new Book_Order__c();
 static Line_Item__c LineItemRec = new Line_Item__c();
 static {
		user userinfo = [select id from user where name ='BWS Customer'];
		lstWhareAcct = TestDataHelper.createWhareHouseAccts();
		lstSellerAcct = TestDataHelper.createbookSellerAccts();
		lstBooks = TestDataHelper.CreateBooks();

	 	//Get Books list and Bollser ID
		for (account eachSellerAcct: [SELECT id,name,type,RecordTypeId, (Select id,name,Account__r.name,Family,Current_Price__c from Products__r where Family <> 'Inventory' ) 
									FROM account  
									WHERE Type='Book Seller'  order by name asc ]){ 
            List<string> countBooks = new List<string>();
            if(eachSellerAcct.Products__r.size()>200){
            				for (Product2 eachPrd:eachSellerAcct.Products__r ){
				system.assertNotEquals(eachPrd.Current_Price__c,Null);
				countBooks.add(eachPrd.Name);
                //for bulk test capture books with greater than 200 records
                //if (countBooks.size()>200){
					lstPrd.add(eachPrd);
                	BookNames.add(eachPrd.Name);
                	MapBookSellerBooks.put(eachPrd.Name,eachPrd);
              //  }
			}
			
     			acct = eachSellerAcct.Id;
                Break;
            
            }

		}
    
    //List<Product2> lstBooks_1 = [select id,name from product2 where account__c =: acct];
    //system.debug('test_1'+lstBooks_1.size());


	    //from above List of Book names get the inventory data.
		for(Product2 eachPrd: [Select id,name,Family,Inventory__c,Account__r.name,Account__r.Type
								from Product2 where name in: BookNames 
								    and Family = 'Inventory'  order by name asc ]){
			MapInventoryBooks.Put(eachPrd.Name,eachPrd);
			system.assertNotEquals(eachPrd.Inventory__c,Null);
			system.assertNotEquals(eachPrd.Inventory__c,0);
		}
 	   
        system.assertNOTEquals(Null,acct);
		contactRec = TestDataHelper.createContact(acct,userinfo.Id);
	    bookOrderRec = TestDataHelper.bookOrder(contactRec.ID);
        system.assertEquals(bookOrderRec.Contact__r.Accountid , acct);

}

/********************This will check follwoing Senarios 
1) Order status changed to Shipped
2) Whare house has records
3) Reduce the Wharehouse inventory count
4) Collections has books
**********************/ 

 static testMethod void TestMethodOne() { 

//check book order is not null
  system.assertNotEquals(Null,bookOrderRec);

  	List<Line_Item__c> LT = new List<Line_Item__c>();
//check books in seller and whare house are matching
	for(string str: MapInventoryBooks.KeySet()){  
		//ssystem.assertnotEquals(MapInventoryBooks.get(str).name,Null);
		system.assertEquals(MapInventoryBooks.get(str).name,MapBookSellerBooks.get(str).Name); 
        system.assertEquals(100,MapInventoryBooks.get(str).Inventory__c);
        system.assertNOTEquals(Null,MapBookSellerBooks.get(str).Current_Price__c);
		}system.debug('Test data'+ bookOrderRec);


		//Create Line Item 
		integer Count1 =0;
 	for(integer i = 0; i <= BookNames.Size();i++){
 		if(MapInventoryBooks.get(BookNames[i]).Family == 'Inventory')
		{system.debug('Anydatatype_msg1Family1**'+MapInventoryBooks.get(BookNames[i]).Family +' '+MapInventoryBooks.get(BookNames[i]).Account__r.Type);


 		LT.add(new Line_Item__c(Book_Order__c = bookOrderRec.Id, 
				          	    Name=MapBookSellerBooks.get(BookNames[i]).Name, 
								Book__c = MapBookSellerBooks.get(BookNames[i]).id,
								Price_Each__c = MapBookSellerBooks.get(BookNames[i]).Current_Price__c,
								Quantity__c = 1
								)
 							);Count1++;
 		if(Count1==10) break;
 		}
	}
	insert LT;
Set<String> names = new Set<String>();
	 List<Line_Item__c> lstLT =[select id,name from Line_Item__c];
	 for(Line_Item__c each: lstLT){
	 	names.add(each.Name);

	 }
  system.assertEquals(10,lstLT.Size());

   for(Product2 prd: [SELECT Id,Name,Account__c,Family,Account__r.Type,Account__r.name FROM Product2 
                                         WHERE //Account__r.Type = 'Warehouse' 
                                           //AND 
                                           Name IN : names]){
   	system.debug('Anydatatype_msg*** '+prd.Account__r.Type +' '+prd.Account__r.name);
   }


 


//Ship Order
	Test.startTest();
       Book_Order__c updateBook = [select id,name,Order_Status__c from Book_Order__c];
		updateBook.Order_Status__c = 'Ordered';
		Update updateBook;

	Book_Order__c updateBook1 = [select id,name,Order_Status__c from Book_Order__c];
	system.assertEquals(updateBook1.Order_Status__c,'Shipped');

	system.assertEquals(bookOrderRec.Order_Status__c,'Shipped');
	
	Test.stopTest();


  }


}