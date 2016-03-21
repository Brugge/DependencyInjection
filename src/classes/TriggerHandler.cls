public virtual class TriggerHandler {

	// static map of handlername, times run() was invoked
	private static Map<String, LoopCount> loopCountMap;
	private static Set<String> bypassedHandlers;

	// the current context of the trigger, overridable in tests
	@TestVisible
	private TriggerContext context;

	// the current context of the trigger, overridable in tests
	@TestVisible
	private Boolean isTriggerExecuting;

	// static initialization
	static {
		loopCountMap = new Map<String, LoopCount> ();
		bypassedHandlers = new Set<String> ();
	}

	// constructor
	public TriggerHandler() {
		this.setTriggerContext();
	}

	/***************************************
	 * public instance methods
	 ***************************************/

	// main method that will be called during execution
	public void run() {

		if (!validateRun()) return;

		addToLoopCount();

		// dispatch to the correct handler method
		if (this.context == TriggerContext.BEFORE_INSERT) {
			this.beforeInsert();
		} else if (this.context == TriggerContext.BEFORE_UPDATE) {
			this.beforeUpdate();
		} else if (this.context == TriggerContext.BEFORE_DELETE) {
			this.beforeDelete();
		} else if (this.context == TriggerContext.AFTER_INSERT) {
			this.afterInsert();
		} else if (this.context == TriggerContext.AFTER_UPDATE) {
			this.afterUpdate();
		} else if (this.context == TriggerContext.AFTER_DELETE) {
			this.afterDelete();
		} else if (this.context == TriggerContext.AFTER_UNDELETE) {
			this.afterUndelete();
		}

	}

	public void setMaxLoopCount(Integer max) {
		String handlerName = getHandlerName();
		if (!TriggerHandler.loopCountMap.containsKey(handlerName)) {
			TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
		} else {
			TriggerHandler.loopCountMap.get(handlerName).setMax(max);
		}
	}

	public void clearMaxLoopCount() {
		this.setMaxLoopCount(- 1);
	}

	/***************************************
	 * public static methods
	 ***************************************/

	public static void bypass(String handlerName) {
		TriggerHandler.bypassedHandlers.add(handlerName);
	}

	public static void clearBypass(String handlerName) {
		TriggerHandler.bypassedHandlers.remove(handlerName);
	}

	public static Boolean isBypassed(String handlerName) {
		return TriggerHandler.bypassedHandlers.contains(handlerName);
	}

	public static void clearAllBypasses() {
		TriggerHandler.bypassedHandlers.clear();
	}
	
	public static Map<String,List<sObject>> newInheritanceMap;
	public static Map<String,Map<Id,sObject>> oldInheritanceMap;
	public static void getInheritanceObjectMap(String objectName, String callType, List<sObject> newObjs, Map<Id,sObject> oldObjs, boolean isDeleteContext) {
		newInheritanceMap = new Map<String,List<sObject>>();
		oldInheritanceMap = new Map<String,Map<Id,sObject>>();
		if(isDeleteContext){
			mapInheretanceSetting(objectName, callType, oldObjs.values(), true);
		}else{
			mapInheretanceSetting(objectName, callType, newObjs, false);
		}
		if(newObjs != NULL && oldObjs != NULL){
			for(String s : newInheritanceMap.keySet()){
				List<sObject> tempList = new List<sObject>();
				for (sObject sObj : newInheritanceMap.get(s)){
					tempList.add(oldObjs.get(sObj.id));
				}
				Map<Id,sObject> tempMap = new Map<Id,sObject>(tempList); 
				oldInheritanceMap.put(s,tempMap);
			}
		}
	}

	/***************************************
	 * private instancemethods
	 ***************************************/

	 private static void mapInheretanceSetting(String objectName, String callType, List<sObject> sObjs, boolean isDeleteContext){
		List<Inheritance_Setting__mdt> settings = [SELECT DeveloperName, Object__c, Type__c, Record_Type_1__c, Record_Type_2__c, Record_Type_3__c, Record_Type_4__c, Record_Type_5__c, Record_Type_6__c FROM Inheritance_Setting__mdt WHERE Object__c =: objectName AND Type__c =: callType];
		Map<Id,RecordType> recTypeMap = RecordTypeDAO.getAllRecordTypes().get(objectName);
		Map<String,String> recordTypeNameToClass = buildRT2NameMap(settings);
		for (sObject sObj : sObjs){
			String applicableClass = recordTypeNameToClass.get(recTypeMap.get((id)sObj.get('recordTypeId')).DeveloperName);
			if (applicableClass != NULL)
			{
			List<sObject> newsObjList = new List<sObject>();
			Map<Id,sObject> oldsObjMap = new Map<Id,sObject>();
			if(isDeleteContext){
				if (oldInheritanceMap.containsKey(applicableClass)){
					oldsObjMap = oldInheritanceMap.get(applicableClass);
				}
				oldsObjMap.put(sObj.Id,sObj);
				oldInheritanceMap.put(applicableClass,oldsObjMap);
			}else{
				if (newInheritanceMap.containsKey(applicableClass)){
					newsObjList = newInheritanceMap.get(applicableClass);
				}
				newsObjList.add(sObj);
				newInheritanceMap.put(applicableClass,newsObjList);
				}
			}
		}
	 }

	 private static Map<String,String> buildRT2NameMap(List<Inheritance_Setting__mdt> settings){
		Map<String,String> tempMap = new Map<String,String>();
		for (Inheritance_Setting__mdt inhSet : settings){
			if (inhSet.Record_Type_1__c != NULL){
				tempMap.put(inhSet.Record_Type_1__c,inhSet.DeveloperName);
			}
			if (inhSet.Record_Type_2__c != NULL){
				tempMap.put(inhSet.Record_Type_2__c,inhSet.DeveloperName);
			}
			if (inhSet.Record_Type_3__c != NULL){
				tempMap.put(inhSet.Record_Type_3__c,inhSet.DeveloperName);
			}
			if (inhSet.Record_Type_4__c != NULL){
				tempMap.put(inhSet.Record_Type_4__c,inhSet.DeveloperName);
			}
			if (inhSet.Record_Type_5__c != NULL){
				tempMap.put(inhSet.Record_Type_5__c,inhSet.DeveloperName);
			}
			if (inhSet.Record_Type_6__c != NULL){
				tempMap.put(inhSet.Record_Type_6__c,inhSet.DeveloperName);
			}
		}
		return tempMap;
	 }

	@TestVisible
	private void setTriggerContext() {
		this.setTriggerContext(null, false);
	}

	@TestVisible
	private void setTriggerContext(String ctx, Boolean testMode) {
		if (!Trigger.isExecuting && !testMode) {
			this.isTriggerExecuting = false;
			return;
		} else {
			this.isTriggerExecuting = true;
		}

		if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
		(ctx != null && ctx == 'before insert')) {
			this.context = TriggerContext.BEFORE_INSERT;
		} else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
		(ctx != null && ctx == 'before update')) {
			this.context = TriggerContext.BEFORE_UPDATE;
		} else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
		(ctx != null && ctx == 'before delete')) {
			this.context = TriggerContext.BEFORE_DELETE;
		} else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
		(ctx != null && ctx == 'after insert')) {
			this.context = TriggerContext.AFTER_INSERT;
		} else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
		(ctx != null && ctx == 'after update')) {
			this.context = TriggerContext.AFTER_UPDATE;
		} else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
		(ctx != null && ctx == 'after delete')) {
			this.context = TriggerContext.AFTER_DELETE;
		} else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
		(ctx != null && ctx == 'after undelete')) {
			this.context = TriggerContext.AFTER_UNDELETE;
		}
	}

	// increment the loop count
	@TestVisible
	private void addToLoopCount() {
		String handlerName = getHandlerName();
		if (TriggerHandler.loopCountMap.containsKey(handlerName)) {
			Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
			if (exceeded) {
				Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
				throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
			}
		}
	}

	// make sure this trigger should continue to run
	@TestVisible
	private Boolean validateRun() {
		if (!this.isTriggerExecuting || this.context == null) {
			throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
		}
		if (TriggerHandler.bypassedHandlers.contains(getHandlerName())) {
			return false;
		}
		return true;
	}

	@TestVisible
	private String getHandlerName() {
		return String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
	}

	/***************************************
	 * context methods
	 ***************************************/

	// context-specific methods for override
	@TestVisible
	protected virtual void beforeInsert() { }
	@TestVisible
	protected virtual void beforeUpdate() { }
	@TestVisible
	protected virtual void beforeDelete() { }
	@TestVisible
	protected virtual void afterInsert() { }
	@TestVisible
	protected virtual void afterUpdate() { }
	@TestVisible
	protected virtual void afterDelete() { }
	@TestVisible
	protected virtual void afterUndelete() { }

	/***************************************
	 * inner classes
	 ***************************************/

	// inner class for managing the loop count per handler
	@TestVisible
	private class LoopCount {
		private Integer max;
		private Integer count;

		public LoopCount() {
			this.max = 5;
			this.count = 0;
		}

		public LoopCount(Integer max) {
			this.max = max;
			this.count = 0;
		}

		public Boolean increment() {
			this.count++;
			return this.exceeded();
		}

		public Boolean exceeded() {
			if (this.max < 0) return false;
			if (this.count > this.max) {
				return true;
			}
			return false;
		}

		public Integer getMax() {
			return this.max;
		}

		public Integer getCount() {
			return this.count;
		}

		public void setMax(Integer max) {
			this.max = max;
		}
	}

	// possible trigger contexts
	@TestVisible
	private enum TriggerContext {
		BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
		AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
		AFTER_UNDELETE
	}

	// exception class
	public class TriggerHandlerException extends Exception { }

}