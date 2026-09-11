module Api
  module V1
    # Autorização por perfil via EmployeePolicy (Pundit):
    #   colaborador -> só o próprio perfil | manager -> todos | admin -> todos + edição
    class EmployeesController < BaseController
      before_action :set_employee, only: %i[show update destroy history]
      after_action :verify_authorized
      after_action :verify_policy_scoped, only: :index

      SORTABLE = %w[full_name job_title hired_on salary employment_status created_at].freeze

      # GET /api/v1/employees
      # Filtros: ?q= &department_id= &status=active|on_leave|terminated
      # Ordenação: ?sort= &direction=asc|desc  |  Paginação: ?page= &per_page=
      def index
        authorize Employee

        scope = policy_scope(Employee)
                .includes(:department, user: :role)
                .search(params[:q])
                .by_department(params[:department_id])
                .by_status(params[:status])
        scope = apply_order(scope, allowed: SORTABLE, default: "full_name")

        render_page(scope, with: EmployeeSerializer)
      end

      # GET /api/v1/employees/:id
      def show
        authorize @employee
        render_resource(@employee, with: EmployeeSerializer)
      end

      # POST /api/v1/employees
      def create
        authorize Employee

        employee = Employee.new(employee_params)
        employee.save!
        render_resource(employee, with: EmployeeSerializer, status: :created)
      end

      # PATCH/PUT /api/v1/employees/:id
      def update
        authorize @employee

        @employee.update!(employee_params)
        render_resource(@employee, with: EmployeeSerializer)
      end

      # DELETE /api/v1/employees/:id
      def destroy
        authorize @employee

        @employee.destroy!
        head :no_content
      end

      # GET /api/v1/employees/:id/history — histórico de alterações (paper_trail)
      def history
        authorize @employee, :history?

        render_page(@employee.versions.reorder(created_at: :desc), with: VersionSerializer)
      end

      private

      def set_employee
        @employee = Employee.find(params[:id])
      end

      def employee_params
        params.require(:employee).permit(
          :full_name, :email, :document_number, :job_title, :phone,
          :employment_status, :hired_on, :terminated_on, :birth_date, :salary,
          :department_id, :user_id
        )
      end
    end
  end
end
