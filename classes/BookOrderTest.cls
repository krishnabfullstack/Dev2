@istest
public class BookOrderTest {

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


/********************This will check follwoing Senarios 
1) Order status changed to Shipped
2) Whare house has records
3) Reduce the Wharehouse inventory count
4) Collections has books
**********************/ 
 /*
 static testMethod void TestMethodOne() { 
 
 //Get Books list
	List<Product2> getBooks = [select id,Family,Name,Current_Price__c,Inventory__c from Product2 where Family != 'Inventory' order by Name Asc];
	Map<String,Product2> mapGetBooks = new Map<String,Product2>();
	for(Product2 eachBook: getBooks){
		mapGetBooks.put(eachBook.Name,eachBook);
	}


//Create Book order
	Contact getContactRecs = [Select id from Contact order by Name Asc Limit 1];
	Book_Order__c BO = new Book_Order__c(Name = 'order_1',Contact__c  = getContactRecs.id);
	Insert BO;
    
//Create Line Item 
	List<Line_Item__c> LT = new List<Line_Item__c>();
    List<String> BookNames = new List<String>();
	for(Integer i=18; i<50; i++){  
		String BookName= 'Book_'+i; 

		if(getBooks[i].Family <> 'Inventory' && mapGetBooks.get(BookName).Family <> 'Inventory') {		
			LT.add(new Line_Item__c(Book_Order__c = BO.ID, 
				                    Name=mapGetBooks.get(BookName).Name, 
			Book__c = mapGetBooks.get(BookName).id,
			Price_Each__c = mapGetBooks.get(BookName).Current_Price__c ));
			BookNames.add(mapGetBooks.get(BookName).Name);
		}
	}
	Insert LT;

//Ship Order
	Test.startTest();

		Book_Order__c updateBO = [select id, Order_Status__c from Book_Order__c];
		system.assertNotEquals(UpdateBo.Order_Status__c, 'Shipped');
		updateBO.Order_Status__c = 'Ordered';
		Update updateBO;

	Test.stopTest();

//  Wharehouse inventory count Check
	for (Product2 eachPrd: [SELECT id,name,Inventory__c FROM Product2 WHERE Family = 'Inventory' and Name in: BookNames]){
         system.assertNotEquals(eachPrd.Inventory__c,mapGetBooks.get(eachPrd.Name).Inventory__c);
	}

	Book_Order__c  CheckBO = [select id, Order_Status__c from Book_Order__c];
	system.assertEquals(CheckBO.Order_Status__c,'Shipped','Failed to Ship');



}
*/ 
/*********************Validate if inventory is not having sufficient books*********************/
 
static testMethod void TestMethodTwo_InvetoryQuantityZero() { 


	List<Product2> updateBooksInvetory = new List<Product2>();
	for(Product2 eachPrd: [select id,Family,Name,Current_Price__c,Inventory__c from Product2 where Family = 'Inventory' order by Name Asc]){
		eachPrd.Inventory__c = 0;  
		updateBooksInvetory.add(eachPrd);
	}
	Update updateBooksInvetory;


//Get Books list
	List<Product2> getBooks = [select id,Family,Name,Current_Price__c from Product2 where Family != 'Inventory' order by Name Asc];
	Map<String,Product2> mapGetBooks = new Map<String,Product2>();
	for(Product2 eachBook: getBooks){
		mapGetBooks.put(eachBook.Name,eachBook);
	}


//Create Book order
	List<Contact> getContactRecs = [Select id from Contact];
	Book_Order__c BO = new Book_Order__c(Name = 'order_2',Contact__c  = getContactRecs[0].id);

	Insert BO;

//Create Line Item 
	List<Line_Item__c> LT = new List<Line_Item__c>();
	if(mapGetBooks.get('Book_31').Family <> 'Inventory') {
	LT.add(new Line_Item__c(Book_Order__c = BO.ID, 
							Name=mapGetBooks.get('Book_31').Name, 
							Book__c = mapGetBooks.get('Book_31').id,
							Quantity__c = 1,
							Price_Each__c = mapGetBooks.get('Book_31').Current_Price__c ));
	}
 	Insert LT;

//Ship Order
	Test.startTest();

	for(Product2 eachPrd: [select id,Family,Name,Current_Price__c,Inventory__c from Product2 where Family = 'Inventory' order by Name Asc]){
		system.assertEquals(eachPrd.Inventory__c,0,'Inventory is not Zero');
	}
	Book_Order__c updateBO = [select id, Order_Status__c from Book_Order__c];
	updateBO.Order_Status__c = 'Ordered';
	system.debug('Test 1**'+updateBO);
	Update updateBO;

	system.debug('Test 2**'+updateBO);
	Book_Order__c asrtCheckBO = [select id, Order_Status__c from Book_Order__c ];
	system.assertNotEquals(asrtCheckBO.Order_Status__c,'BackOrdered','Failed Inventory Backorder');


	Test.stopTest(); 
}

 
/*********************Validate if inventory is not having sufficient books*********************/
/********************This will check follwoing Senarios 
1) Order status changed to Shipped
2) Whare house has records
3) Reduce the Wharehouse inventory count
4) Collections has books
**********************/ 
static testMethod void TestMethodTwo_InvetoryQuantity() { 

//Get Books list and Bollser ID
	Map<id,Account> mapGetBooks = new Map<id,Account>([select id,name,type, (Select id,name,Account__r.name,Family,Current_Price__c from Products__r  ) 
								from account  
								where Type='Book Seller'  order by name asc ]);
	System.debug('getBooks'+mapGetBooks.size());
	List<Product2> lstPrd = new List<Product2>(); List<String> BookNames = new List<String>();
	id acct;
	 
	for (account eachacct: mapGetBooks.Values()){ 
		acct = eachacct.Id;
		for (Product2 eachPrd:eachacct.Products__r ){
			 lstPrd.add(eachPrd);BookNames.add(eachPrd.Name);

		}
		if(lstPrd.size()>0){Break;}
	}
	system.debug('Products List' + lstPrd);   
    system.assertNotEquals(lstPrd.size(),0,'Product has no records');

//get inventory data
	Map<String,Product2> MapInventoryBooks = new Map<String,Product2> ();
	for(Product2 eachPrd: [Select id,name,Family,Inventory__c,Account__r.name
							from Product2 where name in: BookNames 
							    and Family = 'Inventory'  order by name asc ]){
		MapInventoryBooks.Put(eachPrd.Name,eachPrd);
		system.assertNotEquals(eachPrd.Inventory__c,Null);
		system.assertNotEquals(eachPrd.Inventory__c,0);
		//system.debug(eachPrd.Account__r.name+' ; '+eachPrd.Name+' ; '+eachPrd.Family+' ; ' +eachPrd.Inventory__c);
	}


//Create Book order
	 Contact contactRec = [Select id,name,User__r.Name,Account.Name from Contact where Accountid =: acct Limit 1];
	 system.assertEquals(contactRec.Account.Name,mapGetBooks.get(acct).Name, 'Book seller ID is not matching');

//Create Book Order
	Book_Order__c bookOrderRec= new Book_Order__c(Name = 'order_2',Contact__c  = ContactRec.id);
	Insert bookOrderRec;


//Create Line Item 
	List<Line_Item__c> lineItemRec = new List<Line_Item__c>();
	for(Product2 eachprd: lstPrd){
	lineItemRec.add(new Line_Item__c(Book_Order__c = bookOrderRec.id, 
							Name=eachprd.Name, 
							Book__c = eachprd.id,
							Quantity__c = 1,
							Price_Each__c = eachprd.Current_Price__c ));
	    system.debug(';Book Name '+eachprd.Name+';Book Seller Name '+MapInventoryBooks.get(eachprd.Name).Account__r.Name +' ; '+MapInventoryBooks.get(eachprd.Name).Inventory__c+';Seller Name '+eachprd.Name +';'+eachprd.Family);
	     
	}
 

 	Insert lineItemRec;

 	for(Line_Item__c eachLT: [select id,name,Quantity__c from Line_Item__c ]){
 	 system.debug('Line Item Rec' +eachLT);
 	}
 
//Ship Order
	Test.startTest();

 
	Book_Order__c updateBO = [select id, Order_Status__c from Book_Order__c];
	updateBO.Order_Status__c = 'Ordered';
	system.debug('Test 1**'+updateBO);
	Update updateBO;

	system.debug('Test 2**'+updateBO);
	Book_Order__c asrtCheckBO = [select id, Order_Status__c from Book_Order__c ];
	system.assertEquals(asrtCheckBO.Order_Status__c,'Shipped','Failed Inventory to Ship');
     
	//get inventory data
	Integer Count = 0;
	Map<String,Product2> MapInventoryBooks1 = new Map<String,Product2> ();
	for(Product2 eachPrd: [Select id,name,Family,Inventory__c,Account__r.name
							from Product2 where name in: BookNames
							//and    Account__c =: acct
							    and Family = 'Inventory'  order by name asc ]){
		MapInventoryBooks1.Put(eachPrd.Name,eachPrd);
		  system.debug(eachPrd.Account__r.name+' ; '+eachPrd.Name+' ; '+eachPrd.Family+' ; inv ' +eachPrd.Inventory__c);
		 if(eachPrd.Inventory__c < 100){
		 	System.assertEquals(eachPrd.Inventory__c,99);
		 	Count ++;
		 }
	}

	//system.assertEquals(lineItemRec.Size(),Count);
	Test.stopTest(); 
	 
}



       
}