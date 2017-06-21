/*==============================================
* Apex Class Name : BookList
* Version             : 1.0 
* Created Date        : 23 February 2017
* Function            : Book Order Controller Test Class
* Modification Log 
* Developer                   Date                    Description
* -----------------------------------------------------------------------------------------------------------
* Krishna Bogavelli           02/23/2016            Final version
-------------------------------------------------------------------------------------------------------------
=================================================*/
@isTest
public class BookOrderPageControllerTest {
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
			for (Product2 eachPrd:eachSellerAcct.Products__r ){
				system.assertNotEquals(eachPrd.Current_Price__c,Null);
				countBooks.add(eachPrd.Name);
                //for bulk test capture books with greater than 200 records
                if (countBooks.size()>200){
					lstPrd.add(eachPrd);
                	BookNames.add(eachPrd.Name);
                	MapBookSellerBooks.put(eachPrd.Name,eachPrd);
                }
			}
			if (countBooks.size()>200){
     			acct = eachSellerAcct.Id;
                Break;
            }
		}
    
    //List<Product2> lstBooks_1 = [select id,name from product2 where account__c =: acct];
    //system.debug('test_1'+lstBooks_1.size());


	    //from above List of Book names get the inventory data.
		for(Product2 eachPrd: [Select id,name,Family,Inventory__c,Account__r.name
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
/*==============================================
Check following Methods from controller
*	addToShoppingCart
*	removeFromShoppingCart
*	updateFromShoppingCart
*	shipOrder
=================================================*/

static testMethod void TestMethodOne() {  system.debug('lstPrd '+lstPrd.size());
//check books in seller and whare house are matching
	for(string str: BookNames){  
		system.assertEquals(MapInventoryBooks.get(str).name,MapBookSellerBooks.get(str).Name); 
        system.assertEquals(100,MapInventoryBooks.get(str).Inventory__c);
        system.assertNOTEquals(Null,MapBookSellerBooks.get(str).Current_Price__c);
		}system.debug('Test data'+ bookOrderRec);

//start Test
	Test.startTest();  
//Assign page reference
   PageReference testPage = Page.BookOrderPage; system.assertNotEquals(Null,bookOrderRec.id);
   testPage.getParameters().put('id', bookOrderRec.id); 
   Test.setCurrentPage(testPage);
//Inititate Controller
	ApexPages.StandardController stc = new ApexPages.StandardController(bookOrderRec);
    BookOrderPageController bkCntrl = new BookOrderPageController(stc);
		//add line items to book order
		    	system.assertNotEquals(Null,lstPrd[0].id);
                system.assertNotEquals(Null,lstPrd[0].Current_Price__c);
			bkCntrl.selectedBookID = lstPrd[0].id;            	
		    bkCntrl.addToShoppingCart(); 
                                        
            	system.assertNotEquals(Null,lstPrd[1].id); 
                system.assertNotEquals(Null,lstPrd[1].Current_Price__c);
		    bkCntrl.selectedBookID = lstPrd[1].id; 
		    bkCntrl.addToShoppingCart(); 
		//assertion check for line items
		    List<Line_Item__c> lt = [select id from Line_Item__c where Book_Order__c  =: bookOrderRec.id];
		    system.assertEquals(2,lt.Size());
		//remove one line item
		    bkCntrl.selectedLineItemID = lt[0].id;
		    bkCntrl.removeFromShoppingCart();
		//assertion check for remove line item
    List<Line_Item__c> lt1 = [select id,Quantity__c from Line_Item__c where Book_Order__c  =: bookOrderRec.id];
    system.assertEquals(1,lt1.Size());
    
//Update LineItem by increasing the quantity
    for(Line_Item__c eachLt: lt1){
    	 system.assertEquals(1,eachLt.Quantity__c);
    	eachLt.Quantity__c = 2;
    	bkCntrl.updateFromShoppingCart();
    }
//assertion check for line item update    
    for(Line_Item__c eachLt: lt1){
    	 system.assertEquals(2,eachLt.Quantity__c);  
    }

//Shipp Order
    bkCntrl.shipOrder();

 Test.stopTest();
}
/*==============================================
*Check for Shoppingcart catch exception senario
*Check for Search Input senario
*Check for Delete catch Eception Senario
=================================================*/

static testMethod void TestMethodTwo() { 
    //clear existing list
	lstPrd.clear();
	system.assertEquals(lstPrd.size(),0);


	 //Get Books list and Bollser ID
	for (account eachSellerAcct: [SELECT id,name,type,RecordTypeId, (Select id,name,Account__r.name,Family,Current_Price__c from Products__r where Family <> 'Inventory' ) 
								FROM account  
								WHERE Type='Book Seller'  order by name asc ]){ 
		List<string> countBooks = new List<string>();
		for (Product2 eachPrd:eachSellerAcct.Products__r ){
			eachPrd.Current_Price__c = Null;
			system.assertEquals(eachPrd.Current_Price__c,Null);
			countBooks.add(eachPrd.Name);
            //for bulk test capture books with greater than 200 records
			if (countBooks.size()>200){
				lstPrd.add(eachPrd);
              	BookNames.add(eachPrd.Name);
            }
		} update lstPrd;
		if (countBooks.size()>200){
     		acct = eachSellerAcct.Id;
            Break;
		}
	}
    

	Test.startTest(); 
		PageReference testPage = Page.BookOrderPage; system.assertNotEquals(Null,bookOrderRec.id);
		testPage.getParameters().put('id', bookOrderRec.id); 
		Test.setCurrentPage(testPage);
		//Inititate Controller
		ApexPages.StandardController stc = new ApexPages.StandardController(bookOrderRec);
		BookOrderPageController bkCntrl = new BookOrderPageController(stc);
		//add line items to book orderly
		bkCntrl.selectedBookID = lstPrd[0].id; 
		bkCntrl.addToShoppingCart(); 
		bkCntrl.updateFromShoppingCart(); 
		bkCntrl.Userinput = 'Fantacy';
		bkCntrl.removeFromShoppingCart();
    bkCntrl.ShipOrder();
	Test.stopTest();

}

/*==============================================
*Check for Book Order ID missing Input senario
=================================================*/

static testMethod void TestMethodFour() { 

	Test.startTest(); 
		PageReference testPage = Page.BookOrderPage; system.assertNotEquals(Null,bookOrderRec.id);
		//testPage.getParameters().put('id', bookOrderRec.id); 
		Test.setCurrentPage(testPage);
		//Inititate Controller
		ApexPages.StandardController stc = new ApexPages.StandardController(bookOrderRec);
		BookOrderPageController bkCntrl = new BookOrderPageController(stc);
        	bkCntrl.ShipOrder();
	Test.stopTest();
}

}