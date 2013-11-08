public with sharing class aci_test_SOQL_SOSL_DML_SendEmail {
	
	public static void demo() {
		//TO DO: complete smth here
		for(Integer i = 0; i < 100; i ++) {
			//SOQL
			Account [] accounts = [select id from Account];
			//SOSL
			List<Sobject[]> objects = [FIND 'smth' IN ALL FIELDS RETURNING Account(id,name)];
			//send email
			Messaging.sendEmail(new List<Messaging.Email>());
		}
		//TO DO: complete smth here
		while(true) {
			//SOQL
			Account [] accounts = [select id from Account];
			//SOSL
			List<Sobject[]> objects = [FIND 'smth' IN ALL FIELDS RETURNING Account(id,name)];
			//DML
			Database.update(accounts);
			//send email
			Messaging.sendEmail(new List<Messaging.Email>());
		}
		//TO DO: complete smth here
		do {
			//SOQL
			Account [] accounts = [select id from Account];
			//SOSL
			List<Sobject[]> objects = [FIND 'smth' IN ALL FIELDS RETURNING Account(id,name)];
			//DML
			Database.update(accounts);
			//send email
			Messaging.sendEmail(new List<Messaging.Email>());
		}
		while(true);
	}
	
}