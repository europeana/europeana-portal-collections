require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
module RailsAdmin
  module Config
    module Actions
      class Requeue < Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member do
          true
        end

        register_instance_option :route_fragment do
          'requeue'
        end

        register_instance_option :http_methods do
          [:get, :put]
        end

        register_instance_option :authorization_key do
          :requeue
        end

        register_instance_option :link_icon do
          'icon-refresh'
        end

        register_instance_option :visible? do
          authorized? && bindings[:object].respond_to?(:requeue)
        end

        register_instance_option :bulkable? do
          true
        end

        register_instance_option :controller do
          proc do
            if request.get? # ASK FOR CONFIRMATION
              respond_to do |format|
                format.html { render @action.template_name }
              end
            elsif request.put? # REQUEUE
              if @object.requeue
                respond_to do |format|
                  format.html { redirect_to_on_success }
                  format.js { render json: { id: @object.id.to_s, label: @model_config.with(object: @object).object_label } }
                end
              else
                handle_save_error :requeue
              end
            end
          end
        end
      end
    end
  end
end
