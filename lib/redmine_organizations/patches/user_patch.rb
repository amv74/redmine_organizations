require_dependency 'project' #see: http://www.redmine.org/issues/11035
require_dependency 'principal'
require_dependency 'user'

#Here's a hack to avoid User class missing Principal scopes
#TODO: find a better hack...
#TODO: confirm the bug is gone in rails 3
#User.scopes[:like] = Principal.scopes[:like]

class User < Principal
  unloadable
  belongs_to :organization

  safe_attributes 'organization_id'

  def update_membership_through_organization(organization_membership)
    if id && project_id = organization_membership.project_id
      attributes = {:user_id => id, :project_id => project_id}
      member = Member.first(:conditions => attributes) || Member.new(attributes)
      member.roles = organization_membership.roles
      member.save!
    end
  end
  
  def destroy_membership_through_organization(project_id)
    if id
      attributes = {:user_id => id, :project_id => project_id}
      Member.first(:conditions => attributes).try(:destroy)
    end
  end
end
