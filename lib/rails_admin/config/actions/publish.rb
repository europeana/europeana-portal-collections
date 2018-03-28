# frozen_string_literal: true

require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Extensions
    module PaperTrail
      class AuditingAdapter
        # @see RailsAdmin::Config::Action::Publish
        def publish_object(_object, _model, _user, _changes)
          # do nothing
        end
      end
    end
  end
end

module RailsAdmin
  module Config
    module Actions
      class Publish < Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member do
          true
        end

        register_instance_option :route_fragment do
          'publish'
        end

        register_instance_option :http_methods do
          %i(get put)
        end

        register_instance_option :authorization_key do
          :publish
        end

        register_instance_option :link_icon do
          'icon-share'
        end

        register_instance_option :visible? do
          authorized? && bindings[:object].respond_to?(:may_publish?) && bindings[:object].may_publish?
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
            elsif request.put? # PUBLISH
              @object.publish
              changes = @object.changes
              if @object.save
                @auditing_adapter&.publish_object(@object, @abstract_model, _current_user, changes)
                respond_to do |format|
                  format.html { redirect_to_on_success }
                  format.js { render json: { id: @object.id.to_s, label: @model_config.with(object: @object).object_label } }
                end
              else
                handle_save_error :publish
              end
            end
          end
        end
      end
    end
  end
end
