module ParentRelation
  LOCATED = :located
  CONTAINED = :contained
  SUPPORTED = :supported
  ATTACHED = :attached

  include Node
   
  attr_writer :parent_relation
  
  def parent_relation
    @parent_relation ||= :located
  end
end
