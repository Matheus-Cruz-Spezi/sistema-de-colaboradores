module Api
  module V1
    class DashboardController < BaseController
      # GET /api/v1/dashboard
      def show
        authorize! "dashboard.view"

        render json: {
          data: {
            employees: employee_stats,
            by_department: employees_by_department,
            payroll: payroll,
            recent_hires: EmployeeSerializer.new(recent_hires).serializable_hash,
            recent_changes: VersionSerializer.new(recent_changes).serializable_hash,
            notifications: { unread: current_user.notifications.unread.count }
          }
        }
      end

      private

      def employee_stats
        {
          total: Employee.count,
          active: Employee.active.count,
          on_leave: Employee.on_leave.count,
          terminated: Employee.terminated.count
        }
      end

      def employees_by_department
        Department.left_joins(:employees)
                  .group("departments.name")
                  .order("departments.name")
                  .count("employees.id")
                  .map { |name, count| { department: name, employees: count } }
      end

      def payroll
        active = Employee.active
        {
          monthly_total: active.sum(:salary).to_f,
          average_salary: active.average(:salary)&.to_f&.round(2)
        }
      end

      def recent_hires
        Employee.includes(:department).order(hired_on: :desc).limit(5)
      end

      def recent_changes
        PaperTrail::Version.order(created_at: :desc).limit(10)
      end
    end
  end
end
