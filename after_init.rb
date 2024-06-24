lib_dir = File.join(File.dirname(__FILE__), 'lib', 'easy_gantt')

# Redmine patches
patch_path = File.join(lib_dir, '*_patch.rb')
Dir.glob(patch_path).each do |file|
  require file
end

require lib_dir
require File.join(lib_dir, 'hooks')

Redmine::MenuManager.map :top_menu do |menu|
  menu.push(:easy_gantt, { controller: 'easy_gantt', action: 'index', set_filter: 0 },
    caption: :label_easy_gantt,
    after: :documents,
    html: { class: 'icon icon-stats' },
    if: proc { User.current.allowed_to_globally?(:view_global_easy_gantt) })
end

Redmine::MenuManager.map :project_menu do |menu|
  menu.push(:easy_gantt, { controller: 'easy_gantt', action: 'index' },
    param: :project_id,
    caption: :button_project_menu_easy_gantt,
    if: proc { |p| User.current.allowed_to?(:view_easy_gantt, p) })
end

Redmine::MenuManager.map :easy_gantt_tools do |menu|
  menu.push(:back, 'javascript:void(0)',
            param: :project_id,
            caption: :button_back,
            html: { icon: 'icon-back' })

  menu.push(:task_control, 'javascript:void(0)',
            param: :project_id,
            caption: :button_edit,
            html: { icon: 'icon-edit' })

  menu.push(:add_task, 'javascript:void(0)',
            param: :project_id,
            caption: :label_new,
            html: { trial: true, icon: 'icon-add' },
            if: proc { |p| p.present? })

  menu.push(:critical, 'javascript:void(0)',
            param: :project_id,
            caption: :'easy_gantt.button.critical_path',
            html: { trial: true, icon: 'icon-summary' },
            if: proc { |p| p.present? })

  menu.push(:baseline, 'javascript:void(0)',
            param: :project_id,
            caption: :'easy_gantt.button.create_baseline',
            html: { trial: true, icon: 'icon-projects icon-project' },
            if: proc { |p| p.present? })

  menu.push(:resource, proc { |project| defined?(EasyUserAllocations) ? { controller: 'user_allocation_gantt', project_id: project } : nil },
            param: :project_id,
            caption: :'easy_gantt.button.resource_management',
            html: { trial: true, icon: 'icon-stats' },
            if: proc { |p| p.present? && Redmine::Plugin.installed?(:easy_gantt_resources) })

end


  Redmine::AccessControl.map do |map|
    map.project_module :easy_gantt do |pmap|
      # View project level
      pmap.permission(:view_easy_gantt, {
        easy_gantt: [:index, :issues, :projects],
        easy_gantt_pro: [:lowest_progress_tasks, :cashflow_data],
        easy_gantt_resources: [:index, :project_data, :users_sums, :projects_sums, :allocated_issues],
        easy_resource_limits: [:index]
      }, read: true)

      # Edit project level
      pmap.permission(:edit_easy_gantt, {
        easy_gantt: [:change_issue_relation_delay, :reschedule_project],
        easy_gantt_resources: [:bulk_update_or_create],
        easy_resource_limits: [:new, :create, :edit, :update, :destroy]
      }, require: :member)

      # View global level
      pmap.permission(:view_global_easy_gantt, {
        easy_gantt: [:index, :issues, :projects, :project_issues],
        easy_gantt_pro: [:lowest_progress_tasks, :cashflow_data],
        easy_gantt_resources: [:index, :project_data, :global_data, :projects_sums, :allocated_issues],
        easy_resource_limits: [:index]
      }, global: true, read: true)

      # Edit global level
      pmap.permission(:edit_global_easy_gantt, {
        easy_gantt_resources: [:bulk_update_or_create],
        easy_resource_limits: [:new, :create, :edit, :update, :destroy]
      }, global: true, require: :loggedin)

      # View personal level
      # pmap.permission(:view_personal_easy_gantt, {
      #   easy_gantt_resources: [:global_data],
      #   easy_resource_limits: [:index]
      # }, global: true, read: true)

      # Edit personal level
      pmap.permission(:edit_personal_easy_gantt, {
        easy_gantt_resources: [:bulk_update_or_create],
        easy_resource_limits: [:new, :create, :edit, :update, :destroy]
      }, global: true, require: :loggedin)
    end

end
