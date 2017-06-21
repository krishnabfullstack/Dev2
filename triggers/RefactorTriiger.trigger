trigger RefactorTriiger on Book_Order__c (before Update) {
 
 if(Trigger.isUpdate){ 


    Map<Id,Product2> mapUpdatePrd = new Map<Id,Product2>();
    Map<id,id> BooksellerID = new Map<id,id>();
    id rtId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Book Seller').getRecordTypeId();  
    id rtWhareId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Warehouse').getRecordTypeId();   
    Set<String> BookNames = new Set<String>();
    Map<id,Line_Item__c> mapLineItems = NEW Map<id,Line_Item__c>();
    Map<id,Map<String,Decimal>> mapBOrdPrdNames = new Map<id,Map<String,Decimal>>();
    List<Product2> CollectionBooks = new List<Product2>(); 
    Map<id,Book_Order__c> lstBookOrder = new Map<id,Book_Order__c>();
    Map<id,List<Product2>> mapLTBookList = new Map<id,List<Product2>>(); 

    //---
    Map<id,Product2> refGetBookDetails = new Map<id,Product2>();
    Map<id,Decimal> retGetCollectionDetails = new Map<id,Decimal>();
    Map<id,id> mapGetBKID = new  Map<id,id> ();
     
/*************************************** describe each varaibales as well****************************************************/
  for (Book_Order__c eachBook: Trigger.new){
      lstBookOrder.put(eachBook.id,eachBook); 
  } 

       //getting book names and quantity ordered by cutomer                                                     
        Map<String,Decimal> mapBookNames = new Map<String,Decimal>();
  // looping through book order to capture Line Item details (book names and quantities)
  for (Line_Item__c eachLT: [SELECT id,name,Book_Order__c,Book_Order__r.Contact__r.Accountid,Book__r.Id,Book__r.name,Book__r.Family,Quantity__c 
							    FROM Line_Item__c
							    WHERE Book_Order__c in: Trigger.New]){ 
      if(lstBookOrder.get(eachLT.Book_Order__c).Order_Status__c == 'Ordered'){  // System.debug('Check1');
        //Get bookseller ID (Book order --> Contact --> AccountID)
        BooksellerID.put(eachLT.Book_Order__c,eachLT.Book_Order__r.Contact__r.Accountid);
            if(eachLT.Book__r.Family <> 'Collection'){ 
              mapLineItems.PUT(eachLT.Book_Order__c,eachLT);
              mapBookNames.Put(eachLT.Book__r.name, eachLT.Quantity__c);
              BookNames.add(eachLT.Book__r.name);   
            }
            if(eachLT.Book__r.Family == 'Collection'){
             CollectionBooks.add(new Product2(id=eachLT.Book__r.Id)); 
             retGetCollectionDetails.put(eachLT.Book__r.Id,eachLT.Quantity__c);
           //  mapGetBKID.put(eachLT.Book__r.Id,eachLT.Book_Order__c);
            }
        mapBOrdPrdNames.put(eachLT.Book_Order__c,mapBookNames); 
      }
  }

 /*******************************************************************************************/
  //Collect collection related books
  system.debug(retGetCollectionDetails);
    
    Map<id,Product2> mapCollectionBooks = new Map<id,Product2>(); 
	Map<String,Decimal> mapCollecBookNames = new Map<String,Decimal>();

	if(!CollectionBooks.isEmpty()){
	     mapCollectionBooks = new Map<id,Product2>([SELECT id,name,Collection__c,Family,Inventory__c
									FROM Product2 
								   WHERE Family <> 'Inventory' AND Collection__c in: CollectionBooks order by Collection__c]);
		
		for (Book_Order__c eachBook: lstBookOrder.Values()){
	  	  //before we add any new books Copy existing books to collections 
	  	  if(mapBOrdPrdNames.get(eachBook.id) != Null){
	  	  	mapCollecBookNames.PUTALL(mapBOrdPrdNames.get(eachBook.id));
			for(Product2 eachPrd: mapCollectionBooks.values() ){
				if(retGetCollectionDetails.get(eachPrd.Collection__c)!= Null){
					BookNames.add(eachPrd.Name); 
					mapCollecBookNames.put(eachPrd.Name,retGetCollectionDetails.get(eachPrd.Collection__c));
				}
				
				
			} mapBOrdPrdNames.Put(eachBook.Id,mapCollecBookNames); 
	  	  }
	 	}
	}

  system.debug('List of Book Names' +mapBOrdPrdNames); 
 /*******************************************************************************************/
/*
Notes:
in below logic it checks for these senarios
1) Select the whare house which has all Line Items 
2) Check inventory 
*/
  //get books realted to WhareHouse
  //**IMP--> Implement offset fi each whare house is having more than 50,000 records
  
 


  List<Account> lstAcctRecs = new List<Account>();
  if(!BookNames.isEmpty()){ 
    // retrives 24 accounts and related Inventory Books records
 Map<id,Product2> mapBooks = new Map<id,Product2> ([SELECT id,name,Inventory__c,Account__r.name 
                                FROM product2 
                              WHERE Family = 'Inventory' and Name in: BookNames Order by Account__r.name  Asc]);
 

  lstAcctRecs = [SELECT id,name//, 
                         // (SELECT id,name,Inventory__c FROM products__r WHERE Family = 'Inventory' and Name in: BookNames Limit 50000) 
                    FROM Account 
                   WHERE RecordTypeId =: rtWhareId order by Name Asc]; 
  

  //check if Account Wharehouse Inventory has books available and has sufficent in inventory, this will update 
    Map<id,Boolean> mapWharehouseHasSellerBooks = new Map<id,Boolean>();
   for (Book_Order__c eachBO: Trigger.new){ // system.debug('Entered Whare house check ****');
    if(lstBookOrder.get(eachBO.id).Order_Status__c == 'Ordered'){  
      //itterate each account, to check Line item has sufficient books in inventory to order
      for (Account eachAcct : lstAcctRecs){ //System.debug('Inventory WhareHouse Name'+eachAcct.Name);
          Map<String,id> WharehouseBookNames = new Map<String,id>(); //added on feb 17
          Map<id,Product2> WharehouseBooksDetails = new Map<id,Product2>(); //added on feb 17
          //store book in MAP for later use
          for (Product2 eachPrd : eachAcct.products__r){//System.debug('Invenlog 2 Book Name'+eachPrd.Name);
              WharehouseBookNames.put(eachPrd.Name,eachPrd.Id);
              WharehouseBooksDetails.put(eachPrd.Id,eachPrd);                                            
          }
          //checking if inventory has books
          for (String eachOrderedBooks: BookNames ){ //system.debug('Inventory search for Books '+eachOrderedBooks);
              //if inventory doesn't have the lineItem book, then revert back the order
              if(WharehouseBookNames.get(eachOrderedBooks) == Null){
                mapWharehouseHasSellerBooks.put(BooksellerID.get(eachBO.id),False); 
                eachBO.Order_Status__c = 'Backordered'; 
                Break;             
              }

              //Since Wharehouse has books reduce the invetory count in wharehouse based on number of books ordered
              Product2 prdDetails = WharehouseBooksDetails.get(WharehouseBookNames.get(eachOrderedBooks));
              if(mapBOrdPrdNames.get(eachBO.id) != Null ){
                if(mapBOrdPrdNames.get(eachBO.id).get(eachOrderedBooks) != Null){ //system.debug('Inventory search for Books Quantity Before '+prdDetails.Inventory__c);
                  prdDetails.Inventory__c = prdDetails.Inventory__c - mapBOrdPrdNames.get(eachBO.id).Get(eachOrderedBooks);
                  //system.debug('Inventory search for Books Quantity After '+prdDetails.Inventory__c);
                } 
              } 
              //add to map to update inventory Books
              mapUpdatePrd.put(PrdDetails.id,PrdDetails);

              //if inventory goes below 1, than Order must be Orderedback
              if(PrdDetails.Inventory__c < 0){ //system.debug('inventory is less than 0 '+PrdDetails.Inventory__c);               
                mapUpdatePrd.remove(PrdDetails.id); 
                Break;
              }

              //Since the Books are available in inventory with sufficient quantity to order set the map "mapWharehouseHasSellerBooks" to True
              mapWharehouseHasSellerBooks.put(BooksellerID.get(eachBO.id),True); 
          }
         // System.debug(eachAcct.Name);
          // system.debug('Inventory search Sucess '+mapWharehouseHasSellerBooks.get(BooksellerID.get(eachBO.id)));                                    
          if(mapWharehouseHasSellerBooks.get(BooksellerID.get(eachBO.id)) != Null){  
            Boolean existInWharehouse = mapWharehouseHasSellerBooks.get(BooksellerID.get(eachBO.id)); 
            if(existInWharehouse == True){
              eachBO.Order_Status__c = 'Shipped'; //system.debug('Log***'+eachBO.Order_Status__c);
             Break;
            } 
            else {
            eachBO.Order_Status__c = 'Backordered'; 
            }
          }           
      } //system.debug('Book Seller Result 2'+mapWharehouseHasSellerBooks.get(BooksellerID.get(eachBO.id)));
      //If Product to be update is empty set order status to Backordered
      if(mapUpdatePrd.isEmpty()){  
        eachBO.Order_Status__c = 'Backordered';     
      }
    } 
  }

  system.debug('Final update to Product' +mapUpdatePrd);
  if(!mapUpdatePrd.isEmpty()){
    Update mapUpdatePrd.values();
  }

}

}