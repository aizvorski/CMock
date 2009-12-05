require File.expand_path(File.dirname(__FILE__)) + "/../test_helper"
require 'cmock_generator_plugin_callback'

class CMockGeneratorPluginCallbackTest < Test::Unit::TestCase
  def setup
    create_mocks :config, :utils
    
    @cmock_generator_plugin_callback = CMockGeneratorPluginCallback.new(@config, @utils)
  end

  def teardown
  end
  
  should "have set up internal accessors correctly on init" do
    assert_equal(@config, @cmock_generator_plugin_callback.config)
    assert_equal(@utils,  @cmock_generator_plugin_callback.utils)
    assert_equal(3,       @cmock_generator_plugin_callback.priority)
  end
  
  should "not include any additional include files" do 
    assert(!@cmock_generator_plugin_callback.respond_to?(:include_files))
  end
  
  should "add to control structure" do
    function = {:name => "Oak", :args => [:type => "int*", :name => "blah", :ptr? => true], :return_type => "int*"}
    expected = "  CMOCK_Oak_CALLBACK Oak_CallbackFunctionPointer;\n"
    returned = @cmock_generator_plugin_callback.instance_structure(function)
    assert_equal(expected, returned)
  end
  
  should "add mock function declaration for function without arguments" do
    function = {:name => "Maple", :args_string => "void", :return_type => "void"}
    expected = [ "\n",
                 "typedef void (* CMOCK_Maple_CALLBACK)(int NumCalls);\n",
                 "void Maple_StubWithCallback(CMOCK_Maple_CALLBACK Callback);\n" ].join
    returned = @cmock_generator_plugin_callback.mock_function_declarations(function)
    assert_equal(expected, returned)
  end
  
  should "add mock function declaration for function with arguments" do
    function = {:name => "Maple", :args_string => "int* tofu", :return_type => "void"}
    expected = [ "\n",
                 "typedef void (* CMOCK_Maple_CALLBACK)(int* tofu, int NumCalls);\n",
                 "void Maple_StubWithCallback(CMOCK_Maple_CALLBACK Callback);\n" ].join
    returned = @cmock_generator_plugin_callback.mock_function_declarations(function)
    assert_equal(expected, returned)
  end
  
  should "add mock function declaration for function with return values" do
    function = {:name => "Maple", :args_string => "int* tofu", :return_type => "char*"}
    expected = [ "\n",
                 "typedef char* (* CMOCK_Maple_CALLBACK)(int* tofu, int NumCalls);\n",
                 "void Maple_StubWithCallback(CMOCK_Maple_CALLBACK Callback);\n" ].join
    returned = @cmock_generator_plugin_callback.mock_function_declarations(function)
    assert_equal(expected, returned)
  end

  should "add mock function implementation for functions of style 'void func(void)'" do
    function = {:name => "Apple", :args => [], :args_string => "void", :return_type => "void"}
    expected = ["\n",
                "  if (Mock.Apple_CallbackFunctionPointer != NULL)\n",
                "  {\n",
                "    Mock.Apple_CallsExpected++;\n",
                "    Mock.Apple_CallbackFunctionPointer(Mock.Apple_CallCount++);\n",
                "    return;\n",
                "  }\n"
               ].join
    returned = @cmock_generator_plugin_callback.mock_implementation(function)
    assert_equal(expected, returned)
  end

  should "add mock function implementation for functions of style 'int func(void)'" do
    function = {:name => "Apple", :args => [], :args_string => "void", :return_type => "int"}
    expected = ["\n",
                "  if (Mock.Apple_CallbackFunctionPointer != NULL)\n",
                "  {\n",
                "    Mock.Apple_CallsExpected++;\n",
                "    return Mock.Apple_CallbackFunctionPointer(Mock.Apple_CallCount++);\n",
                "  }\n"
               ].join
    returned = @cmock_generator_plugin_callback.mock_implementation(function)
    assert_equal(expected, returned)
  end

  should "add mock function implementation for functions of style 'void func(int* steak, uint8_t flag)'" do
    function = {:name => "Apple", 
                :args => [ { :type => 'int*', :name => 'steak', :ptr? => true},
                  { :type => 'uint8_t', :name => 'flag', :ptr? => false} ], 
                :args_string => "int* steak, uint8_t flag",
                :return_type => "void"}
    expected = ["\n",
                "  if (Mock.Apple_CallbackFunctionPointer != NULL)\n",
                "  {\n",
                "    Mock.Apple_CallsExpected++;\n",
                "    Mock.Apple_CallbackFunctionPointer(steak, flag, Mock.Apple_CallCount++);\n",
                "    return;\n",
                "  }\n"
               ].join
    returned = @cmock_generator_plugin_callback.mock_implementation(function)
    assert_equal(expected, returned)
  end

  should "add mock function implementation for functions of style 'int16_t func(int* steak, uint8_t flag)'" do
    function = {:name => "Apple", 
                :args => [ { :type => 'int*', :name => 'steak', :ptr? => true},
                  { :type => 'uint8_t', :name => 'flag', :ptr? => false} ],
                :args_string => "int* steak, uint8_t flag", 
                :return_type => "int16_t"}
    expected = ["\n",
                "  if (Mock.Apple_CallbackFunctionPointer != NULL)\n",
                "  {\n",
                "    Mock.Apple_CallsExpected++;\n",
                "    return Mock.Apple_CallbackFunctionPointer(steak, flag, Mock.Apple_CallCount++);\n",
                "  }\n"
               ].join
    returned = @cmock_generator_plugin_callback.mock_implementation(function)
    assert_equal(expected, returned)
  end
  
  should "add mock interfaces for functions " do
    function = {:name => "Lemon", 
                :args => [{ :type => "char*", :name => "pescado"}], 
                :args_string => "char* pescado",
                :return_type => "int", 
                :return_string => "int toReturn" }
     
    expected = ["\n",
                "void Lemon_StubWithCallback(CMOCK_Lemon_CALLBACK Callback)\n",
                "{\n",
                "  Mock.Lemon_CallbackFunctionPointer = Callback;\n",
                "}\n"
               ].join
    returned = @cmock_generator_plugin_callback.mock_interfaces(function)
    assert_equal(expected, returned)
  end

  should "add mock destroy for functions" do
    function = {:name => "Peach", :args => [], :return_type => "void" }
    expected = ["\n",
                "  Mock.Peach_CallbackFunctionPointer = NULL;\n" ].join
    returned = @cmock_generator_plugin_callback.mock_destroy(function)
    assert_equal(expected, returned)
  end
end