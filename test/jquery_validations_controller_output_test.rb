require File.join(File.dirname(__FILE__), "test_helper")

class JqueryValidationsControllerOutputTest < Test::Unit::TestCase
  def setup
    reset_database
    reset_callbacks Post
    LiveValidations.use(LiveValidations::Adapters::JqueryValidations)
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_json_output
    Post.validates_presence_of :title
    
    render
    
    assert_html "script[type=text/javascript]"
    assert rendered_view.include?("$('#new_post').validate")
    
    expected_json = {
      "rules" => {
        "post[title]" => {"required" => true}
      },
      "messages" => {
        "post[title]" => {"required" => "can't be blank"}
      }
    }
    
    assert rendered_view.include?(expected_json.to_json)
  end
  
 
  def test_validator_options
    Post.validates_presence_of :title
    LiveValidations.use LiveValidations::Adapters::JqueryValidations, :validator_settings => {"errorElement" => "span"}
    
    render
    
    assert rendered_view.include?(%{"errorElement": "span"})
  end
  
  def test_validation_on_attributes_without_form_field
    Post.validates_presence_of :unexisting_attribute
    
    render
    
    assert rendered_view.include?(%{"messages": {}})
    assert rendered_view.include?(%{"rules": {}})
    assert !rendered_view.include?("post[unexisting_attribute]")
  end
end