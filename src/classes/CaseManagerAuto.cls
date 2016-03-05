public class CaseManagerAuto implements TriggerManager{ 

	public static void beforeInsert(List<sObject> casesToInsert){
		System.debug('In CaseManagerAuto! '+casesToInsert);
	}
	public static void beforeUpdate(){}
	public static void beforeDelete(){}
	public static void afterInsert(){}
	public static void afterUpdate(){}
	public static void afterDelete(){}
	public static void afterUndelete(){}
}