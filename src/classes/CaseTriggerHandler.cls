public without sharing class CaseTriggerHandler extends TriggerHandler
{
    public Map<String,IManager> caseManagerMap;
    public Set<String> applicableClasses;

    public CaseTriggerHandler() {
        if (Trigger.isDelete){
            TriggerHandler.getInheritanceObjectMap('Case','TriggerHandler',Trigger.new, Trigger.oldMap,true);
        }else{
            TriggerHandler.getInheritanceObjectMap('Case','TriggerHandler',Trigger.new, Trigger.oldMap,false);
        }
        caseManagerMap = new Map<String,IManager>();
        applicableClasses = new Set<String>();
        applicableClasses.addAll(newInheritanceMap.keySet());
        applicableClasses.addAll(oldInheritanceMap.keySet());
        if (!applicableClasses.isEmpty()){
            for(String s : applicableClasses){
            IManager tm = (IManager)Type.forName(s).newInstance();
            caseManagerMap.put(s,tm);
            }
        }
    }

    public override void beforeInsert()
    {
        for(String s: applicableClasses){
            caseManagerMap.get(s).beforeInsert(newInheritanceMap.get(s));
        }
    }

    public override void beforeUpdate()
    {
        for(String s: applicableClasses){
            caseManagerMap.get(s).beforeUpdate(newInheritanceMap.get(s),oldInheritanceMap.get(s));
        }
    }

    public override void beforeDelete()
    {
        for(String s: applicableClasses){
            caseManagerMap.get(s).beforeDelete(oldInheritanceMap.get(s));
        }
    }

    public override void afterInsert()
    {
        for(String s: applicableClasses){
            caseManagerMap.get(s).afterInsert(newInheritanceMap.get(s));
        }
    }

    public override void afterUpdate()
    {
        for(String s: applicableClasses){
            caseManagerMap.get(s).afterUpdate(newInheritanceMap.get(s),oldInheritanceMap.get(s));
        }
    }

    public override void afterDelete()
    {
        for(String s: applicableClasses){
            caseManagerMap.get(s).afterDelete(oldInheritanceMap.get(s));
        }
    }

    public override void afterUndelete()
    {
        for(String s: applicableClasses){
            caseManagerMap.get(s).afterUndelete();
        }
    }
}