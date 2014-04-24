require 'action_view/helpers'

module FoundationRailsHelper
  class FormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::TagHelper
    %w(file_field email_field text_field text_area telephone_field phone_field url_field number_field).each do |method_name|
      define_method(method_name) do |*args|
        attribute = args[0]
        options   = args[1] || {}
        field(attribute, options) do |options|
          super(attribute, options)
        end
      end
    end

    def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
#      Rails.logger.info("check_box attribute: #{attribute}, options: #{options}")
      label_html = custom_label_inner(attribute, options[:label], options[:label_options])
      options.delete(:label)
      options.delete(:label_options)
      inner = super(attribute, options, checked_value, unchecked_value) + label_html + error_and_hint(attribute, options)
      content_tag(:div, inner, 'class' => 'complex_label')      
    end

    def radio_button(attribute, tag_value, options = {})
      options[:for] ||= "#{object.class.to_s.downcase}_#{attribute}_#{tag_value}"
      c = super(attribute, tag_value, options)
      l = label(attribute, options.delete(:text), options)
      l.gsub(/(for=\"\w*\"\>)/, "\\1#{c} ").html_safe
    end

    def password_field(attribute, options = {})
      field attribute, options do |options|
        super(attribute, options.merge(:autocomplete => :off))
      end
    end

    def datetime_select(attribute, options = {}, html_options = {})
      field attribute, html_options do |html_options|
        super(attribute, options, html_options.merge(:autocomplete => :off))
      end
    end

    def date_select(attribute, options = {}, html_options = {})
      field attribute, html_options do |html_options|
        super(attribute, options, html_options.merge(:autocomplete => :off))
      end
    end

    def time_zone_select(attribute, options = {})
      field attribute, options do |options|
        super(attribute, {}, options.merge(:autocomplete => :off))
      end
    end

    def select(attribute, choices, options = {}, html_options = {})
#      Rails.logger.info("select attribute: #{attribute}, options: #{options}, html_options: #{html_options}")
      field attribute, html_options do |html_options|
        html_options[:autocomplete] ||= :off
        super(attribute, choices, options, html_options)
      end
    end

    def autocomplete(attribute, url, options = {})
      field attribute, options do |options|
        autocomplete_field(attribute, url, options.merge(:update_elements => options[:update_elements],
                                                         :min_length => 0,
                                                         :value => object.send(attribute)))
      end
    end

    def submit(value=nil, options={})
      options[:class] ||= "small radius success button"
      super(value, options)
    end

  private
    def has_error?(attribute)
      !object.errors[attribute].blank?
    end

    def error_for(attribute, options = {})
      class_name = "error"
      class_name += " #{options[:class]}" if options[:class]
      content_tag(:small, object.errors[attribute].join(', '), :class => class_name) if has_error?(attribute)
    end

    def custom_label(attribute, text, options, &block)
      inner = custom_label_inner(attribute, text, options, &block)
      content_tag(:div, inner, 'class' => 'complex_label')      
    end

    def custom_label_inner(attribute, text, options, &block)
#      Rails.logger.info("custom_label object_name: #{object_name}, attribute: #{attribute}, text: #{text}, options: #{options}")
      
      if text == false
        text = ""
      elsif text.nil?
        text = object.class.human_attribute_name(attribute)
      end
      text = block.call.html_safe + text if block_given?

      # add error class?
      options ||= {}
      options[:class] ||= ""
      options[:class] += " error" if has_error?(attribute)

      # add tooltip?
      unless options[:no_tip]
        tip_plc_cls = options[:tip_plc_cls] || 'tip-right'
        tip_title = options[:tip_title] || I18n.t("tips.#{object_name}.#{attribute}")
        options[:class] += " has-tip #{tip_plc_cls}"
        options[:title] = tip_title
        options[:data] = { tooltip: '' }
        
        options.delete :with_tip
        options.delete :tip_plc_cls
        options.delete :tip_title
      end

      # render label in div with optional help blurb
      help_text = options.delete :help
      inner = label(attribute, text, options)
      inner += content_tag(:span, help_text, 'class' => 'help') if help_text
#      Rails.logger.info("custom_label_inner html: #{inner}")
      inner
    end

    def error_and_hint(attribute, options = {})
      html = ""
      html += error_for(attribute, options) || ""
      html.html_safe
    end

    def field(attribute, options, &block)
#      Rails.logger.info("field attribute: #{attribute}, options: #{options}")      
      html = ''.html_safe
      html = custom_label(attribute, options[:label], options[:label_options]) if false != options[:label]
      options[:class] ||= ""
      options[:class] += " error" if has_error?(attribute)
      options.delete(:label)
      options.delete(:label_options)
      html += yield(options)
      html += error_and_hint(attribute, options)
    end
  end
end
