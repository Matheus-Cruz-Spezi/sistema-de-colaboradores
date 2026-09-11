module Api
  module V1
    class DepartmentsController < BaseController
      before_action :set_department, only: %i[show update destroy]

      SORTABLE = %w[name created_at].freeze

      # GET /api/v1/departments  (?q= &sort= &direction= &page= &per_page=)
      def index
        authorize! "departments.read"

        scope = Department.select(
          "departments.*, (SELECT COUNT(*) FROM employees " \
          "WHERE employees.department_id = departments.id) AS employees_count"
        )
        scope = scope.where("name ILIKE ?", "%#{params[:q].strip}%") if params[:q].present?
        scope = apply_order(scope, allowed: SORTABLE, default: "name")

        render_page(scope, with: DepartmentSerializer)
      end

      def show
        authorize! "departments.read"
        render_resource(@department, with: DepartmentSerializer)
      end

      def create
        authorize! "departments.manage"

        department = Department.create!(department_params)
        render_resource(department, with: DepartmentSerializer, status: :created)
      end

      def update
        authorize! "departments.manage"

        @department.update!(department_params)
        render_resource(@department, with: DepartmentSerializer)
      end

      def destroy
        authorize! "departments.manage"

        @department.destroy!
        head :no_content
      end

      private

      def set_department
        @department = Department.find(params[:id])
      end

      def department_params
        params.require(:department).permit(:name, :description)
      end
    end
  end
end
