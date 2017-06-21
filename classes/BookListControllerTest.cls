@isTest
public class BookListControllerTest { 

//in regular day to day work i create test data Helper Class, which will have various objects data creation methods
  @testSetup static void caseTestData() {

	id BookSellRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Book Seller').getRecordTypeId();  
	id WhareRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Warehouse').getRecordTypeId(); 

	List<Account> bookSellerAcct = new List<Account>();
	List<Account> WhareHouseAcct = new List<Account>();

//created 24 Book wharehouse Accounts
	for (Integer i=0; i<24; i++){ 
	    WhareHouseAcct.add(new Account(Name = 'Warehouse'+i,RecordTypeId =WhareRecTypeId, Type= 'Warehouse'));
	}
	Insert WhareHouseAcct;

//created  202 Book Seller Accounts 
	for (Integer i=0; i<202; i++){  
	    bookSellerAcct.add(new Account(Name = 'Book Seller Store'+i,RecordTypeId =BookSellRecTypeId, Type= 'Book Seller'  ));
	}
	Insert bookSellerAcct;

//Created Books
 	List<Account> getBookSellerAcct = [select id from account where type ='Book Seller'];
	List<Account> getWhareHouseAcct = [select id from account where type ='Warehouse'];

    List<Product2> BookSellerBooks = new List<Product2>();
    List<Product2> WhareHouseBooks = new List<Product2>();

    Integer count = 0;
    for (Integer i=0;i<300;i++){
    	//Inventory Record
    	system.assertNotEquals(getWhareHouseAcct[2].Id,Null);
    	 WhareHouseBooks.add(new Product2(name = 'Book_'+i,Family = 'Inventory',IsActive=True,Inventory__c = 100,Account__c = getWhareHouseAcct[2].Id ));
    	if(i<30){system.assertNotEquals(getWhareHouseAcct[0].Id,Null);
    	   WhareHouseBooks.add(new Product2(name = 'Book_'+i,Family = 'Inventory',IsActive=True,Inventory__c = 100,Account__c = getWhareHouseAcct[0].Id ));		
    	} else {
    		 WhareHouseBooks.add(new Product2(name = 'Book_'+i,Family = 'Inventory',IsActive=True,Inventory__c = 100,Account__c = getWhareHouseAcct[1].Id ));
    	}

    	
        //Collection Records
    	if(i==0){
    	  BookSellerBooks.add(new Product2(name = 'Book_'+i,Family = 'Collection',IsActive=True,Current_Price__c = 20,Account__c = getBookSellerAcct[0].Id));	
    	}
        //Paperback Records
     	if(i>0 && i<40){
     	  if(i <30){
     	     BookSellerBooks.add(new Product2(name = 'Book_'+i,Family = 'Paperback',IsActive=True,Current_Price__c = 20,Account__c = getBookSellerAcct[0].Id ));		
     	  }else{
     	  	 BookSellerBooks.add(new Product2(name = 'Book_'+i,Family = 'Paperback',IsActive=True,Current_Price__c = 20,Account__c = getBookSellerAcct[1].Id ));		
     	  }  
    	}
    	//Hardcover Records
     	if(i>=40 ){
	    	if(i>=60){
	    		BookSellerBooks.add(new Product2(name = 'Book_'+i,Family = 'Hardcover',IsActive=True,Current_Price__c = 20,Account__c = getBookSellerAcct[1].Id ));	
	    	}else {
	    		BookSellerBooks.add(new Product2(name = 'Book_'+i,Family = 'Hardcover',IsActive=True,Current_Price__c = 20,Account__c = getBookSellerAcct[0].Id ));	
	    	}
    	}
    	          
       
    }
    Insert BookSellerBooks; Insert WhareHouseBooks;

// creating list of books under Collections
	List<Product2> getBooks = [select id,Family,Name,Current_Price__c,Account__r.Name from Product2 where Family != 'Inventory' order by Name Asc];
	System.assertNOTEquals(getBooks.Size(),0,'SIZE IS zero');
	Map<String,Product2> mapGetBooks = new Map<String,Product2>();
	for(Product2 eachBook: getBooks){
		mapGetBooks.put(eachBook.Name,eachBook);
	}

	List<Product2> UpdateBooks = New   List<Product2>();
    for(Product2 eachPrd: getBooks){
        if(eachPrd.Name.Contains('Book_3')){
        	if(eachPrd.Family <> 'Inventory' && mapGetBooks.get('Book_0').Family  <> 'Inventory') {
        		if(eachPrd.Family <> 'Collection' && mapGetBooks.get('Book_3').Family  <> 'Collection'){
        	       eachPrd.Collection__c = mapGetBooks.get('Book_0').ID;		
        	       UpdateBooks.add(eachPrd);
        	       system.debug(UpdateBooks);
        	       	System.debug('Name = '+eachPrd.Name+'Family = '+eachPrd.Family +' === '+eachPrd.Collection__c +'Account Name = '+eachPrd.Account__r.Name );
        		}
           }
        }
    }
	Update UpdateBooks;
 
//Creating Contact Records
	List<Contact> ContactRecs = new List<Contact>();
	user userinfo = [select id from user where name = 'BWS Customer'];
	for (Integer i=0;i<1;i++){ 
		ContactRecs.add(new Contact(LastName = 'TestOrderUser'+i, User__c = userinfo.id, AccountId = getBookSellerAcct[i].id )); 
	}
	Insert ContactRecs;

}
 
 static Map<id,Account> mapGetBooks = New Map<id,Account>();
 static List<Product2> lstPrd = new List<Product2>();
 static List<String> BookNames = New List<String>();
 static id acct;
 static Map<String,Product2> MapInventoryBooks = New Map<String,Product2>();
 static Contact contactRec = New Contact();

 static{ 
	 	//Get Books list and Bollser ID
	 	List<account> lstAcct =[select id,name,type, (Select id,name,Account__r.name,Family,Current_Price__c from Products__r  ) 
									from account  
									where Type='Book Seller'  order by name asc ];
		system.assertNotEquals(lstAcct.size(),0);
	 	//get only Booksellers having books and for current test considering only one record
		for (account eachacct: lstAcct){ mapGetBooks.put(eachacct.Id,eachacct); system.assertNOTEquals(eachacct.Products__r.size(),0);

			for (Product2 eachPrd:eachacct.Products__r ){ 	
				 lstPrd.add(eachPrd);BookNames.add(eachPrd.Name);
			}
			if(lstPrd.size()>0){acct = eachacct.Id;Break;}
		}


	    //from above List of Book names get the inventory data.
		for(Product2 eachPrd: [Select id,name,Family,Inventory__c,Account__r.name
								from Product2 where name in: BookNames 
								    and Family = 'Inventory'  order by name asc ]){
			MapInventoryBooks.Put(eachPrd.Name,eachPrd);
			system.assertNotEquals(eachPrd.Inventory__c,Null);
			system.assertNotEquals(eachPrd.Inventory__c,0);
		}

		//Create contactRec
		contactRec = [Select id,name,User__r.Name,Account.Name from Contact where Accountid =: acct Limit 1];
}

 /********************This will check follwoing Senarios 1)  **********************/ 
 
static testMethod void TestMethodOne_BookList() { 

    system.assertNotEquals(lstPrd.size(),0,'Product has no records');

    system.assertEquals(contactRec.Account.Name,mapGetBooks.get(acct).Name, 'Book seller ID is not matching');

//Create Book Order
	Book_Order__c bookOrderRec= new Book_Order__c(Name = 'order_2',Contact__c  = ContactRec.id);
	Insert bookOrderRec; 
 
//Ship Order
	Test.startTest();  
	Book_Order__c updateBO = [select id, Order_Status__c from Book_Order__c]; 

   PageReference testPage = Page.BookOrderPage; system.assertNotEquals(lstPrd[0].id,Null);
   testPage.getParameters().put('selectedBookID', lstPrd[0].id); 
        Test.setCurrentPage(testPage);

	ApexPages.StandardController stc = new ApexPages.StandardController(updateBO);
    Bookslist bkCntrl = new Bookslist(stc);
//add line items to book order
    bkCntrl.selectedBookID = lstPrd[0].id; 
    bkCntrl.addToShoppingCart();
    bkCntrl.selectedBookID = lstPrd[0].id; 
    bkCntrl.addToShoppingCart();
 //assertion check for line items
    List<Line_Item__c> lt = [select id from Line_Item__c where Book_Order__c  =: updateBO.id];
    system.assertEquals(lt.Size(),2);

//remove one line item
    bkCntrl.selectedLineItemID = lt[0].id;
    bkCntrl.removeFromShoppingCart();
//assertion check for remove line item
    List<Line_Item__c> lt1 = [select id,Quantity__c from Line_Item__c where Book_Order__c  =: updateBO.id];
    system.assertEquals(lt1.Size(),1);
    
//Update LineItem by increasing the quantity
    for(Line_Item__c eachLt: lt1){
    	 system.assertEquals(eachLt.Quantity__c,1);
    	eachLt.Quantity__c = 2;
    	bkCntrl.updateFromShoppingCart();
    }
//assertion check for line item update    
    for(Line_Item__c eachLt: lt1){
    	 system.assertEquals(eachLt.Quantity__c,2);  
    }

//Shipp Order
    bkCntrl.shipOrder();
    
   Test.stopTest(); 
	 
}
/* 
static testMethod void TestMethodTwo_BookList() { 

//Get Books list and Bollser ID
	Map<id,Account> mapGetBooks = new Map<id,Account>([select id,name,type, (Select id,name,Account__r.name,Family,Current_Price__c from Products__r  ) 
								from account  
								where Type='Book Seller'  order by name asc ]);
	System.debug('getBooks'+mapGetBooks.size());
	List<Product2> lstPrd = new List<Product2>(); List<String> BookNames = new List<String>();
	id acct;
//get only Booksellers having books and for current test considering only one record	 
	for (account eachacct: mapGetBooks.Values()){  
		for (Product2 eachPrd:eachacct.Products__r ){
			eachPrd.Current_Price__c = Null;
			 lstPrd.add(eachPrd);BookNames.add(eachPrd.Name); 
		}
		if(lstPrd.size()>0){acct = eachacct.Id;Break;}
	}
	update lstPrd;
	system.debug('Products List' + lstPrd);   
    system.assertNotEquals(lstPrd.size(),0,'Product has no records');

//from above List of Book names get the inventory data
	Map<String,Product2> MapInventoryBooks = new Map<String,Product2> ();
	for(Product2 eachPrd: [Select id,name,Family,Inventory__c,Account__r.name
							from Product2 where name in: BookNames 
							    and Family = 'Inventory'  order by name asc ]){
		MapInventoryBooks.Put(eachPrd.Name,eachPrd);
		system.assertNotEquals(eachPrd.Inventory__c,Null);
		system.assertNotEquals(eachPrd.Inventory__c,0);
		//system.debug(eachPrd.Account__r.name+' ; '+eachPrd.Name+' ; '+eachPrd.Family+' ; ' +eachPrd.Inventory__c);
	}


//Create contactRec
	 Contact contactRec = [Select id,name,User__r.Name,Account.Name from Contact where Accountid =: acct Limit 1];
	 system.assertEquals(contactRec.Account.Name,mapGetBooks.get(acct).Name, 'Book seller ID is not matching');

//Create Book Order
	Book_Order__c bookOrderRec= new Book_Order__c(Name = 'order_2',Contact__c  = ContactRec.id);
	Insert bookOrderRec; 
 
//Ship Order
	Test.startTest();  
	Book_Order__c updateBO = [select id, Order_Status__c from Book_Order__c]; 

   PageReference testPage = Page.BookOrderPage; system.assertNotEquals(lstPrd[0].id,Null);
   testPage.getParameters().put('selectedBookID', lstPrd[0].id); 
        Test.setCurrentPage(testPage);

	ApexPages.StandardController stc = new ApexPages.StandardController(updateBO);
    Bookslist bkCntrl = new Bookslist(stc);
    bkCntrl.selectedBookID = lstPrd[0].id;  
    bkCntrl.addToShoppingCart();
    bkCntrl.updateFromShoppingCart(); 
    bkCntrl.ShipOrder();
	Test.stopTest(); 
	 
}
 */
       
}